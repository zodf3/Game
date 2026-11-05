import 'package:flutter/material.dart';
import '../../models/card.dart';

typedef OnTrumpSelected = void Function({
  required Suit suit,
  required bool isReverseGame,
  required PlayingCard trumpCard,
});

class TrumpSelectionDialog extends StatefulWidget {
  final List<PlayingCard> initialHand;
  final OnTrumpSelected onSelected;

  const TrumpSelectionDialog({
    super.key,
    required this.initialHand,
    required this.onSelected,
  });

  @override
  State<TrumpSelectionDialog> createState() => _TrumpSelectionDialogState();
}

class _TrumpSelectionDialogState extends State<TrumpSelectionDialog> {
  Suit _selectedSuit = Suit.hearts;
  bool _isReverseGame = false;
  late PlayingCard _selectedCard;

  @override
  void initState() {
    super.initState();
    _selectedCard = widget.initialHand.first;
    _selectedSuit = _selectedCard.suit;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E293B),
      title: const Text(
        'Set Trump & Mode',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Choose Trump Suit:',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Suit.values.map((suit) {
                final isSelected = suit == _selectedSuit;
                final color = suit.isRed ? Colors.redAccent : Colors.white;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSuit = suit;
                      // Update selected card to match suit if available
                      final match = widget.initialHand.where((c) => c.suit == suit).toList();
                      if (match.isNotEmpty) {
                        _selectedCard = match.first;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber.withOpacity(0.25) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(suit.symbol, style: TextStyle(color: color, fontSize: 24)),
                        Text(
                          suit.label,
                          style: TextStyle(
                            color: isSelected ? Colors.amber : Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // REVERSE GAME (ULTA 29) TOGGLE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isReverseGame ? Colors.purple.shade900.withOpacity(0.4) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isReverseGame ? Colors.purpleAccent : Colors.white24,
                  width: _isReverseGame ? 1.8 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.swap_vert, color: Colors.purpleAccent),
                          SizedBox(width: 8),
                          Text(
                            'Reverse Game (Ulta 29)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isReverseGame,
                        activeColor: Colors.purpleAccent,
                        onChanged: (val) => setState(() => _isReverseGame = val),
                      ),
                    ],
                  ),
                  Text(
                    _isReverseGame
                        ? '★ REVERSE ACTIVE: Card ranks are inverted! 7 is highest (beats everything), then 8, Q, K, 10, A, 9, Jack is lowest! Card points remain standard (Jack=3, 9=2, Ace=1, 10=1).'
                        : 'Standard 29: Jack is highest (beats everything), then 9, Ace, 10, King, Queen, 8, 7.',
                    style: TextStyle(
                      color: _isReverseGame ? Colors.purple.shade200 : Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              '2. Select card from hand to place face down:',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.initialHand.map((card) {
                final isCardSelected = card == _selectedCard;
                final color = card.suit.isRed ? Colors.redAccent : Colors.white;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCard = card;
                      _selectedSuit = card.suit;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCardSelected ? Colors.amber.withOpacity(0.3) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCardSelected ? Colors.amber : Colors.white24,
                        width: isCardSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '${card.rank.label} ${card.suit.symbol}',
                      style: TextStyle(
                        color: color,
                        fontWeight: isCardSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isReverseGame ? Colors.purpleAccent : Colors.amber.shade600,
            foregroundColor: _isReverseGame ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSelected(
              suit: _selectedSuit,
              isReverseGame: _isReverseGame,
              trumpCard: _selectedCard,
            );
          },
          child: Text(
            _isReverseGame ? 'SET REVERSE TRUMP' : 'SET TRUMP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
