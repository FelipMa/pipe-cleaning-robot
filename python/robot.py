class Robot:
    def __init__(self):
        # Inicializa o estado atual
        self.state = 'first_move'
        # Define a saída de movimento
        self.movement = 'neither'
        self.stop = 0

    def update(self, head, left, under, barrier):

        if under:
            self.stop += 1
        elif self.stop == 2:
            self.state = 'stand_by'
        if self.state == 'reseting':
            self.movement = 'neither'
            # Transita para o próximo estado
            self.state = 'first_move'

        elif self.state == 'first_move':
            if head == 1 and barrier == 1:
                self.movement = 'neither'
                self.state = 'stand_by'
            elif head == 0 and left == 1 and barrier == 0:
                self.movement = 'front'
                self.state = 'searching_trash_or_left'
            elif head == 0 and left == 1 and barrier == 1:
                self.movement = 'remove'
                self.state = 'first_move'
            else:
                self.movement = 'turn'
                self.state = 'first_move'

        elif self.state == 'searching_trash_or_left':
            if head == 1 and barrier == 1:
                self.movement = 'neither'
                self.state = 'stand_by'
            elif head == 0 and left == 1 and barrier == 0:
                self.movement = 'front'
            elif head == 1 and left == 1 and barrier == 0:
                self.movement = 'turn'
                self.state = 'rotating'
            elif head == 0 and left == 1 and barrier == 1:
                self.movement = 'remove'
                self.state = 'removing_trash_or_following_left'
            else:
                self.movement = 'turn'
                self.state = 'removing_trash_or_following_left'

        elif self.state == 'rotating':
            if head == 1 and barrier == 1:
                self.movement = 'neither'
                self.state = 'stand_by'
            elif head == 0 and left == 1 and barrier == 0:
                self.movement = 'front'
                self.state = 'searching_trash_or_left'
            elif head == 0 and left == 1 and barrier == 1:
                self.movement = 'remove'
                self.state = 'removing_trash_or_following_left'
            else:
                self.movement = 'turn'

        elif self.state == 'removing_trash_or_following_left':
            if head == 1 and barrier == 1:
                self.movement = 'neither'
                self.state = 'stand_by'
            elif head == 0 and barrier == 1:
                self.movement = 'remove'
            elif head == 0 and barrier == 0:
                self.movement = 'front'
                self.state = 'searching_trash_or_left'
            elif head == 1 and left == 1 and barrier == 0:
                self.movement = 'turn'
                self.state = 'rotating'
            elif head == 1 and left == 0 and barrier == 0:
                self.movement = 'turn'

        elif self.state == 'stand_by':
            self.movement = 'neither'
            # Permanece em stand_by até que detecte lixo
            # Aqui você pode adicionar a lógica para transição para outro estado
            # baseado no sensor 'under'

    def __repr__(self):
        return f"State: {self.state}, Movement: {self.movement}"
