import 'package:flutter/material.dart';
import '../../engine/game_controller.dart';
import '../../network/bluetooth_service.dart';
import 'game_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final BluetoothManager _bluetooth = BluetoothManager();
  bool _isHosting = false;

  @override
  void dispose() {
    _bluetooth.disposeBluetooth();
    super.dispose();
  }

  void _startSoloGame() {
    final controller = GameController();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(controller: controller),
      ),
    );
  }

  void _showRulesExplainer() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Colors.amber),
            SizedBox(width: 8),
            Text('29 Game & Reverse Rules', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '★ Standard 29 Rules:',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                '• Rank Order: Jack (highest) > 9 > Ace > 10 > King > Queen > 8 > 7 (lowest)\n'
                '• Points: Jack = 3, 9 = 2, Ace = 1, 10 = 1, K/Q/8/7 = 0\n'
                '• Deck: 32 cards (4 suits × 8 cards). Total points = 28 + 1 (last trick) = 29.\n'
                '• Bidding from 16 to 28. Winner sets hidden trump.\n'
                '• Trump Reveal: If unable to follow suit, player can reveal trump to cut.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 14),
              Text(
                '★ REVERSE GAME (Ulta 29) Rules:',
                style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                '• Chosen by winning bidder during Trump Selection.\n'
                '• Rank Order INVERTS: 7 (highest) > 8 > Queen > King > 10 > Ace > 9 > Jack (weakest!)\n'
                '• 7 of Trump beats every other card in the game!\n'
                '• Card points remain STANDARD (Jack=3, 9=2, Ace=1, 10=1, 7/8/K/Q=0).\n'
                '• High-stakes strategy: 7s and 8s win tricks effortlessly but give 0 points, while Jacks and 9s are heavy point cards that lose to everything!',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('GOT IT', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('29 Card Game - Reverse & Bluetooth', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF064E3B),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.amber),
            tooltip: 'Rules & Reverse Info',
            onPressed: _showRulesExplainer,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mode Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.style, color: Colors.amber, size: 40),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'South Asian 29 + Ulta Mode',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Play Solo with AI Bots or connect with friends via Bluetooth! Unfilled seats are automatically filled with intelligent bots.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Solo Play
            _buildActionCard(
              icon: Icons.smart_toy,
              iconColor: Colors.tealAccent,
              title: 'Solo Play (with Bots)',
              subtitle: 'Jump into a quick offline game with 3 smart AI bots. Try Standard and Reverse games.',
              onTap: _startSoloGame,
            ),
            const SizedBox(height: 14),

            // Option 2: Bluetooth Host Table
            _buildActionCard(
              icon: Icons.bluetooth_audio,
              iconColor: Colors.blueAccent,
              title: 'Host Bluetooth Table',
              subtitle: 'Create a local table for nearby friends to join. Any open seats are filled by bots.',
              onTap: () {
                setState(() => _isHosting = true);
                _bluetooth.startHostServer();
                _showHostDialog();
              },
            ),
            const SizedBox(height: 14),

            // Option 3: Bluetooth Join Table
            _buildActionCard(
              icon: Icons.bluetooth_searching,
              iconColor: Colors.indigoAccent,
              title: 'Join Bluetooth Table',
              subtitle: 'Scan for a friend hosting a 29 table nearby and connect.',
              onTap: _showJoinDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  void _showHostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: _bluetooth,
          builder: (context, _) {
            final peerCount = _bluetooth.connectedPeers.length;
            final botCount = 3 - peerCount;

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('Hosting Bluetooth Table', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seat 0 (Host): You (South)', style: TextStyle(color: Colors.amber)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < 3; i++)
                    Text(
                      i < peerCount
                          ? 'Seat ${i + 1}: ${_bluetooth.connectedPeers[i].device.name ?? "Friend"} (Connected)'
                          : 'Seat ${i + 1}: Bot (Will play if no friend connects)',
                      style: TextStyle(
                        color: i < peerCount ? Colors.greenAccent : Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Connected Friends: $peerCount | AI Bots: $botCount',
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _bluetooth.disposeBluetooth();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('CANCEL', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final controller = GameController();
                    // Connect peer seats to controller
                    for (int i = 0; i < peerCount; i++) {
                      controller.players[i + 1].name = _bluetooth.connectedPeers[i].device.name ?? 'Friend ${i + 1}';
                      controller.players[i + 1].isBot = false;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(controller: controller),
                      ),
                    );
                  },
                  child: const Text('START GAME WITH BOTS & FRIENDS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showJoinDialog() {
    _bluetooth.refreshPairedDevices();
    showDialog(
      context: context,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: _bluetooth,
          builder: (context, _) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('Connect to Host via Bluetooth', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select your friend\'s paired device to join their 29 table:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    if (_bluetooth.pairedDevices.isEmpty)
                      const Text(
                        'No paired Bluetooth devices found.\nPlease pair with your friend in Android Bluetooth Settings first.',
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        textAlign: TextAlign.center,
                      )
                    else
                      ..._bluetooth.pairedDevices.map((d) {
                        return ListTile(
                          leading: const Icon(Icons.bluetooth, color: Colors.blueAccent),
                          title: Text(d.name ?? 'Unknown Device', style: const TextStyle(color: Colors.white)),
                          subtitle: Text(d.address, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          onTap: () async {
                            final success = await _bluetooth.connectToHost(d);
                            if (success && mounted) {
                              Navigator.of(ctx).pop();
                              final controller = GameController();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GameScreen(controller: controller),
                                ),
                              );
                            }
                          },
                        );
                      }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('CLOSE', style: TextStyle(color: Colors.amber)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
