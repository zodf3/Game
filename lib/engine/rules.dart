import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class GameRules {
  static const int minBid = 16;
  static const int maxBid = 28;
  static const int targetPointsToWinMatch = 6;

  /// Creates a standard 32-card 29 deck
  static List<PlayingCard> createDeck() {
    final deck = <PlayingCard>[];
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        deck.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    return deck;
  }

  /// Determines which cards a player is legally allowed to play
  static List<PlayingCard> getValidCards({
    required Player player,
    required GameRoundState state,
  }) {
    if (player.hand.isEmpty) return [];

    // If leading the trick
    if (state.currentTrick.isEmpty) {
      // If trump is not revealed, bidder cannot lead trump unless they have ONLY trump cards
      if (!state.isTrumpRevealed &&
          state.highestBidderIndex == player.id &&
          state.trumpSuit != null) {
        final nonTrumpCards = player.hand.where((c) => c.suit != state.trumpSuit).toList();
        if (nonTrumpCards.isNotEmpty) {
          return nonTrumpCards;
        }
      }
      return List.from(player.hand);
    }

    // Following a trick
    final leadCard = state.currentTrick.first.card;
    final sameSuitCards = player.hand.where((c) => c.suit == leadCard.suit).toList();

    // Must follow suit if able
    if (sameSuitCards.isNotEmpty) {
      return sameSuitCards;
    }

    // Player does not have lead suit
    // If trump is revealed, can play trump or any card
    return List.from(player.hand);
  }

  /// Resolves the winner of a trick according to 29 rules (Standard or Reverse)
  static int determineTrickWinner({
    required List<PlayedCard> trick,
    required Suit? trumpSuit,
    required bool isTrumpRevealed,
    required bool isReverse,
  }) {
    assert(trick.isNotEmpty, 'Trick cannot be empty');

    final leadCard = trick.first.card;
    int winningPlayer = trick.first.playerIndex;
    PlayingCard winningCard = leadCard;

    for (int i = 1; i < trick.length; i++) {
      final candidate = trick[i];
      final card = candidate.card;

      final bool isCandidateTrump = isTrumpRevealed && trumpSuit != null && card.suit == trumpSuit;
      final bool isWinningTrump = isTrumpRevealed && trumpSuit != null && winningCard.suit == trumpSuit;

      if (isCandidateTrump) {
        if (!isWinningTrump) {
          // Trump card beats non-trump card
          winningCard = card;
          winningPlayer = candidate.playerIndex;
        } else {
          // Both are trump cards: compare power based on game mode (Standard vs Reverse)
          if (card.power(isReverse: isReverse) > winningCard.power(isReverse: isReverse)) {
            winningCard = card;
            winningPlayer = candidate.playerIndex;
          }
        }
      } else if (!isWinningTrump && card.suit == leadCard.suit) {
        // Neither is trump: compare power of lead suit
        if (card.power(isReverse: isReverse) > winningCard.power(isReverse: isReverse)) {
          winningCard = card;
          winningPlayer = candidate.playerIndex;
        }
      }
    }

    return winningPlayer;
  }

  /// Calculates points in a trick
  static int calculateTrickPoints(List<PlayedCard> trick) {
    return trick.fold(0, (sum, played) => sum + played.card.points);
  }

  /// Checks if player holds Pair / Marriage (King + Queen of trump)
  static bool hasPair(Player player, Suit? trumpSuit) {
    if (trumpSuit == null) return false;
    bool hasKing = false;
    bool hasQueen = false;

    for (final card in player.hand) {
      if (card.suit == trumpSuit) {
        if (card.rank == Rank.king) hasKing = true;
        if (card.rank == Rank.queen) hasQueen = true;
      }
    }
    return hasKing && hasQueen;
  }
}
