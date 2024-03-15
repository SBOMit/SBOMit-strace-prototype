import sys

def parse_txt_file_lines(file_path):
    """Parse lines from a text file and return a set of cleaned lines."""
    lines_set = set()

    with open(file_path, 'r') as file:
        for line in file:
            clean_line = line.strip()
            if clean_line:
                lines_set.add(clean_line)

    return lines_set

# Check if the correct number of arguments are passed
if len(sys.argv) != 3:
    print("Usage: script.py <file1_path> <file2_path>")
    sys.exit(1)

# Use the arguments as the paths for the two text files to compare
file1_path = sys.argv[1]
file2_path = sys.argv[2]

# Parse the text files
file1_set = parse_txt_file_lines(file1_path)
file2_set = parse_txt_file_lines(file2_path)

# Determine the relationship between the two sets
if not file1_set and not file2_set or file1_set == file2_set:
    condition = 0  # Both files are exactly the same
elif file1_set > file2_set:
    condition = 1  # file1_set contains all items in file2_set and has more
elif file2_set > file1_set:
    condition = 2  # file2_set contains all items in file1_set and has more
else:
    condition = 3  # Both files contain some items that the other doesn't have

# Print the condition number
print("Condition:", condition)
