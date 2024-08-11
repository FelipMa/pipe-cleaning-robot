import difflib
import re

def preprocess_lines(text):
    """Remove blank lines, strip whitespace from each line, and handle double spaces."""
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return [re.sub(r'\s{2,}', ' ', line) for line in lines]

def truncate_to_minimum_length(lines1, lines2):
    """Truncate both lists to the length of the smaller list."""
    min_length = min(len(lines1), len(lines2))
    return lines1[:min_length], lines2[:min_length]

def find_double_spaces(text):
    """Find lines with two or more consecutive spaces."""
    double_space_lines = []
    for line in text.splitlines():
        if re.search(r'\s{2,}', line):
            double_space_lines.append(line)
    return double_space_lines

def compare_file_to_string(file_path, comparison_string):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        lines_to_compare = ''.join(lines[3:]).strip()

    processed_file_lines = preprocess_lines(lines_to_compare)
    processed_comparison_lines = preprocess_lines(comparison_string)

    truncated_file_lines, truncated_comparison_lines = truncate_to_minimum_length(processed_file_lines, processed_comparison_lines)

    double_space_file_lines = find_double_spaces(''.join(processed_file_lines))
    double_space_comparison_lines = find_double_spaces(''.join(processed_comparison_lines))

    if double_space_file_lines:
        print("Lines in the file with double spaces:")
        for line in double_space_file_lines:
            print(line)
    if double_space_comparison_lines:
        print("Lines in the comparison string with double spaces:")
        for line in double_space_comparison_lines:
            print(line)

    diff = difflib.unified_diff(
        truncated_file_lines,
        truncated_comparison_lines,
        fromfile='file_content',
        tofile='comparison_string',
        lineterm=''
    )

    diff_list = list(diff)
    if len(diff_list) > 0:
        print("\nDifferences:")
        for line in diff_list:
            print(line)
    else:
        print("The contents of the file match the string.")
