class PokerHand():
    def __init__(self, cadena):
        _values = 0
        _suits = 1
        self.order_values = _values
        self.order_suits = _suits
        
        self._types = [
            self.royal_straight_flush, self.straight_flush,
            self.four_of_a_kind, self.full_house,
            self.flush, self.straight, self.three_of_a_kind,
            self.two_pair, self.one_pair, self.high_card
        ]
        
        self._dict_default = {
            _values: ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'],
            _suits : ['S',  'H',  'D',  'C']
        }
                
        self._list_card = list(zip(
            *[(_[0], _[1]) for _ in cadena.split()]
        ))
        
        if not( 
            self.valid_cards(_values) and self.valid_cards(_suits)
        ):
            raise Exception("Valores invalidos detectados")
        
        self.values = self.get_ids(_values)
        self.suits = self._list_card[_suits]
        self._is = self.analysis_hand()

    def analysis_hand(self):
        for _types in self._types:
            hand_is = _types()
            if hand_is:
                return hand_is
                
    def compare_with(self, other_class):
        order_of_win = [_.__name__ for _ in self._types]
        
        self_is = self._is
        other_is = getattr(other_class, '_is')
        
        if order_of_win.index(self_is[0]) < order_of_win.index(other_is[0]):
            return 'WIN'
        elif order_of_win.index(self_is[0]) > order_of_win.index(other_is[0]):
            return 'LOSS'
        elif self_is[1] > other_is[1]:
            return 'WIN'
        elif self_is[1] < other_is[1]:
            return 'LOSS'
        elif max(self.values) > max(getattr(other_class, 'values')):
            return 'WIN'
        elif max(self.values) < max(getattr(other_class, 'values')):
            return 'LOSS'
        else:
            return 'LOSS'
        
        
    def valid_cards(self, order):
        return set(self._list_card[order]).issubset(
            set(self._dict_default[order])
        )
    
    def get_ids(self, order):
        return sorted([
            self._dict_default[order].index(_) for _ in self._list_card[order]
        ])
    
    def parser_values(self):
        pass
    
    def royal_straight_flush(self):
        if self.values == [8, 9, 10, 11, 12] and len(set(self.suits)) == 1:
            return 'royal_straight_flush', \
                   max(self.values)
    
    def straight_flush(self):
        if (self.values[0] + self.values[-1] == 2 * self.values[2]) \
            and len(set(self.values)) == 5 and len(set(self.suits)) == 1:
            return 'straight_flush',\
                   max(self.values)
    
    def four_of_a_kind(self):
        if len(set(self.values)) == 2 and 4 in [self.values.count(_) for _ in self.values]:
            return 'four_of_a_kind', \
                   max(set(self.values), key=self.values.count)
        
    def full_house(self):
        if len(set(self.values)) == 2 and 3 in [self.values.count(_) for _ in self.values]:
            return 'full_house', \
                   max(set(self.values), key=self.values.count)

    def flush(self):
        if len(set(self.values)) == 5 and len(set(self.suits)) == 1:
            return 'flush', max(self.values)
        
    def straight(self):
        if len(set(self.values)) == 5 and (self.values[0] + self.values[-1] == 2 * self.values[2]):
            return 'straight', max(self.values)
    
    def three_of_a_kind(self):
        if len(set(self.values)) == 3 and 3 in [self.values.count(_) for _ in self.values]:
            return 'three_of_a_kind', \
                   max(set(self.values), key=self.values.count)
            
    def two_pair(self):
        if len(set(self.values)) == 3 and [self.values.count(_) for _ in self.values].count(2) == 4:
            return 'two_pair', \
                   max(set(self.values), key=self.values.count)

    def one_pair(self):
        if len(set(self.values)) == 4 and [self.values.count(_) for _ in self.values].count(2) == 2:
            return 'one_pair', \
                   max(set(self.values), key=self.values.count)
        
    def high_card(self):
        return 'high_card', max(self.values)