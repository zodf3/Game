"""
Verification test for 29 Card Game logic including Reverse Game (Ulta 29)
"""
from dataclasses import dataclass
from enum import Enum
import random

class Suit(Enum):
    SPADES = "♠"
    HEARTS = "♥"
    DIAMONDS = "♦"
    CLUBS = "♣"

class Rank(Enum):
    SEVEN = "7"
    EIGHT = "8"
    NINE = "9"
    TEN = "10"
    JACK = "J"
    QUEEN = "Q"
    KING = "K"
    ACE = "A"

# Card point values (same in both Standard and Reverse!)
POINT_VALUES = {
    Rank.JACK: 3,
    Rank.NINE: 2,
    Rank.ACE: 1,
    Rank.TEN: 1,
    Rank.KING: 0,
    Rank.QUEEN: 0,
    Rank.EIGHT: 0,
    Rank.SEVEN: 0,
}

# Trick-taking strength:
# Standard: J > 9 > A > 10 > K > Q > 8 > 7
STANDARD_RANK_POWER = {
    Rank.JACK: 8,
    Rank.NINE: 7,
    Rank.ACE: 6,
    Rank.TEN: 5,
    Rank.KING: 4,
    Rank.QUEEN: 3,
    Rank.EIGHT: 2,
    Rank.SEVEN: 1,
}

# Reverse (Ulta): 7 > 8 > Q > K > 10 > A > 9 > J
REVERSE_RANK_POWER = {
    Rank.SEVEN: 8,
    Rank.EIGHT: 7,
    Rank.QUEEN: 6,
    Rank.KING: 5,
    Rank.TEN: 4,
    Rank.ACE: 3,
    Rank.NINE: 2,
    Rank.JACK: 1,
}

@dataclass(frozen=True)
class Card:
    suit: Suit
    rank: Rank

    @property
    def points(self):
        return POINT_VALUES[self.rank]

    def power(self, is_reverse: bool) -> int:
        return REVERSE_RANK_POWER[self.rank] if is_reverse else STANDARD_RANK_POWER[self.rank]

    def __str__(self):
        return f"{self.rank.value}{self.suit.value}"

def determine_trick_winner(trick: list[tuple[int, Card]], trump_suit: Suit, trump_revealed: bool, is_reverse: bool) -> int:
    """
    trick: list of (player_index, Card)
    Returns winner player_index
    """
    lead_suit = trick[0][1].suit
    best_player = trick[0][0]
    best_card = trick[0][1]

    for player, card in trick[1:]:
        # If card is trump and trump is revealed
        if trump_revealed and card.suit == trump_suit:
            if best_card.suit == trump_suit:
                if card.power(is_reverse) > best_card.power(is_reverse):
                    best_card = card
                    best_player = player
            else:
                # First trump played beats any non-trump card
                best_card = card
                best_player = player
        elif card.suit == lead_suit and best_card.suit != trump_suit:
            # Same lead suit, no trump involved yet
            if card.power(is_reverse) > best_card.power(is_reverse):
                best_card = card
                best_player = player

    return best_player

def test_reverse_game_trick():
    # Test 1: In standard, Jack beats 7
    trick_std = [
        (0, Card(Suit.SPADES, Rank.JACK)),
        (1, Card(Suit.SPADES, Rank.SEVEN)),
    ]
    assert determine_trick_winner(trick_std, Suit.HEARTS, True, False) == 0

    # Test 2: In reverse, 7 beats Jack!
    trick_rev = [
        (0, Card(Suit.SPADES, Rank.JACK)),
        (1, Card(Suit.SPADES, Rank.SEVEN)),
    ]
    assert determine_trick_winner(trick_rev, Suit.HEARTS, True, True) == 1

    # Test 3: In reverse, 7 of Trump beats Jack of Trump
    trick_trump_rev = [
        (0, Card(Suit.HEARTS, Rank.JACK)), # Trump
        (1, Card(Suit.HEARTS, Rank.SEVEN)), # Trump
    ]
    assert determine_trick_winner(trick_trump_rev, Suit.HEARTS, True, True) == 1

    # Test 4: Points calculation
    total_deck_points = sum(POINT_VALUES[r] for r in Rank) * 4
    assert total_deck_points == 28, f"Expected 28, got {total_deck_points}"
    print("All unit tests passed successfully!")

if __name__ == "__main__":
    test_reverse_game_trick()
