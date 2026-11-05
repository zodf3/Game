import 'card.dart';

enum PlayerPosition {
  south(0, 'You', 0),
  east(1, 'vut', 1),
  north(2, 'dada', 0),
  west(3, 'kukur', 1);

  final int seatNumber;
  final String defaultName;
  final int team; // 0 for South-North, 1 for East-West

  const PlayerPosition(this.seatNumber, this.defaultName, this.team);
}

class Player {
  final int id;
  String name;
  bool isBot;
  bool isLocalUser;
  final int team;
  List<PlayingCard> hand;
  bool declaredPair;

  Player({
    required this.id,
    required this.name,
    this.isBot = false,
    this.isLocalUser = false,
    required this.team,
    List<PlayingCard>? hand,
    this.declaredPair = false,
  }) : hand = hand ?? [];

  PlayerPosition get position => PlayerPosition.values[id];

  void sortHand() {
    hand.sort((a, b) {
      if (a.suit.index != b.suit.index) {
        return a.suit.index.compareTo(b.suit.index);
      }
      return a.rank.standardPower.compareTo(b.rank.standardPower);
    });
  }

  Map<String, dynamic> toJson({bool includeHand = true}) => {
    'id': id,
    'name': name,
    'isBot': isBot,
    'isLocalUser': isLocalUser,
    'team': team,
    'declaredPair': declaredPair,
    if (includeHand) 'hand': hand.map((c) => c.toJson()).toList(),
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as int,
      name: json['name'] as String,
      isBot: json['isBot'] as bool? ?? false,
      isLocalUser: json['isLocalUser'] as bool? ?? false,
      team: json['team'] as int,
      declaredPair: json['declaredPair'] as bool? ?? false,
      hand: (json['hand'] as List<dynamic>?)
          ?.map((c) => PlayingCard.fromJson(c as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
