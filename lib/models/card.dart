enum Suit {
  spades('♠', 'Spades'),
  hearts('♥', 'Hearts'),
  diamonds('♦', 'Diamonds'),
  clubs('♣', 'Clubs');

  final String symbol;
  final String label;
  const Suit(this.symbol, this.label);

  bool get isRed => this == Suit.hearts || this == Suit.diamonds;
}

enum Rank {
  seven('7', 0, 1, 8),
  eight('8', 0, 2, 7),
  nine('9', 2, 7, 2),
  ten('10', 1, 5, 4),
  jack('J', 3, 8, 1),
  queen('Q', 0, 3, 6),
  king('K', 0, 4, 5),
  ace('A', 1, 6, 3);

  final String label;
  final int points;
  final int standardPower;
  final int reversePower;

  const Rank(this.label, this.points, this.standardPower, this.reversePower);
}

class PlayingCard {
  final Suit suit;
  final Rank rank;

  const PlayingCard({required this.suit, required this.rank});

  int get points => rank.points;

  int power({required bool isReverse}) {
    return isReverse ? rank.reversePower : rank.standardPower;
  }

  Map<String, dynamic> toJson() => {
    'suit': suit.name,
    'rank': rank.name,
  };

  factory PlayingCard.fromJson(Map<String, dynamic> json) {
    return PlayingCard(
      suit: Suit.values.byName(json['suit'] as String),
      rank: Rank.values.byName(json['rank'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() => '${rank.label}${suit.symbol}';
}
