import 'package:flutter/material.dart';

class BiddingDialog extends StatefulWidget {
  final int currentHighestBid;
  final ValueChanged<int?> onBidSubmitted; // null represents Pass

  const BiddingDialog({
    super.key,
    required this.currentHighestBid,
    required this.onBidSubmitted,
  });

  @override
  State<BiddingDialog> createState() => _BiddingDialogState();
}

class _BiddingDialogState extends State<BiddingDialog> {
  late int _selectedBid;

  @override
  void initState() {
    super.initState();
    _selectedBid = widget.currentHighestBid < 16 ? 16 : widget.currentHighestBid + 1;
  }

  @override
  Widget build(BuildContext context) {
    final int minPossibleBid = widget.currentHighestBid < 16 ? 16 : widget.currentHighestBid + 1;
    final bool canBidHigher = minPossibleBid <= 28;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E293B),
      title: const Row(
        children: [
          Icon(Icons.gavel, color: Colors.amber),
          SizedBox(width: 8),
          Text('Auction Bid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.currentHighestBid < 16
                ? 'No bids yet. Minimum opening bid is 16.'
                : 'Current highest bid: ${widget.currentHighestBid}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (canBidHigher) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.amber),
                    onPressed: _selectedBid > minPossibleBid
                        ? () => setState(() => _selectedBid--)
                        : null,
                  ),
                  Text(
                    '$_selectedBid',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
                    onPressed: _selectedBid < 28
                        ? () => setState(() => _selectedBid++)
                        : null,
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Maximum bid of 28 reached!',
              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onBidSubmitted(null); // Pass
          },
          child: const Text('PASS', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
        ),
        if (canBidHigher)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onBidSubmitted(_selectedBid);
            },
            child: Text('BID $_selectedBid', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
