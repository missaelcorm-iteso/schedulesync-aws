import requests
import argparse

def main():
    parser = argparse.ArgumentParser(description='Upload scan results to DefectDojo.')
    parser.add_argument('--file', required=True, help='The scan result file to upload.')
    parser.add_argument('--environment', required=True, help='The environment name.')
    parser.add_argument('--token', required=True, help='The API token for authentication.')
    parser.add_argument('--url', required=True, help='The base URL of the DefectDojo instance.')

    args = parser.parse_args()

    file_name = args.file
    environment = args.environment
    token = args.token
    base_url = args.url
    endpoint = '/api/v2/import-scan/'

    scans_types = {
        "tfsec-report.json": "TFSec Scan",
        "tfsec-report.sarif.json": "SARIF",
        "trivy-results.json": "Trivy Scan",
        "javascript.sarif": "SARIF",
        "zapproxy-results.xml": "ZAP Scan"
    }

    scan_type = scans_types.get(file_name, None)
    if not scan_type:
        print(f"Unsupported file type: {file_name}")
        return

    headers = {
        'Authorization': f'Token {token}'
    }

    url = f'{base_url}{endpoint}'

    data = {
        'active': True,
        'verified': True,
        'scan_type': scan_type,
        'environment': environment,
        'minimum_severity': 'Low',
        'product_name': 'schedulesync',
        'product_type_name': 'Research',
        'engagement_name': f'schedulesync-{environment}',
    }

    files = {'file': open(file_name, 'rb')}

    response = requests.post(url, headers=headers, data=data, files=files)

    if response.status_code == 201:
        print("Scan uploaded successfully.")
    else:
        print(f"Failed to upload scan: {response.status_code} - {response.text}")

if __name__ == "__main__":
    main()