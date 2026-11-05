import 'package:flutter/material.dart';
import '../../models/card.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard? card; // null = face down
  final bool isSelected;
  final bool isPlayable;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    this.card,
    this.isSelected = false,
    this.isPlayable = true,
    this.width = 68,
    this.height = 98,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFaceDown = card == null;

    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: width,
        height: height,
        margin: EdgeInsets.only(bottom: isSelected ? 16 : 0),
        decoration: BoxDecoration(
          color: isFaceDown ? const Color(0xFF1E3A8A) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : (isFaceDown ? const Color(0xFFD97706) : const Color(0xFFCBD5E1)),
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFF59E0B).withOpacity(0.55)
                  : Colors.black.withOpacity(0.35),
              blurRadius: isSelected ? 10 : 5,
              offset: Offset(0, isSelected ? -4 : 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: isFaceDown ? _buildRealCardBack() : _buildRealCardFront(),
        ),
      ),
    );
  }

  /// Authentic Bicycle-style Ornate Card Back
  Widget _buildRealCardBack() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [Color(0xFF1E40AF), Color(0xFF0F172A)],
        ),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.8), width: 1.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Intricate Lattice / Filigree simulation
            CustomPaint(
              size: Size(width, height),
              painter: _CardBackPatternPainter(),
            ),
            // Center Medallion
            Container(
              width: width * 0.48,
              height: width * 0.48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F172A),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
                ],
              ),
              child: const Center(
                child: Text(
                  '29',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Authentic Real Playing Card Front
  Widget _buildRealCardFront() {
    final isRed = card!.suit.isRed;
    final primaryColor = isRed ? const Color(0xFFB91C1C) : const Color(0xFF0F172A);

    return Opacity(
      opacity: isPlayable ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Stack(
          children: [
            // Top-Left Index (Rank + Suit)
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card!.rank.label,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    card!.suit.symbol,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom-Right Inverted Index
            Align(
              alignment: Alignment.bottomRight,
              child: RotatedBox(
                quarterTurns: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card!.rank.label,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      card!.suit.symbol,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center Illustration / Pip Arrangement
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Center(
                  child: _buildCardCenterBody(primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Center layout based on card rank (Court Cards vs Ace vs Numbers)
  Widget _buildCardCenterBody(Color color) {
    final rank = card!.rank;
    final suit = card!.suit;

    if (rank == Rank.jack || rank == Rank.queen || rank == Rank.king) {
      return _buildCourtCardPortrait(rank, suit, color);
    } else if (rank == Rank.ace) {
      return _buildAceCenter(suit, color);
    } else {
      return _buildNumberedPips(rank, suit, color);
    }
  }

  /// Authentic Court / Face Card Artwork Box
  Widget _buildCourtCardPortrait(Rank rank, Suit suit, Color color) {
    IconData courtIcon;
    String title;
    if (rank == Rank.jack) {
      courtIcon = Icons.shield;
      title = 'JACK';
    } else if (rank == Rank.queen) {
      courtIcon = Icons.auto_awesome;
      title = 'QUEEN';
    } else {
      courtIcon = Icons.military_tech;
      title = 'KING';
    }

    return Container(
      width: width * 0.55,
      height: height * 0.65,
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: const Color(0xFFD97706), width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(courtIcon, size: 20, color: const Color(0xFFD97706)),
          Text(
            suit.symbol,
            style: TextStyle(color: color, fontSize: 16, height: 1.1),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: Color(0xFF78350F),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Large Ornate Ace Center
  Widget _buildAceCenter(Suit suit, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          suit.symbol,
          style: TextStyle(
            color: color,
            fontSize: width * 0.42,
            height: 1.0,
            shadows: [
              Shadow(
                color: color.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Symmetric Realistic Pip arrangements for 7, 8, 9, 10
  Widget _buildNumberedPips(Rank rank, Suit suit, Color color) {
    int pipCount;
    switch (rank) {
      case Rank.seven: pipCount = 7; break;
      case Rank.eight: pipCount = 8; break;
      case Rank.nine: pipCount = 9; break;
      case Rank.ten: pipCount = 10; break;
      default: pipCount = 4;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(suit.symbol, style: TextStyle(color: color, fontSize: 12)),
            Text(suit.symbol, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
        if (pipCount >= 7)
          Text(suit.symbol, style: TextStyle(color: color, fontSize: 12)),
        if (pipCount >= 9)
          Text(suit.symbol, style: TextStyle(color: color, fontSize: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(suit.symbol, style: TextStyle(color: color, fontSize: 12)),
            Text(suit.symbol, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

/// Custom Painter for the intricate card back geometric pattern
class _CardBackPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF59E0B).withOpacity(0.18)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const step = 8.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(size.width, size.height - x), paint);
      canvas.drawLine(Offset(0, x), Offset(size.width - x, size.height), paint);
      canvas.drawLine(Offset(size.width - x, 0), Offset(0, size.height - x), paint);
      canvas.drawLine(Offset(size.width, x), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
