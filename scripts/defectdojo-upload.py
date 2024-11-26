import requests
import sys

file_name = sys.argv[1]
token = sys.argv[2]
scan_type = ''

scans_types = {
    "tfsec-report.json": "TFSec Scan",
    "tfsec-report.sarif.json": "SARIF",
    "trivy-results.json": "Trivy Scan",
    "javascript.sarif": "SARIF"
}

scan_type = scans_types[file_name]

headers = {
    'Authorization': f'Token {token}'
}

url = 'https://demo.defectdojo.org/api/v2/import-scan/'

data = {
    'active': True,
    'verified': True,
    'scan_type': scan_type,
    'minimum_severity': 'Low',
    'engagement': 19
}

files = {
    'file': open(file_name, 'rb')
}

response = requests.post(url, headers=headers, data=data, files=files)

if response.status_code == 201:
    print('Scan results imported successfully')
else:
    print(f'Failed to import scan results: {response.content}')