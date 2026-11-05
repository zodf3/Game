enum MessageType {
  lobbyUpdate,
  seatAssignment,
  gameStateUpdate,
  actionBid,
  actionSelectTrump,
  actionPlayCard,
  actionRevealTrump,
  actionClaimPair,
}

class NetworkMessage {
  final MessageType type;
  final Map<String, dynamic> payload;

  NetworkMessage({required this.type, required this.payload});

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'payload': payload,
  };

  factory NetworkMessage.fromJson(Map<String, dynamic> json) => NetworkMessage(
    type: MessageType.values.byName(json['type'] as String),
    payload: (json['payload'] as Map<String, dynamic>?) ?? {},
  );
}
