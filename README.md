# 29 Card Game (with Reverse Game, Bots & Bluetooth Multiplayer)

An authentic South Asian **29 Card Game** featuring an innovative **Reverse Game (Ulta 29)** mode, intelligent **AI Bots** for solo play, and **Bluetooth Local Multiplayer** to play with nearby friends.

---

## 🌟 Key Features

1. **Authentic 29 Gameplay & Rules**:
   - 32-card deck (4 suits × 8 cards: J, 9, A, 10, K, Q, 8, 7).
   - Point system: **Jack = 3**, **9 = 2**, **Ace = 1**, **10 = 1**, others = 0.
   - Trick-taking with 4 players (Team 0: South + North vs Team 1: East + West).
   - Bidding phase (16 to 28), hidden trump placement, trump reveal mechanism, and Pair (Marriage) bonus (+4 pts).
   - Red & Black game points (pips) scoring.

2. **Reverse Game (Ulta 29 Mode)**:
   - When a player wins the bidding auction, they can choose to play in **Reverse Mode**.
   - **Inverted Card Ranks**:
     $$\mathbf{7 > 8 > Q > K > 10 > A > 9 > J}$$
     - **7 is the supreme card** in each suit (beats everything)!
     - **Jack is the weakest card**!
     - 7 of Trump is unbeatable.
   - **Card Points Remain Standard**:
     - Jack is still worth 3 points, 9 is 2 points, Ace is 1 point, 10 is 1 point.
     - 7s and 8s are worth 0 points.
   - **Tactical Dynamic**: 7s and 8s easily win tricks but yield zero points, whereas Jacks and 9s carry heavy points but lose to virtually any card.

3. **Solo Play with AI Bots**:
   - Play offline anytime against 3 smart AI bots (Partner North, Opponents East and West).
   - Bots evaluate hands for both Standard and Reverse mode bidding.
   - Strategic trump reveal and card throwing heuristics (feeding points to partner, cutting tricks with trump, saving top cards).

4. **Bluetooth Local Multiplayer**:
   - Host a table without internet connection using Android Bluetooth.
   - Up to 3 friends can connect directly.
   - **Auto-Fill AI Bots**: Any unfilled seats (e.g. if only 2 friends play) are automatically filled by AI Bots so you can always play 4-player 29!

---

## 🚀 Instant Playable Browser Version

You can play immediately without installing any SDKs:
1. Navigate to:
   ```
   twenty_nine_card_game/play_twenty_nine.html
   ```
2. Double-click to open in **Google Chrome**, **Microsoft Edge**, or any modern browser.
3. Enjoy a full 4-player game against 3 bots with bidding, Reverse mode selection, trump reveal, and pair declarations!

---

## 📁 Codebase Structure

```
twenty_nine_card_game/
├── play_twenty_nine.html          # Standalone playable browser game & simulator
├── pubspec.yaml                   # Flutter dependencies & app configuration
├── README.md                      # Documentation & guides
├── test_rules.py                  # Python rule validation & test suite
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml    # Bluetooth permissions (legacy + Android 12+)
└── lib/
    ├── main.dart                  # Flutter entry point & theme setup
    ├── models/
    │   ├── card.dart              # Suits, Ranks, Points, Standard & Reverse power
    │   ├── player.dart            # Player positions, hands, teams
    │   └── game_state.dart        # Game phases, tricks, round scores, pips
    ├── engine/
    │   ├── rules.dart             # Move validation, trick resolution, pair rules
    │   ├── bot_ai.dart            # Hand evaluation, bidding, trump selection, card play
    │   └── game_controller.dart   # Authoritative game coordinator & state machine
    ├── network/
    │   ├── protocol.dart          # JSON message serialization for Bluetooth
    │   └── bluetooth_service.dart # RFCOMM socket host/client & device discovery
    └── ui/
        ├── lobby_screen.dart      # Solo, Bluetooth Host & Join navigation
        ├── game_screen.dart       # 4-player card table with felt animations
        └── widgets/
            ├── card_widget.dart           # Realistic playing card UI & backs
            ├── bidding_dialog.dart        # 16-28 interactive auction modal
            ├── trump_selection_dialog.dart# Trump suit & Reverse Game toggle
            └── score_board.dart           # Pts, targets, pips & game mode banner
```

---

## 📱 How to Run Flutter App on Android

### Prerequisites
1. **Flutter SDK** (Version 3.0+): [flutter.dev](https://flutter.dev)
2. **Android Studio** or Android SDK with platform-tools.
3. Physical Android devices (for testing real Bluetooth Classic RFCOMM communication).

### Steps
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Connect your Android device via USB (with USB Debugging enabled).
3. Run the app:
   ```bash
   flutter run
   ```

### Bluetooth Connection Steps
1. Pair both Android phones in **Android Settings > Bluetooth**.
2. Open the app on Phone 1, choose **"Host Bluetooth Table"**.
3. Open the app on Phone 2, choose **"Join Bluetooth Table"**, and select Phone 1.
4. Phone 1 starts the game — any vacant player slots will be taken by AI bots!
