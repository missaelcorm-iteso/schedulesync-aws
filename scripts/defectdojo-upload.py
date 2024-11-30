import requests
import argparse
import datetime

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
        "tfsec-report.json": {
            "name": "TFSec Scan",
            "type": "TFSec Scan",
        },
        "tfsec-report.sarif.json": {
            "name": "TFSec Scan",
            "type": "SARIF",
        },
        "trivy-results.json": {
            "name": "Trivy Scan",
            "type": "Trivy Scan",
        },
        "javascript.sarif": {
            "name": "CodeQL Scan",
            "type": "SARIF",
        },
        "zapproxy-results.xml": {
            "name": "ZAP Scan",
            "type": "ZAP Scan",
        },
    }

    scan_type = scans_types.get(file_name, None).get('type', None)
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
        'test_title': f'{scans_types.get(file_name, None).get("name", None)} - {datetime.datetime.now().strftime("%x %X")}',
        'environment': environment,
        'service': 'schedulesync',
        'close_old_findings': True,
        'auto_create_context': True,
        'deduplication_on_engagement': True,
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