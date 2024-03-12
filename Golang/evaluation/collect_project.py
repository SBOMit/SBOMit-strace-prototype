import requests
from bs4 import BeautifulSoup
import subprocess
import os

# URL of the Awesome GitHub page
url = "https://github.com/avelino/awesome-go"

def clone_repo(repo_url, output_path):
    # Ensure the output path exists
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    # Change the current working directory to the output path
    os.chdir(output_path)
    subprocess.run(["git", "clone", repo_url])
    # Change back to the original working directory
    os.chdir('..')

output_path = 'eval_golang_projects'

def get_categories(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    category_headings = soup.find_all('h2')
    categories = [h2.text.strip() for h2 in category_headings if h2.text.strip() != 'Contents']
    return categories

def get_repo_urls(html_content, category):
    soup = BeautifulSoup(html_content, 'html.parser')
    category_section = soup.find('h2', string=category)
    repo_urls = set()
    
    for sibling in category_section.find_all_next():
        if sibling.name == "h2":
            break
        for a in sibling.find_all('a', href=True):
            href = a['href']
            if href.startswith('https://github.com'):
                repo_urls.add(href)
    return repo_urls

# Fetch the Awesome README page
response = requests.get(url)
if response.status_code == 200:
    categories_parse = get_categories(response.text)  # Get all categories
    # print(categories_parse)
    categories_all = ['Artificial Intelligence', 'Audio and Music', 'Authentication and OAuth', 'Blockchain', 'Bot Building', 'Build Automation', 'Command Line', 'Configuration', 'Continuous Integration', 'CSS Preprocessors', 'Data Structures and Algorithms', 'Database', 'Database Drivers', 'Date and Time', 'Distributed Systems', 'Dynamic DNS', 'Email', 'Embeddable Scripting Languages', 'Error Handling', 'File Handling', 'Financial', 'Forms', 'Functional', 'Game Development', 'Generators', 'Geographic', 'Go Compilers', 'Goroutines', 'GUI', 'Hardware', 'Images', 'IoT (Internet of Things)', 'Job Scheduler', 'JSON', 'Logging', 'Machine Learning', 'Messaging', 'Microsoft Office', 'Miscellaneous', 'Natural Language Processing', 'Networking', 'OpenGL', 'ORM', 'Package Management', 'Performance', 'Query Language', 'Resource Embedding', 'Science and Data Analysis', 'Security', 'Serialization', 'Server Applications', 'Stream Processing', 'Template Engines', 'Testing', 'Text Processing', 'Third-party APIs', 'Utilities', 'UUID', 'Validation', 'Version Control', 'Video', 'Web Frameworks', 'WebAssembly', 'Windows', 'XML', 'Zero Trust', 'Code Analysis', 'Editor Plugins', 'Go Generate Tools', 'Go Tools', 'Software Packages', 'Benchmarks', 'Conferences', 'E-Books', 'Gophers', 'Meetups', 'Style Guides', 'Social Media', 'Websites']
    categories = ['Artificial Intelligence', 'Audio and Music', 'Authentication and OAuth', 'Blockchain', 'Bot Building', 'Build Automation', 'Command Line', 'Configuration', 'Continuous Integration', 'CSS Preprocessors']
    for category in categories:
        print(f"Processing category: {category}")
        repo_urls = get_repo_urls(response.text, category)
        for repo_url in repo_urls:
            print(f"Cloning {repo_url}")
            clone_repo(repo_url, output_path)
else:
    print("Failed to fetch the Awesome README page")