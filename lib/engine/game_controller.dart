import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'rules.dart';
import 'bot_ai.dart';

typedef StateCallback = void Function(Map<String, dynamic> statePayload);

class GameController extends ChangeNotifier {
  final List<Player> players = [];
  final GameRoundState state = GameRoundState();
  List<PlayingCard> _remainingDeck = [];

  StateCallback? onBroadcastState;
  VoidCallback? onNeedUserBid;
  VoidCallback? onNeedUserTrump;
  VoidCallback? onNeedUserCard;

  String userName;

  GameController({this.userName = 'Player 1'}) {
    _initializeDefaultPlayers();
  }

  void updateUserName(String newName) {
    if (newName.trim().isNotEmpty) {
      userName = newName.trim();
      if (players.isNotEmpty) {
        players[0].name = userName;
        notifyListeners();
      }
    }
  }

  void _initializeDefaultPlayers() {
    players.clear();
    players.addAll([
      Player(id: 0, name: userName, isBot: false, isLocalUser: true, team: 0),
      Player(id: 1, name: 'vut', isBot: true, isLocalUser: false, team: 1),
      Player(id: 2, name: 'dada', isBot: true, isLocalUser: false, team: 0),
      Player(id: 3, name: 'kukur', isBot: true, isLocalUser: false, team: 1),
    ]);
  }

  Player get localPlayer => players[0];
  Player get currentPlayer => players[state.currentTurn];

  /// Starts a fresh round
  void startNewRound() {
    state.resetForNewRound();
    for (final p in players) {
      p.hand.clear();
      p.declaredPair = false;
    }

    _remainingDeck = GameRules.createDeck();
    _remainingDeck.shuffle();

    // Deal first 4 cards
    _dealInitialCards();
    state.phase = GamePhase.bidding;
    state.currentTurn = (state.dealerIndex + 1) % 4;
    notifyListeners();
    _broadcast();

    _triggerTurnAction();
  }

  void _dealInitialCards() {
    for (int i = 0; i < 4; i++) {
      players[i].hand.addAll(_remainingDeck.take(4));
      _remainingDeck.removeRange(0, 4);
      players[i].sortHand();
    }
  }

  void _dealRemainingCards() {
    for (int i = 0; i < 4; i++) {
      players[i].hand.addAll(_remainingDeck.take(4));
      _remainingDeck.removeRange(0, 4);
      players[i].sortHand();
    }
    state.phase = GamePhase.trickPlay;
    // Highest bidder leads first trick
    state.currentTurn = state.highestBidderIndex ?? 0;
    state.leadPlayerIndex = state.currentTurn;
    notifyListeners();
    _broadcast();

    _triggerTurnAction();
  }

  void _triggerTurnAction() {
    if (state.phase == GamePhase.bidding) {
      final p = currentPlayer;
      if (p.isLocalUser) {
        onNeedUserBid?.call();
      } else {
        Future.delayed(const Duration(milliseconds: 700), () => _processBotBid());
      }
    } else if (state.phase == GamePhase.trumpSelection) {
      final bidder = players[state.highestBidderIndex!];
      if (bidder.isLocalUser) {
        onNeedUserTrump?.call();
      } else {
        Future.delayed(const Duration(milliseconds: 800), () => _processBotTrumpSelection());
      }
    } else if (state.phase == GamePhase.trickPlay) {
      final p = currentPlayer;
      if (p.isLocalUser) {
        onNeedUserCard?.call();
      } else {
        Future.delayed(const Duration(milliseconds: 800), () => _processBotCardPlay());
      }
    }
  }

  // --- BIDDING ---
  void submitBid({required int playerIndex, required int? bid}) {
    if (state.phase != GamePhase.bidding || state.currentTurn != playerIndex) return;

    if (bid != null && bid > state.highestBid) {
      state.highestBid = bid;
      state.highestBidderIndex = playerIndex;
      state.consecutivePasses = 0;
    } else {
      state.hasPassed[playerIndex] = true;
      state.consecutivePasses++;
    }

    // Check if bidding concluded
    // Bidding ends when 3 players have passed
    final passedCount = state.hasPassed.where((p) => p).length;
    if (passedCount >= 3 && state.highestBidderIndex != null) {
      state.phase = GamePhase.trumpSelection;
      state.currentTurn = state.highestBidderIndex!;
      notifyListeners();
      _broadcast();
      _triggerTurnAction();
      return;
    }

    // Advance turn to next unpassed player
    int nextTurn = (state.currentTurn + 1) % 4;
    while (state.hasPassed[nextTurn]) {
      nextTurn = (nextTurn + 1) % 4;
    }
    state.currentTurn = nextTurn;
    notifyListeners();
    _broadcast();

    _triggerTurnAction();
  }

  void _processBotBid() {
    final bot = currentPlayer;
    final bid = BotAI.evaluateBid(bot, state.highestBid);
    submitBid(playerIndex: bot.id, bid: bid);
  }

