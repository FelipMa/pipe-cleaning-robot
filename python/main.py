import numpy as np
import io

from python.compare import compare_file_to_string
from python.map import transform_map
from python.robot import Robot

# Mapa como um array numpy para manipulação mais fácil
map_ = transform_map()

# Posição inicial do robô
initial_position = None

# Orientação inicial do robô
robot_orientation_string = "North"

# Mapeamento de orientação para direções
orientation_mapping = {
    "North": (-1, 0),  # Move para cima
    "West": (0, -1),  # Move para a esquerda
    "South": (1, 0),  # Move para baixo
    "East": (0, 1)  # Move para a direita
}

# Orientações possíveis em ordem anti-horária
orientations = ["North", "West", "South", "East"]

# Função para encontrar a posição do robô (7)
def find_robot_position(map_):
    return np.argwhere(map_ == 7)[0]

# Função para verificar se a posição está fora dos limites
def is_out_of_bounds(map_, x, y):
    return x < 0 or x >= map_.shape[0] or y < 0 or y >= map_.shape[1]

# Função para verificar se o caminho à frente é uma barreira
def is_barrier(map_, x, y):
    return map_[x, y] in [4, 3, 2]

# Função para decrementar o valor do bloco à frente (e transformá-lo em caminho se for 3)
def decrement_block_ahead(map_, orientation):
    robot_pos = find_robot_position(map_)
    x, y = robot_pos
    dx, dy = orientation_mapping[orientation]
    new_x, new_y = x + dx, y + dy

    if not is_out_of_bounds(map_, new_x, new_y) and is_barrier(map_, new_x, new_y):

        if map_[new_x, new_y] == 2:
            map_[new_x, new_y] = 0
        else:
            map_[new_x, new_y] -= 1

    return map_

# Função para mover o robô à frente com base na orientação atual
def move_ahead(map_, orientation):
    robot_pos = find_robot_position(map_)
    x, y = robot_pos
    dx, dy = orientation_mapping[orientation]
    new_x, new_y = x + dx, y + dy

    if not is_out_of_bounds(map_, new_x, new_y) and map_[new_x, new_y] != 1:
        map_[x, y], map_[new_x, new_y] = 0, 7

    return map_

# Função para alterar a orientação do robô
def change_orientation():
    global robot_orientation_string
    current_index = orientations.index(robot_orientation_string)
    new_index = (current_index + 1) % 4
    robot_orientation_string = orientations[new_index]

# Função para definir os valores dos sensores com base na orientação
def define_sensors_values(map_, robot_row, robot_column, robot_orientation):
    # Inicialize os sensores com valores padrão
    head = left = under = barrier = 0

    # Mapeamento de orientações
    orientations = {
        "North": (-1, 0, 0, -1),  # Move para cima, esquerda é a coluna anterior
        "South": (1, 0, 0, 1),  # Move para baixo, esquerda é a coluna seguinte
        "East": (0, 1, -1, 0),  # Move para a direita, esquerda é a linha anterior
        "West": (0, -1, 1, 0)  # Move para a esquerda, esquerda é a linha seguinte
    }

    if robot_orientation in orientations:
        dx, dy, lx, ly = orientations[robot_orientation]

        # Verificar o caminho à frente (head)
        head_x, head_y = robot_row + dx, robot_column + dy
        if (head_x < 0 or head_x >= map_.shape[0] or
                head_y < 0 or head_y >= map_.shape[1] or
                map_[head_x, head_y] == 1):
            head = 1
        else:
            head = 0

        # Verificar o caminho à esquerda (left)
        left_x, left_y = robot_row + lx, robot_column + ly
        if (left_x < 0 or left_x >= map_.shape[0] or
                left_y < 0 or left_y >= map_.shape[1] or
                map_[left_x, left_y] == 1):
            left = 1
        else:
            left = 0

        # Verificar a posição sob o robô (under)
        if initial_position is not None and (robot_row, robot_column) == initial_position:
            under = 1
        else:
            under = 0

        # Verificar se há barreira à frente (barrier)
        barrier_x, barrier_y = robot_row + dx, robot_column + dy
        if (barrier_x >= 0 and barrier_x < map_.shape[0] and
                barrier_y >= 0 and barrier_y < map_.shape[1] and
                map_[barrier_x, barrier_y] in [2,3,4]):
            barrier = 1
        else:
            barrier = 0

    return head, left, under, barrier

# Função para imprimir o estado do robô
def print_robot_state(x, y, orientation, head, left, under, barrier, output_stream):
    output_stream.write(f"Row = {x} | Column =  {y+1} | Orientation =  {orientation}\n")
    output_stream.write(f"Head = {head} | Left = {left} | Barrier = {barrier} | Under = {under}\n")
    print(f"Row = {x} | Column =  {y+1} | Orientation =  {orientation}")
    print(f"Head = {head} | Left = {left} | Barrier = {barrier} | Under = {under}")
    print(f"\n")

    # if (head == 0 and left == 1 and barrier == 0 and under == 0 and
    #         x == 1 and y + 1 == 10 and orientation == "North"):
    #     print_robot_state


robot = Robot()

# Função para mover o robô com a nova lógica e atualizar o estado
def move(map_):
    global robot_orientation_string, initial_position
    robot_pos = find_robot_position(map_)
    x, y = robot_pos

    # Inicialize a posição inicial do robô
    if initial_position is None:
        initial_position = (x, y)

    # Obtenha os valores dos sensores
    head, left, under, barrier = define_sensors_values(map_, x, y, robot_orientation_string)
    robot.update(head, left, under, barrier)

    # Atualizar o estado do robô
    print_robot_state(x, y, robot_orientation_string, head, left, under, barrier, output_stream)

    if robot.movement == "turn":
        change_orientation()
    elif robot.movement == "remove":
        map_ = decrement_block_ahead(map_, robot_orientation_string)
    elif robot.movement == "front":
        map_ = move_ahead(map_, robot_orientation_string)

    return map_

# Captura da saída padrão
output_stream = io.StringIO()

# Sequência de movimentos de exemplo
for _ in range(100):
    map_ = move(map_)
    print(map_)
    output_stream.write("\n")

# Obtém o conteúdo da saída padrão
output_string = output_stream.getvalue()
output_stream.close()

compare_file_to_string("../robot_output.txt", output_string)