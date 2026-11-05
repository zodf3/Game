import 'package:flutter/material.dart';
import '../../engine/game_controller.dart';
import '../../engine/rules.dart';
import '../../models/card.dart';
import '../../models/player.dart';
import '../../models/game_state.dart';
import 'widgets/card_widget.dart';
import 'widgets/bidding_dialog.dart';
import 'widgets/trump_selection_dialog.dart';
import 'widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  PlayingCard? _selectedCard;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChanged);
    widget.controller.onNeedUserBid = _showBiddingDialog;
    widget.controller.onNeedUserTrump = _showTrumpSelectionDialog;

    // Start round automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.state.phase == GamePhase.lobby) {
        widget.controller.startNewRound();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _showBiddingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BiddingDialog(
        currentHighestBid: widget.controller.state.highestBid,
        onBidSubmitted: (bid) {
          widget.controller.submitBid(playerIndex: 0, bid: bid);
        },
      ),
    );
  }

  void _showTrumpSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TrumpSelectionDialog(
        initialHand: widget.controller.localPlayer.hand,
        onSelected: ({required suit, required isReverseGame, required trumpCard}) {
          widget.controller.selectTrump(
            playerIndex: 0,
            suit: suit,
            isReverseGame: isReverseGame,
            trumpCard: trumpCard,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final players = widget.controller.players;
    final localPlayer = widget.controller.localPlayer;
    final isMyTurn = state.phase == GamePhase.trickPlay && state.currentTurn == 0;

    final validCards = isMyTurn
        ? GameRules.getValidCards(player: localPlayer, state: state)
        : <PlayingCard>[];

    final canRevealTrump = !state.isTrumpRevealed &&
        state.trumpSuit != null &&
        isMyTurn &&
        state.currentTrick.isNotEmpty &&
        localPlayer.hand.every((c) => c.suit != state.currentTrick.first.card.suit);

    final canClaimPair = state.isTrumpRevealed &&
        !localPlayer.declaredPair &&
        GameRules.hasPair(localPlayer, state.trumpSuit);

    return Scaffold(
      backgroundColor: const Color(0xFF064E3B), // Classic Green Card Felt
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Scoreboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ScoreBoardWidget(state: state, players: players),
            ),

            // North Player (Partner)
            _buildOpponentInfo(players[2], Alignment.topCenter),

            // Middle Section: Left Player, Trick Felt, Right Player
            Expanded(
              child: Row(
                children: [
                  // West Player
                  SizedBox(
                    width: 70,
                    child: _buildOpponentInfo(players[3], Alignment.centerLeft),
                  ),

                  // Center Playing Felt
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.shade700.withOpacity(0.4), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Watermark / Table Info
                            Opacity(
                              opacity: 0.15,
                              child: Text(
                                state.isReverseGame ? 'REVERSE 29\n(7 > 8 > Q > K > 10 > A > 9 > J)' : '29 CARD GAME',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Played cards in current trick
                            ...state.currentTrick.map((played) {
                              return _buildPlayedCard(played);
                            }),

                            // Hidden / Revealed Trump Card Slot
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildTrumpSlot(state),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // East Player
                  SizedBox(
                    width: 70,
                    child: _buildOpponentInfo(players[1], Alignment.centerRight),
                  ),
                ],
              ),
            ),

            // Action Bar (Reveal Trump, Claim Pair)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (canRevealTrump)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.visibility),
                      label: const Text('SHOW TRUMP', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => widget.controller.revealTrump(playerIndex: 0),
                    ),
                  if (canClaimPair) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade700,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.favorite),
                      label: const Text('CLAIM PAIR (+4)', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => widget.controller.claimPair(playerIndex: 0),
                    ),
                  ],
                ],
              ),
            ),

            // Turn Indicator
            Text(
              isMyTurn
                  ? 'Your Turn! Select a card to play'
                  : 'Waiting for ${players[state.currentTurn].name}...',
              style: TextStyle(
                color: isMyTurn ? Colors.amberAccent : Colors.white70,
                fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),

            // Bottom Section: South Player (You) Hand
            Container(
              height: 110,
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: localPlayer.hand.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (ctx, index) {
                    final card = localPlayer.hand[index];
                    final isPlayable = isMyTurn && validCards.contains(card);

                    return CardWidget(
                      card: card,
                      isPlayable: isPlayable,
                      isSelected: _selectedCard == card,
                      onTap: () {
                        if (isPlayable) {
                          widget.controller.playCard(playerIndex: 0, card: card);
                          setState(() => _selectedCard = null);
                        }
                      },
                    );
                  },
                ),
              ),
            ),

            // Round End Overlay
            if (state.phase == GamePhase.roundOver || state.phase == GamePhase.gameOver)
              _buildRoundOverBanner(state),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentInfo(Player player, Alignment alignment) {
    final isTurn = widget.controller.state.currentTurn == player.id;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTurn ? Colors.amber.withOpacity(0.3) : Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isTurn ? Colors.amber : Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            player.isBot ? Icons.smart_toy : Icons.person,
            color: isTurn ? Colors.amber : Colors.white70,
            size: 20,
          ),
          Text(
            player.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isTurn ? Colors.amber : Colors.white,
              fontSize: 11,
              fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${player.hand.length} cards',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayedCard(PlayedCard played) {
    // Position cards based on player: 0 = bottom, 1 = right, 2 = top, 3 = left
    Alignment alignment;
    switch (played.playerIndex) {
      case 0:
        alignment = const Alignment(0, 0.45);
        break;
      case 1:
        alignment = const Alignment(0.45, 0);
        break;
      case 2:
        alignment = const Alignment(0, -0.45);
        break;
      case 3:
      default:
        alignment = const Alignment(-0.45, 0);
        break;
    }

    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardWidget(card: played.card, width: 56, height: 80),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.controller.players[played.playerIndex].name.split(' ').first,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrumpSlot(GameRoundState state) {
    if (state.trumpSuit == null) return const SizedBox.shrink();

    return Column(
      children: [
        const Text('Trump', style: TextStyle(color: Colors.white70, fontSize: 10)),
        if (state.isTrumpRevealed)
          CardWidget(card: state.hiddenTrumpCard, width: 42, height: 60)
        else
          const CardWidget(card: null, width: 42, height: 60), // Face down
      ],
    );
  }

  Widget _buildRoundOverBanner(GameRoundState state) {
    final bidderTeam = widget.controller.players[state.highestBidderIndex!].team;
    final totalPoints = bidderTeam == 0
        ? state.team0Points + state.pairBonusTeam0
        : state.team1Points + state.pairBonusTeam1;
    final bool won = totalPoints >= state.highestBid;

    return Container(
      width: double.infinity,
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                won ? 'Round Won! Points: $totalPoints / ${state.highestBid}' : 'Round Lost! Points: $totalPoints / ${state.highestBid}',
                style: TextStyle(
                  color: won ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (state.isReverseGame)
                const Text(
                  'Played in REVERSE Game Mode (7 > J)',
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 12),
                ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () => widget.controller.startNewRound(),
            child: const Text('NEXT ROUND', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
