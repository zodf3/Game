import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'rules.dart';

class BotDecision {
  final PlayingCard cardToPlay;
  final bool shouldRequestTrumpReveal;

  const BotDecision({
    required this.cardToPlay,
    this.shouldRequestTrumpReveal = false,
  });
}

class BotAI {
  static final Random _rng = Random();

  /// Evaluates 4 initial cards for bidding and decides standard vs reverse potential
  static int? evaluateBid(Player bot, int currentHighestBid) {
    if (bot.hand.length < 4) return null;

    final standardScore = _evaluateStandardHand(bot.hand);
    final reverseScore = _evaluateReverseHand(bot.hand);
    final maxPotential = max(standardScore, reverseScore);

    // Bidding threshold logic
    int maxWillingToBid = 15;
    if (maxPotential >= 12) maxWillingToBid = 20;
    else if (maxPotential >= 10) maxWillingToBid = 18;
    else if (maxPotential >= 8) maxWillingToBid = 17;
    else if (maxPotential >= 6) maxWillingToBid = 16;

    if (maxWillingToBid > currentHighestBid) {
      return currentHighestBid + 1;
    }
    return null; // Pass
  }

  static int _evaluateStandardHand(List<PlayingCard> hand) {
    int score = 0;
    for (final c in hand) {
      if (c.rank == Rank.jack) score += 4;
      if (c.rank == Rank.nine) score += 3;
      if (c.rank == Rank.ace) score += 2;
      if (c.rank == Rank.ten) score += 1;
    }
    return score;
  }

  static int _evaluateReverseHand(List<PlayingCard> hand) {
    // In Reverse: 7, 8, Q are trick winners!
    int score = 0;
    for (final c in hand) {
      if (c.rank == Rank.seven) score += 4;
      if (c.rank == Rank.eight) score += 3;
      if (c.rank == Rank.queen) score += 2;
      if (c.rank == Rank.king) score += 1;
    }
    return score;
  }

  /// Chooses trump suit and whether to play Reverse (Ulta) Game
  static ({Suit suit, bool isReverse, PlayingCard trumpCard}) chooseTrump(Player bot) {
    // Evaluate each suit for both Standard and Reverse power
    Suit bestSuit = Suit.hearts;
    bool isReverse = false;
    int bestScore = -1;

    for (final suit in Suit.values) {
      final suitCards = bot.hand.where((c) => c.suit == suit).toList();
      if (suitCards.isEmpty) continue;

      final stdScore = _evaluateStandardHand(suitCards) + suitCards.length * 2;
      final revScore = _evaluateReverseHand(suitCards) + suitCards.length * 2;

      if (stdScore > bestScore) {
        bestScore = stdScore;
        bestSuit = suit;
        isReverse = false;
      }
      if (revScore > bestScore) {
        bestScore = revScore;
        bestSuit = suit;
        isReverse = true;
      }
    }

    // Pick an actual card in hand of bestSuit to be the hidden card
    final suitCards = bot.hand.where((c) => c.suit == bestSuit).toList();
    final trumpCard = suitCards.isNotEmpty ? suitCards.first : bot.hand.first;

    return (suit: bestSuit, isReverse: isReverse, trumpCard: trumpCard);
  }

  /// Chooses whether to reveal trump when unable to follow suit
  static bool shouldRevealTrump(Player bot, GameRoundState state) {
    if (state.isTrumpRevealed || state.trumpSuit == null) return false;

    // Check if bot has trump cards
    final hasTrump = bot.hand.any((c) => c.suit == state.trumpSuit);
    if (!hasTrump) return false;

    // If opponent is currently winning high points trick, reveal trump to cut and take it
    final currentPoints = GameRules.calculateTrickPoints(state.currentTrick);
    return currentPoints >= 2;
  }

  /// AI decision on card play
  static PlayingCard chooseCard(Player bot, GameRoundState state) {
    final validCards = GameRules.getValidCards(player: bot, state: state);
    if (validCards.length == 1) return validCards.first;

    final isReverse = state.isReverseGame;

    // Scenario 1: Leading the trick
    if (state.currentTrick.isEmpty) {
      if (isReverse) {
        // In Reverse: 7 is the strongest card!
        final sevens = validCards.where((c) => c.rank == Rank.seven).toList();
        if (sevens.isNotEmpty) return sevens.first;

        final eights = validCards.where((c) => c.rank == Rank.eight).toList();
        if (eights.isNotEmpty) return eights.first;

        // Otherwise lead low-point cards
        validCards.sort((a, b) => a.points.compareTo(b.points));
        return validCards.first;
      } else {
        // Standard mode: Lead Ace if we have it
        final aces = validCards.where((c) => c.rank == Rank.ace).toList();
        if (aces.isNotEmpty) return aces.first;

        // Or lead 10/K if safe
        validCards.sort((a, b) => b.power(isReverse: false).compareTo(a.power(isReverse: false)));
        return validCards.last; // play safe low card
      }
    }

    // Scenario 2: Following the trick
    final currentWinnerId = GameRules.determineTrickWinner(
      trick: state.currentTrick,
      trumpSuit: state.trumpSuit,
      isTrumpRevealed: state.isTrumpRevealed,
      isReverse: isReverse,
    );
    final isPartnerWinning = (currentWinnerId % 2) == bot.team;

    if (isPartnerWinning) {
      // Partner is winning: feed points to partner!
      validCards.sort((a, b) => b.points.compareTo(a.points));
      return validCards.first; // Drop Jack (3) or 9 (2)
    } else {
      // Opponent is winning: try to beat them with the minimum necessary winning card
      final winningCards = validCards.where((c) {
        final simulatedTrick = [...state.currentTrick, PlayedCard(playerIndex: bot.id, card: c)];
        return GameRules.determineTrickWinner(
          trick: simulatedTrick,
          trumpSuit: state.trumpSuit,
          isTrumpRevealed: state.isTrumpRevealed,
          isReverse: isReverse,
        ) == bot.id;
      }).toList();

      if (winningCards.isNotEmpty) {
        // Pick winning card with lowest power to save top cards
        winningCards.sort((a, b) =>
            a.power(isReverse: isReverse).compareTo(b.power(isReverse: isReverse)));
        return winningCards.first;
      }

      // Cannot win trick: throw away 0 point cards
      validCards.sort((a, b) => a.points.compareTo(b.points));
      return validCards.first;
    }
  }
}
