import sys
import os
import re

def update_tag(tfvars_file: str, service: str, new_tag: str) -> bool:
    """
    Updates a single Docker image tag in terraform.tfvars without modifying other content
    
    Args:
        tfvars_file (str): Path to terraform.tfvars file
        service (str): Service name ('frontend' or 'backend')
        new_tag (str): New tag value
    """
    try:
        # Create backup
        backup_file = f"{tfvars_file}.backup"
        os.system(f"cp {tfvars_file} {backup_file}")
        
        # Read the file content
        with open(tfvars_file, 'r') as file:
            lines = file.readlines()
        
        # Find the tag line and update it
        tag_pattern = re.compile(rf'(\s*tag\s*=\s*")[^"]*(".*)')
        service_block = False
        found_tag = False
        old_tag = None
        
        for i, line in enumerate(lines):
            if f"{service}_image" in line:
                service_block = True
            elif service_block and "}" in line:
                service_block = False
            
            if service_block and "tag" in line:
                match = tag_pattern.search(line)
                if match:
                    old_tag = line.split('"')[1]
                    lines[i] = match.group(1) + new_tag + match.group(2) + '\n'
                    found_tag = True
                    break
        
        if not found_tag:
            print(f"Error: Could not find tag for {service}_image")
            os.system(f"mv {backup_file} {tfvars_file}")
            return False
        
        # Write the updated content back
        with open(tfvars_file, 'w') as file:
            file.writelines(lines)
            
        print(f"Updated {service} image tag from '{old_tag}' to '{new_tag}'")
        os.remove(backup_file)
        return True
            
    except Exception as e:
        print(f"Error: {str(e)}")
        if os.path.exists(backup_file):
            os.system(f"mv {backup_file} {tfvars_file}")
        return False

def main():
    if len(sys.argv) != 4:
        print("Usage: python update_tag.py <tfvars_file> <service> <new_tag>")
        print("Example: python update_tag.py terraform.tfvars frontend v0.12")
        print("Services available: frontend, backend")
        sys.exit(1)
    
    tfvars_file = sys.argv[1]
    service = sys.argv[2]
    new_tag = sys.argv[3]
    
    if service not in ['frontend', 'backend']:
        print("Error: Service must be either 'frontend' or 'backend'")
        sys.exit(1)
    
    if update_tag(tfvars_file, service, new_tag):
        print("Successfully updated Docker image tag")
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()