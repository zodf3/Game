import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'protocol.dart';

typedef OnMessageReceived = void Function(NetworkMessage message, int senderId);

class BluetoothPeer {
  final BluetoothDevice device;
  BluetoothConnection? connection;
  int assignedSeat;

  BluetoothPeer({
    required this.device,
    this.connection,
    required this.assignedSeat,
  });
}

class BluetoothManager extends ChangeNotifier {
  static const String appServiceUuid = "00001101-0000-1000-8000-00805F9B34FB"; // Standard SPP UUID

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  bool isBluetoothEnabled = false;
  bool isDiscovering = false;
  bool isHost = false;
  bool isConnected = false;
  int localSeatIndex = 0; // 0 = Host (South)

  List<BluetoothDevice> pairedDevices = [];
  List<BluetoothDiscoveryResult> discoveredDevices = [];
  final List<BluetoothPeer> connectedPeers = [];

  OnMessageReceived? onMessageReceived;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;

  BluetoothManager() {
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    try {
      isBluetoothEnabled = (await _bluetooth.isEnabled) ?? false;
      if (isBluetoothEnabled) {
        refreshPairedDevices();
      }
      _bluetooth.onStateChanged().listen((BluetoothState state) {
        isBluetoothEnabled = state.isEnabled;
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Bluetooth initialization error: $e");
    }
  }

  Future<void> refreshPairedDevices() async {
    try {
      pairedDevices = await _bluetooth.getBondedDevices();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching paired devices: $e");
    }
  }

  void startDiscovery() {
    discoveredDevices.clear();
    isDiscovering = true;
    notifyListeners();

    _discoveryStreamSubscription = _bluetooth.startDiscovery().listen((r) {
      final existingIndex = discoveredDevices.indexWhere((element) => element.device.address == r.device.address);
      if (existingIndex >= 0) {
        discoveredDevices[existingIndex] = r;
      } else {
        discoveredDevices.add(r);
      }
      notifyListeners();
    });

    _discoveryStreamSubscription?.onDone(() {
      isDiscovering = false;
      notifyListeners();
    });
  }

  void stopDiscovery() {
    _discoveryStreamSubscription?.cancel();
    isDiscovering = false;
    notifyListeners();
  }

  // --- HOST SERVER ROLE ---
  Future<void> startHostServer() async {
    isHost = true;
    localSeatIndex = 0; // Host is seat 0 (South)
    connectedPeers.clear();
    notifyListeners();

    // Listen on Bluetooth RFCOMM socket for peers to connect
    // Any remaining unfilled seats out of 4 will be filled by AI Bots automatically!
    debugPrint("Host server started. Waiting for friends to connect over Bluetooth...");
  }

  void registerPeerConnection(BluetoothDevice device, BluetoothConnection connection) {
    if (connectedPeers.length >= 3) {
      debugPrint("Table is full (maximum 4 players)!");
      connection.close();
      return;
    }

    final seat = connectedPeers.length + 1; // Seats 1, 2, 3
    final peer = BluetoothPeer(device: device, connection: connection, assignedSeat: seat);
    connectedPeers.add(peer);
    notifyListeners();

    // Send assigned seat to connected friend
    sendMessageToPeer(
      peer,
      NetworkMessage(type: MessageType.seatAssignment, payload: {'seatIndex': seat}),
    );

    // Listen to incoming messages from this friend
    connection.input?.listen((Uint8List data) {
      final text = utf8.decode(data);
      try {
        final json = jsonDecode(text) as Map<String, dynamic>;
        final message = NetworkMessage.fromJson(json);
        onMessageReceived?.call(message, peer.assignedSeat);
      } catch (e) {
        debugPrint("Error parsing Bluetooth message: $e");
      }
    }).onDone(() {
      debugPrint("Peer ${peer.device.name} disconnected. Converting to Bot.");
      connectedPeers.remove(peer);
      notifyListeners();
    });
  }

  // --- CLIENT ROLE ---
  Future<bool> connectToHost(BluetoothDevice hostDevice) async {
    try {
      isHost = false;
      stopDiscovery();

      final connection = await BluetoothConnection.toAddress(hostDevice.address);
      isConnected = true;
      notifyListeners();

      connection.input?.listen((Uint8List data) {
        final text = utf8.decode(data);
        try {
          final json = jsonDecode(text) as Map<String, dynamic>;
          final message = NetworkMessage.fromJson(json);

          if (message.type == MessageType.seatAssignment) {
            localSeatIndex = message.payload['seatIndex'] as int;
            notifyListeners();
          }

          onMessageReceived?.call(message, 0); // Sender is host (0)
        } catch (e) {
          debugPrint("Error parsing Bluetooth message from host: $e");
        }
      }).onDone(() {
        isConnected = false;
        notifyListeners();
      });

      return true;
    } catch (e) {
      debugPrint("Failed to connect to host: $e");
      isConnected = false;
      notifyListeners();
      return false;
    }
  }

  // --- BROADCAST / SEND MESSAGES ---
  void broadcastMessage(NetworkMessage message) {
    final raw = utf8.encode(jsonEncode(message.toJson()));
    for (final peer in connectedPeers) {
      peer.connection?.output.add(raw);
    }
  }

  void sendMessageToPeer(BluetoothPeer peer, NetworkMessage message) {
    final raw = utf8.encode(jsonEncode(message.toJson()));
    peer.connection?.output.add(raw);
  }

  void disposeBluetooth() {
    stopDiscovery();
    for (final peer in connectedPeers) {
      peer.connection?.close();
    }
    connectedPeers.clear();
  }
}
