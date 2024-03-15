import json
import sys

def parse_json_for_bom_ref(sbom_file_path):
    bom_ref_set = set()
    with open(sbom_file_path, 'r') as json_file:
        data = json.load(json_file)
        if 'components' in data and data['components']:
            for component in data['components']:
                if 'bom-ref' in component:
                    bom_ref_set.add(component['bom-ref'].replace("pkg:cargo/", ""))
    return bom_ref_set

def parse_txt_file_lines(file_path):
    txt_set = set()
    with open(file_path, 'r') as txt_file:
        for line in txt_file:
            clean_line = line.strip()
            if clean_line:
                txt_set.add(clean_line)
    return txt_set

# Check if the correct number of arguments are passed
if len(sys.argv) != 4:
    print("Usage: script.py <sbom_file_path> <pkg_file_path> <bin_pkg_file_path>")
    sys.exit(1)

sbom_file_path = sys.argv[1]
pkg_file_path = sys.argv[2]
bin_pkg_file_path = sys.argv[3]

# No changes needed for extracting project names from paths, assuming it's not required for the new bin_pkg_set

# Parse the JSON and text files
bom_ref_set = parse_json_for_bom_ref(sbom_file_path)
pkg_set = parse_txt_file_lines(pkg_file_path)
bin_pkg_set = parse_txt_file_lines(bin_pkg_file_path)  # Reuse the function for the new txt file

# Combine all three sets into a unique set
unique_set = bom_ref_set.union(pkg_set, bin_pkg_set)

# Print the combined unique set
for item in unique_set:
    print(item)
