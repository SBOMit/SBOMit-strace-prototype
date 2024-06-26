import requests
from bs4 import BeautifulSoup
import subprocess
import os

# URL of the Awesome GitHub page
url = "https://github.com/rust-unofficial/awesome-rust"

def clone_repo(repo_url, output_path):
    # Ensure the output path exists
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    # Change the current working directory to the output path
    os.chdir(output_path)
    subprocess.run(["git", "clone", repo_url])
    # Change back to the original working directory
    os.chdir('..')

output_path = 'eval_rust_projects'

def get_categories(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    category_headings = soup.find_all('h2')
    categories = [h2.text.strip() for h2 in category_headings if h2.text.strip() != 'Table of contents']
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
    # categories_all = ['Applications', 'Development tools', 'Libraries']
    categories = ['Applications']
    for category in categories:
        print(f"Processing category: {category}")
        repo_urls = get_repo_urls(response.text, category)
        selected_urls = list(repo_urls)[150:200]
        for repo_url in selected_urls:
            print(f"Cloning {repo_url}")
            clone_repo(repo_url, output_path)
else:
    print("Failed to fetch the Awesome README page")