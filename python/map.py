import numpy as np

def transform_map():
    # Define default block type mappings (as integers)
    # 0: free_path_block_on
    # 1: wall_block_on
    # 2: trash_1_on
    # 3: trash_2_on
    # 4: trash_3_on
    # 7: robot_on

    block_types = {
        '000': 0,
        '001': 1,
        '111': 7,
        '010': 4,
        '011': 3,
        '100': 2,
    }

    with open("../map.txt", 'r') as file:
        asd = file.read()
    lines = asd.splitlines()

    # Filter lines that do not start with "//"
    filtered_lines = [line for line in lines if not line.startswith("//")]

    # Rejoin the filtered lines into a single string
    binary_string = "\n".join(filtered_lines)
    cleaned_string = binary_string.replace("\n", " ").strip()

    # Split the string into a list of binary numbers
    binary_list = cleaned_string.split(" ")

    # Convert the list into a list of lists where each inner list represents a row
    rows_as_lists = [binary_list[i:i + 20] for i in range(0, len(binary_list), 20)]

    # Map binary strings to integers based on the configuration
    integer_map = [[block_types.get(cell, -1) for cell in row] for row in rows_as_lists]

    # Optionally, convert to numpy array for easier manipulation
    array_map = np.array(integer_map)

    print(array_map)
    return array_map