  // --- TRUMP & REVERSE SELECTION ---
  void selectTrump({
    required int playerIndex,
    required Suit suit,
    required bool isReverseGame,
    required PlayingCard trumpCard,
  }) {
    if (state.phase != GamePhase.trumpSelection || state.highestBidderIndex != playerIndex) return;

    state.trumpSuit = suit;
    state.isReverseGame = isReverseGame;
    state.hiddenTrumpCard = trumpCard;
    state.isTrumpRevealed = false;

    // Deal remaining 4 cards each
    _dealRemainingCards();
  }

  void _processBotTrumpSelection() {
    final bot = players[state.highestBidderIndex!];
    final result = BotAI.chooseTrump(bot);
    selectTrump(
      playerIndex: bot.id,
      suit: result.suit,
      isReverseGame: result.isReverse,
      trumpCard: result.trumpCard,
    );
  }

  // --- REVEAL TRUMP ---
  void revealTrump({required int playerIndex}) {
    if (state.isTrumpRevealed || state.trumpSuit == null) return;
    state.isTrumpRevealed = true;
    state.trumpRevealerIndex = playerIndex;
    notifyListeners();
    _broadcast();
  }

  // --- PAIR / MARRIAGE ---
  bool claimPair({required int playerIndex}) {
    if (!state.isTrumpRevealed) return false;
    final player = players[playerIndex];
    if (player.declaredPair) return false;

    if (GameRules.hasPair(player, state.trumpSuit)) {
      player.declaredPair = true;
      if (player.team == 0) {
        state.pairBonusTeam0 += 4;
      } else {
        state.pairBonusTeam1 += 4;
      }
      notifyListeners();
      _broadcast();
      return true;
    }
    return false;
  }

  // --- CARD PLAY ---
  void playCard({required int playerIndex, required PlayingCard card}) {
    if (state.phase != GamePhase.trickPlay || state.currentTurn != playerIndex) return;
    final player = players[playerIndex];

    final validCards = GameRules.getValidCards(player: player, state: state);
    if (!validCards.contains(card)) return;

    player.hand.remove(card);
    state.currentTrick.add(PlayedCard(playerIndex: playerIndex, card: card));
    notifyListeners();
    _broadcast();

    if (state.currentTrick.length == 4) {
      // Trick complete
      Future.delayed(const Duration(milliseconds: 1200), () => _resolveTrick());
    } else {
      // Next player's turn
      state.currentTurn = (state.currentTurn + 1) % 4;
      notifyListeners();
      _broadcast();
      _triggerTurnAction();
    }
  }

  void _processBotCardPlay() {
    final bot = currentPlayer;

    // Check if bot needs to reveal trump
    if (BotAI.shouldRevealTrump(bot, state)) {
      revealTrump(playerIndex: bot.id);
    }

    final card = BotAI.chooseCard(bot, state);
    playCard(playerIndex: bot.id, card: card);
  }

  void _resolveTrick() {
    final winnerId = GameRules.determineTrickWinner(
      trick: state.currentTrick,
      trumpSuit: state.trumpSuit,
      isTrumpRevealed: state.isTrumpRevealed,
      isReverse: state.isReverseGame,
    );

    final trickPoints = GameRules.calculateTrickPoints(state.currentTrick);
    final winner = players[winnerId];

    if (winner.team == 0) {
      state.team0Points += trickPoints;
    } else {
      state.team1Points += trickPoints;
    }

    state.lastTrickWinnerIndex = winnerId;
    state.currentTrick.clear();

    if (state.trickNumber == 8) {
      // Award 1 point for the final trick
      if (winner.team == 0) {
        state.team0Points += 1;
      } else {
        state.team1Points += 1;
      }
      _endRound();
    } else {
      state.trickNumber++;
      state.currentTurn = winnerId;
      state.leadPlayerIndex = winnerId;
      notifyListeners();
      _broadcast();
      _triggerTurnAction();
    }
  }

  void _endRound() {
    state.phase = GamePhase.roundOver;

    final bidderIndex = state.highestBidderIndex!;
    final bidderTeam = players[bidderIndex].team;
    final targetBid = state.highestBid;

    // Adjust target with Pair bonus
    final team0Total = state.team0Points + state.pairBonusTeam0;
    final team1Total = state.team1Points + state.pairBonusTeam1;

    final bidderPoints = bidderTeam == 0 ? team0Total : team1Total;
    final bool bidderWon = bidderPoints >= targetBid;

    // Game points (Pips): Bids of 21+ are worth 2 pips, otherwise 1 pip
    final int pipValue = (targetBid >= 21) ? 2 : 1;

    if (bidderWon) {
      if (bidderTeam == 0) {
        state.team0GameScore += pipValue;
      } else {
        state.team1GameScore += pipValue;
      }
    } else {
      // Failed bid
      if (bidderTeam == 0) {
        state.team0GameScore -= pipValue;
      } else {
        state.team1GameScore -= pipValue;
      }
    }

    if (state.team0GameScore.abs() >= GameRules.targetPointsToWinMatch ||
        state.team1GameScore.abs() >= GameRules.targetPointsToWinMatch) {
      state.phase = GamePhase.gameOver;
    }

    notifyListeners();
    _broadcast();
  }

  void _broadcast() {
    onBroadcastState?.call(state.toJson());
  }
}
