import json
import sys

def parse_json_for_bom_ref(sbom_file_path):
    bom_ref_set = set()  # Initialize an empty set for the "bom-ref" items

    with open(sbom_file_path, 'r') as json_file:
        data = json.load(json_file)
        if 'components' in data and data['components']:
            for component in data['components']:
                if 'bom-ref' in component and sbom_project_name not in component['bom-ref']:
                    bom_ref_set.add(component['bom-ref'].replace("pkg:golang/", ""))

    return bom_ref_set

def parse_txt_file_lines(pkg_file_path):
    pkg_set = set()  # Initialize an empty set to store lines from the text file

    with open(pkg_file_path, 'r') as txt_file:
        for line in txt_file:
            clean_line = line.strip()
            if clean_line:
                pkg_set.add(clean_line)

    return pkg_set

# Check if the correct number of arguments are passed
if len(sys.argv) != 3:
    print("Usage: script.py <sbom_file_path> <pkg_file_path>")
    sys.exit(1)

# Use the first argument as the SBOM file path and the second as the package list file path
sbom_file_path = sys.argv[1]
pkg_file_path = sys.argv[2]

# Split the string by '/'
pkg_parts = pkg_file_path.split('/')
# Take the last part and split by '-' to remove 'pkg.txt'
pkg_project_parts = pkg_parts[-1].split('-')[:-1]
# Join the parts back together to form the project name
pkg_project_name = '-'.join(pkg_project_parts)

# Split the string by '/'
sbom_parts = sbom_file_path.split('/')
# Take the last part and split by '-' to remove 'sbom.json'
sbom_project_parts = sbom_parts[-1].split('-')[:-1]
# Join the parts back together to form the project name
sbom_project_name = '-'.join(sbom_project_parts)

# print("pkg_project_name:", pkg_project_name)
# print("sbom_project_name:", sbom_project_name)

# Parse the JSON and text files
bom_ref_set = parse_json_for_bom_ref(sbom_file_path)
pkg_set = parse_txt_file_lines(pkg_file_path)

# Print the parsed lists (optional)
# print("BOM-Ref List:", bom_ref_set)
# print("Text File Lines:", pkg_set)

# Determine the relationship between the two sets
if not bom_ref_set and not pkg_set or bom_ref_set == pkg_set:
    condition = 0  # Both lists are exactly the same
elif bom_ref_set > pkg_set:
    condition = 1  # bom_ref_set contains all items in pkg_set and has more
elif pkg_set > bom_ref_set:
    condition = 2  # pkg_set contains all items in bom_ref_set and has more
else:
    condition = 3  # Both lists contain some items that the other doesn't have

# Print the condition number
print("Condition:", condition)


