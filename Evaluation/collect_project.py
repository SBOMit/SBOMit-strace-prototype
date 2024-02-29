import requests
from bs4 import BeautifulSoup
import subprocess
import os

# URL of the Awesome GitHub page
url = "https://github.com/avelino/awesome-go"

# Categories to scrape
categories = ["Artificial Intelligence", "Audio and Music", "Authentication and OAuth"]

# def clone_repo(repo_url):
#     subprocess.run(["git", "clone", repo_url])

def clone_repo(repo_url, output_path):
    # Ensure the output path exists
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    # Change the current working directory to the output path
    os.chdir(output_path)
    subprocess.run(["git", "clone", repo_url])
    # Change back to the original working directory
    os.chdir('..')

output_path = 'cloned_go_projects'

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
    for category in categories:
        print(f"Processing category: {category}")
        repo_urls = get_repo_urls(response.text, category)
        print(repo_urls)
        for repo_url in repo_urls:
            print(f"Cloning {repo_url}")
            clone_repo(repo_url, output_path)
else:
    print("Failed to fetch the Awesome README page")


