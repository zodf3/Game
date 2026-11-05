import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'protocol.dart';

typedef OnMessageReceived = void Function(NetworkMessage message, int senderId);

class ConnectedFriend {
  final String endpointId;
  final String name;
  final int assignedSeat;

  ConnectedFriend({
    required this.endpointId,
    required this.name,
    required this.assignedSeat,
  });
}

class BluetoothManager extends ChangeNotifier {
  static const Strategy strategy = Strategy.P2P_STAR; // 1 Host + up to 3 peers

  bool isAdvertising = false;
  bool isDiscovering = false;
  bool isHost = false;
  bool isConnected = false;
  int localSeatIndex = 0; // 0 = Host (South)

  final List<ConnectedFriend> connectedPeers = [];
  final Map<String, String> discoveredHosts = {}; // endpointId -> name

  OnMessageReceived? onMessageReceived;

  // --- HOST ROLE ---
  Future<bool> startHostServer({String hostName = 'Host'}) async {
    try {
      isHost = true;
      localSeatIndex = 0;
      connectedPeers.clear();
      isAdvertising = true;
      notifyListeners();

      await Nearby().startAdvertising(
        hostName,
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endid, payload) => _handleIncomingPayload(endid, payload),
          );
        },
        onConnectionResult: (String id, Status status) {
          if (status == Status.CONNECTED) {
            final seat = connectedPeers.length + 1;
            final friend = ConnectedFriend(endpointId: id, name: 'Friend $seat', assignedSeat: seat);
            connectedPeers.add(friend);
            notifyListeners();

            // Send seat assignment to connected friend
            sendMessageToPeer(
              friend,
              NetworkMessage(type: MessageType.seatAssignment, payload: {'seatIndex': seat}),
            );
          }
        },
        onDisconnected: (String id) {
          connectedPeers.removeWhere((p) => p.endpointId == id);
          notifyListeners();
        },
      );
      return true;
    } catch (e) {
      debugPrint("Host start error: $e");
      return false;
    }
  }

  // --- CLIENT ROLE ---
  Future<bool> startDiscovery({String userName = 'Player'}) async {
    try {
      isHost = false;
      discoveredHosts.clear();
      isDiscovering = true;
      notifyListeners();

      await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (String id, String name, String serviceId) {
          discoveredHosts[id] = name;
          notifyListeners();
        },
        onEndpointLost: (String? id) {
          if (id != null) {
            discoveredHosts.remove(id);
            notifyListeners();
          }
        },
      );
      return true;
    } catch (e) {
      debugPrint("Discovery error: $e");
      return false;
    }
  }

  Future<void> connectToHost(String endpointId, String userName) async {
    try {
      await Nearby().requestConnection(
        userName,
        endpointId,
        onConnectionInitiated: (id, info) {
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endid, payload) => _handleIncomingPayload(endid, payload),
          );
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            isConnected = true;
            notifyListeners();
          }
        },
        onDisconnected: (id) {
          isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint("Connect error: $e");
    }
  }

  void _handleIncomingPayload(String endid, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes != null) {
      final text = utf8.decode(payload.bytes!);
      try {
        final json = jsonDecode(text) as Map<String, dynamic>;
        final message = NetworkMessage.fromJson(json);

        if (message.type == MessageType.seatAssignment) {
          localSeatIndex = message.payload['seatIndex'] as int;
          notifyListeners();
        }

        final senderPeer = connectedPeers.firstWhere(
          (p) => p.endpointId == endid,
          orElse: () => ConnectedFriend(endpointId: endid, name: 'Peer', assignedSeat: 0),
        );
        onMessageReceived?.call(message, senderPeer.assignedSeat);
      } catch (e) {
        debugPrint("Error parsing incoming message: $e");
      }
    }
  }

  void broadcastMessage(NetworkMessage message) {
    final raw = Uint8List.fromList(utf8.encode(jsonEncode(message.toJson())));
    for (final peer in connectedPeers) {
      Nearby().sendBytesPayload(peer.endpointId, raw);
    }
  }

  void sendMessageToPeer(ConnectedFriend peer, NetworkMessage message) {
    final raw = Uint8List.fromList(utf8.encode(jsonEncode(message.toJson())));
    Nearby().sendBytesPayload(peer.endpointId, raw);
  }

  void disposeBluetooth() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
    connectedPeers.clear();
    discoveredHosts.clear();
  }
}
