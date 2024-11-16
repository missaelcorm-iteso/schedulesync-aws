import requests
import os

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY')

if not GITHUB_TOKEN:
    raise ValueError('GITHUB_TOKEN is not set')
if not GITHUB_REPOSITORY:
    raise ValueError('GITHUB_REPOSITORY is not set')

headers = {
    "Accept": "application/vnd.github+json",
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "X-GitHub-Api-Version": "2022-11-28"
}

LIST_ARTIFACTS_URL = f"https://api.github.com/repos/{GITHUB_REPOSITORY}/actions/artifacts"

response = requests.get(LIST_ARTIFACTS_URL, headers=headers)

if response.status_code != 200:
    raise ValueError(f"Failed to list artifacts: {response.text}")

artifacts = response.json().get('artifacts', [])

print(f"Found {len(artifacts)} artifacts")
input("Press Enter to delete all artifacts")

for artifact in artifacts:
    artifact_id = artifact.get('id')
    DELETE_ARTIFACT_URL = f"https://api.github.com/repos/{GITHUB_REPOSITORY}/actions/artifacts/{artifact_id}"
    response = requests.delete(DELETE_ARTIFACT_URL, headers=headers)
    if response.status_code != 204:
        raise ValueError(f"Failed to delete artifact {artifact_id}: {response.text}")
    
    print(f"Deleted artifact {artifact_id}")
    
print("All artifacts deleted")