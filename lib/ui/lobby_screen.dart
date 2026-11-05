import 'package:flutter/material.dart';
import '../../engine/game_controller.dart';
import 'game_screen.dart';
import 'mode_selection_screen.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModeSelectionScreen(userName: 'Player 1');
  }
}
