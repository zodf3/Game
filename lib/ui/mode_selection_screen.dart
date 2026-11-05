import 'package:flutter/material.dart';
import '../../engine/game_controller.dart';
import '../../network/bluetooth_service.dart';
import 'game_screen.dart';
import 'profile_setup_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  final String userName;

  const ModeSelectionScreen({super.key, required this.userName});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  final BluetoothManager _bluetooth = BluetoothManager();

  @override
  void dispose() {
    _bluetooth.disposeBluetooth();
    super.dispose();
  }

  void _startSoloGame() {
    final controller = GameController(userName: widget.userName);
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
            Icon(Icons.menu_book, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('29 Game & Reverse Rules', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '★ Standard 29 Game:',
                style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                '• Rank: Jack (highest) > 9 > Ace > 10 > King > Queen > 8 > 7 (lowest)\n'
                '• Points: Jack = 3, 9 = 2, Ace = 1, 10 = 1, K/Q/8/7 = 0\n'
                '• Deck: 32 cards (4 suits × 8 cards). Total points = 28 + 1 (last trick) = 29.\n'
                '• Bidding from 16 to 28. Winner sets hidden trump.\n'
                '• Trump Reveal: If unable to follow suit, player can reveal trump to cut.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 14),
              Text(
                '★ REVERSE GAME (Ulta 29):',
                style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                '• Chosen by winning bidder during Trump Selection.\n'
                '• Rank Inverts: 7 (highest) > 8 > Queen > King > 10 > Ace > 9 > Jack (weakest!)\n'
                '• 7 of Trump beats every card in the game!\n'
                '• Card points remain STANDARD (Jack=3, 9=2, Ace=1, 10=1, 7=0).\n'
                '• High-stakes strategy: 7s and 8s win tricks effortlessly but give 0 points, while Jacks and 9s carry heavy points but lose to everything!',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('GOT IT', style: TextStyle(color: Color(0xFFF59E0B))),
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
        backgroundColor: const Color(0xFF064E3B),
        elevation: 0,
        title: const Text('Select Game Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
            tooltip: 'Rules Guide',
            onPressed: _showRulesExplainer,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            tooltip: 'Edit Profile Name',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Welcome Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF047857),
                      child: Text(
                        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Player: ${widget.userName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Ready for a match of 29 Card Game',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'CHOOSE HOW TO PLAY',
                style: TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // CARD 1: PLAY WITH BOTS
              _buildModeCard(
                icon: Icons.smart_toy_outlined,
                accentColor: const Color(0xFF10B981),
                badgeText: 'INSTANT OFFLINE',
                title: 'Play with Bots',
                subtitle: 'Play solo against smart AI bots. Try standard 29 or challenge the bots in Reverse (Ulta) mode.',
                botLineup: [
                  {'role': 'Partner (North)', 'name': 'dada', 'icon': Icons.sentiment_very_satisfied},
                  {'role': 'Opponent 1 (East)', 'name': 'vut', 'icon': Icons.flutter_dash},
                  {'role': 'Opponent 2 (West)', 'name': 'kukur', 'icon': Icons.pets},
                ],
                buttonText: 'START SOLO GAME',
                onButtonTap: _startSoloGame,
              ),
              const SizedBox(height: 18),

              // CARD 2: PLAY OVER BLUETOOTH WITH FRIENDS
              _buildModeCard(
                icon: Icons.bluetooth_audio,
                accentColor: const Color(0xFF3B82F6),
                badgeText: 'LOCAL MULTIPLAYER',
                title: 'Play with Friends over Bluetooth',
                subtitle: 'Connect wirelessly with friends nearby without internet. Any unfilled seats are automatically taken by bots (vut, kukur, dada).',
                customActions: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.wifi_tethering, size: 18),
                        label: const Text('HOST TABLE', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _showHostDialog,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF60A5FA),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('JOIN TABLE', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _showJoinDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required String title,
    required String subtitle,
    List<Map<String, dynamic>>? botLineup,
    String? buttonText,
    VoidCallback? onButtonTap,
    Widget? customActions,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),

          if (botLineup != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: botLineup.map((bot) {
                  return Column(
                    children: [
                      Icon(bot['icon'] as IconData, size: 18, color: accentColor),
                      const SizedBox(height: 2),
                      Text(
                        bot['name'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        bot['role'] as String,
                        style: const TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),
          if (buttonText != null && onButtonTap != null)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onButtonTap,
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
          if (customActions != null) customActions,
        ],
      ),
    );
  }

  void _showHostDialog() {
    _bluetooth.startHostServer();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: _bluetooth,
          builder: (context, _) {
            final peerCount = _bluetooth.connectedPeers.length;

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('Hosting Bluetooth Table', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seat 0 (Host): ${widget.userName}', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    peerCount >= 1
                        ? 'Seat 1: ${_bluetooth.connectedPeers[0].device.name ?? "Friend 1"} (Connected)'
                        : 'Seat 1: vut (Bot)',
                    style: TextStyle(color: peerCount >= 1 ? Colors.greenAccent : Colors.white60, fontSize: 13),
                  ),
                  Text(
                    peerCount >= 2
                        ? 'Seat 2: ${_bluetooth.connectedPeers[1].device.name ?? "Friend 2"} (Connected)'
                        : 'Seat 2: dada (Partner Bot)',
                    style: TextStyle(color: peerCount >= 2 ? Colors.greenAccent : Colors.white60, fontSize: 13),
                  ),
                  Text(
                    peerCount >= 3
                        ? 'Seat 3: ${_bluetooth.connectedPeers[2].device.name ?? "Friend 3"} (Connected)'
                        : 'Seat 3: kukur (Bot)',
                    style: TextStyle(color: peerCount >= 3 ? Colors.greenAccent : Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '★ Unfilled seats are automatically filled by bots vut, kukur, and dada!',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 11),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final controller = GameController(userName: widget.userName);
                    for (int i = 0; i < peerCount; i++) {
                      controller.players[i + 1].name = _bluetooth.connectedPeers[i].device.name ?? 'Friend ${i + 1}';
                      controller.players[i + 1].isBot = false;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => GameScreen(controller: controller)),
                    );
                  },
                  child: const Text('START GAME', style: TextStyle(fontWeight: FontWeight.bold)),
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
              title: const Text('Join Bluetooth Table', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select your friend\'s paired device to join their table:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    if (_bluetooth.pairedDevices.isEmpty)
                      const Text(
                        'No paired Bluetooth devices found.\nPlease pair your friend\'s phone in Android Settings first.',
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        textAlign: TextAlign.center,
                      )
                    else
                      ..._bluetooth.pairedDevices.map((d) {
                        return ListTile(
                          leading: const Icon(Icons.bluetooth, color: Colors.blueAccent),
                          title: Text(d.name ?? 'Device', style: const TextStyle(color: Colors.white)),
                          subtitle: Text(d.address, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          onTap: () async {
                            final success = await _bluetooth.connectToHost(d);
                            if (success && mounted) {
                              Navigator.of(ctx).pop();
                              final controller = GameController(userName: widget.userName);
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => GameScreen(controller: controller)),
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
                  child: const Text('CLOSE', style: TextStyle(color: Color(0xFFF59E0B))),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
