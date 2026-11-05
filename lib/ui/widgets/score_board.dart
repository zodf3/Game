import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';

class ScoreBoardWidget extends StatelessWidget {
  final GameRoundState state;
  final List<Player> players;

  const ScoreBoardWidget({
    super.key,
    required this.state,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final team0Name = '${players[0].name.split(' ').first} & ${players[2].name}';
    final team1Name = '${players[1].name} & ${players[3].name}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Team 0 Score (User + dada)
          _buildTeamScore(
            label: team0Name,
            cardPoints: state.team0Points,
            pairBonus: state.pairBonusTeam0,
            gamePips: state.team0GameScore,
            isBidder: state.highestBidderIndex == 0 || state.highestBidderIndex == 2,
            target: state.highestBidderIndex == 0 || state.highestBidderIndex == 2 ? state.highestBid : null,
          ),

          // Center Trump & Mode Indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.isReverseGame)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade900,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purpleAccent, width: 1),
                  ),
                  child: const Text(
                    '★ REVERSE (7 > J)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Trump: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  if (state.isTrumpRevealed && state.trumpSuit != null)
                    Text(
                      '${state.trumpSuit!.symbol} ${state.trumpSuit!.label}',
                      style: TextStyle(
                        color: state.trumpSuit!.isRed ? Colors.redAccent : const Color(0xFFF59E0B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (state.trumpSuit != null)
                    const Text('Hidden [?] ', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13))
                  else
                    const Text('Not Set', style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
              Text(
                'Trick: ${state.trickNumber} / 8',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),

          // Team 1 Score (vut + kukur)
          _buildTeamScore(
            label: team1Name,
            cardPoints: state.team1Points,
            pairBonus: state.pairBonusTeam1,
            gamePips: state.team1GameScore,
            isBidder: state.highestBidderIndex == 1 || state.highestBidderIndex == 3,
            target: state.highestBidderIndex == 1 || state.highestBidderIndex == 3 ? state.highestBid : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore({
    required String label,
    required int cardPoints,
    required int pairBonus,
    required int gamePips,
    required bool isBidder,
    required int? target,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            if (isBidder) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Bid: $target', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Pts: ${cardPoints + pairBonus}',
          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          'Pips: ${gamePips >= 0 ? "+$gamePips" : "$gamePips"}',
          style: TextStyle(
            color: gamePips >= 0 ? Colors.greenAccent : Colors.redAccent,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
