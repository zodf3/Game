import 'card.dart';
import 'player.dart';

enum GamePhase {
  lobby,
  dealingFirstFour,
  bidding,
  trumpSelection,
  dealingSecondFour,
  trickPlay,
  roundOver,
  gameOver,
}

class PlayedCard {
  final int playerIndex;
  final PlayingCard card;

  const PlayedCard({required this.playerIndex, required this.card});

  Map<String, dynamic> toJson() => {
    'playerIndex': playerIndex,
    'card': card.toJson(),
  };

  factory PlayedCard.fromJson(Map<String, dynamic> json) => PlayedCard(
    playerIndex: json['playerIndex'] as int,
    card: PlayingCard.fromJson(json['card'] as Map<String, dynamic>),
  );
}

class GameRoundState {
  GamePhase phase;
  int currentTurn;
  int dealerIndex;

  // Bidding
  int highestBid;
  int? highestBidderIndex;
  List<bool> hasPassed;
  int consecutivePasses;

  // Trump and Reverse Mode
  Suit? trumpSuit;
  bool isReverseGame; // ULTA 29: 7 > 8 > Q > K > 10 > A > 9 > J
  bool isTrumpRevealed;
  int? trumpRevealerIndex;
  PlayingCard? hiddenTrumpCard;

  // Current Trick
  List<PlayedCard> currentTrick;
  int trickNumber; // 1 to 8
  int? leadPlayerIndex;

  // Scoring
  int team0Points; // South + North
  int team1Points; // East + West
  int? lastTrickWinnerIndex;
  int pairBonusTeam0;
  int pairBonusTeam1;

  // Match Game Points (Pips)
  int team0GameScore;
  int team1GameScore;

  GameRoundState({
    this.phase = GamePhase.lobby,
    this.currentTurn = 0,
    this.dealerIndex = 3, // dealer is West, South bids first
    this.highestBid = 15,
    this.highestBidderIndex,
    List<bool>? hasPassed,
    this.consecutivePasses = 0,
    this.trumpSuit,
    this.isReverseGame = false,
    this.isTrumpRevealed = false,
    this.trumpRevealerIndex,
    this.hiddenTrumpCard,
    List<PlayedCard>? currentTrick,
    this.trickNumber = 1,
    this.leadPlayerIndex,
    this.team0Points = 0,
    this.team1Points = 0,
    this.lastTrickWinnerIndex,
    this.pairBonusTeam0 = 0,
    this.pairBonusTeam1 = 0,
    this.team0GameScore = 0,
    this.team1GameScore = 0,
  })  : hasPassed = hasPassed ?? [false, false, false, false],
        currentTrick = currentTrick ?? [];

  void resetForNewRound() {
    dealerIndex = (dealerIndex + 1) % 4;
    currentTurn = (dealerIndex + 1) % 4;
    phase = GamePhase.dealingFirstFour;
    highestBid = 15;
    highestBidderIndex = null;
    hasPassed = [false, false, false, false];
    consecutivePasses = 0;
    trumpSuit = null;
    isReverseGame = false;
    isTrumpRevealed = false;
    trumpRevealerIndex = null;
    hiddenTrumpCard = null;
    currentTrick = [];
    trickNumber = 1;
    leadPlayerIndex = null;
    team0Points = 0;
    team1Points = 0;
    lastTrickWinnerIndex = null;
    pairBonusTeam0 = 0;
    pairBonusTeam1 = 0;
  }

  Map<String, dynamic> toJson() => {
    'phase': phase.name,
    'currentTurn': currentTurn,
    'dealerIndex': dealerIndex,
    'highestBid': highestBid,
    'highestBidderIndex': highestBidderIndex,
    'hasPassed': hasPassed,
    'consecutivePasses': consecutivePasses,
    'trumpSuit': trumpSuit?.name,
    'isReverseGame': isReverseGame,
    'isTrumpRevealed': isTrumpRevealed,
    'trumpRevealerIndex': trumpRevealerIndex,
    'hiddenTrumpCard': isTrumpRevealed ? hiddenTrumpCard?.toJson() : null,
    'currentTrick': currentTrick.map((p) => p.toJson()).toList(),
    'trickNumber': trickNumber,
    'leadPlayerIndex': leadPlayerIndex,
    'team0Points': team0Points,
    'team1Points': team1Points,
    'pairBonusTeam0': pairBonusTeam0,
    'pairBonusTeam1': pairBonusTeam1,
    'team0GameScore': team0GameScore,
    'team1GameScore': team1GameScore,
  };
}
