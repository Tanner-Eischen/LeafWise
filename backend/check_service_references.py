#!/usr/bin/env python3
"""
Script to check for references to services in the codebase.
This helps identify missing or duplicate services.
"""

import os
import re
import sys
from collections import defaultdict
from typing import Dict, List, Set, Tuple

# Define colors for terminal output
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
BLUE = "\033[94m"
RESET = "\033[0m"

# Define paths to search
SEARCH_PATHS = [
    "app/services",
    "app/api",
    "app/models",
    "app/schemas",
    "tests"
]

# Define service name pattern
SERVICE_PATTERN = re.compile(r"([a-zA-Z_]+)_service\.py")
SERVICE_IMPORT_PATTERN = re.compile(r"from\s+app\.services\.([a-zA-Z_]+)_service\s+import")
SERVICE_REFERENCE_PATTERN = re.compile(r"([a-zA-Z_]+)Service")

def find_service_files() -> List[str]:
    """Find all service files in the services directory."""
    services_dir = "app/services"
    service_files = []
    
    for file in os.listdir(services_dir):
        if file.endswith("_service.py"):
            service_files.append(file)
    
    return service_files

def find_service_references() -> Dict[str, Set[str]]:
    """Find all references to services in the codebase."""
    references = defaultdict(set)
    
    for path in SEARCH_PATHS:
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith(".py"):
                    file_path = os.path.join(root, file)
                    with open(file_path, "r", encoding="utf-8") as f:
                        try:
                            content = f.read()
                            
                            # Find service imports
                            for match in SERVICE_IMPORT_PATTERN.finditer(content):
                                service_name = match.group(1)
                                references[f"{service_name}_service.py"].add(file_path)
                            
                            # Find service class references
                            for match in SERVICE_REFERENCE_PATTERN.finditer(content):
                                service_class = match.group(1)
                                # Convert CamelCase to snake_case
                                service_name = re.sub(r'(?<!^)(?=[A-Z])', '_', service_class).lower()
                                references[f"{service_name}_service.py"].add(file_path)
                                
                        except UnicodeDecodeError:
                            print(f"Could not read {file_path}")
    
    return references

def check_for_issues() -> Tuple[List[str], List[str], Dict[str, int]]:
    """Check for missing or unreferenced services."""
    service_files = find_service_files()
    service_references = find_service_references()
    
    # Find missing services (referenced but don't exist)
    missing_services = [
        service for service in service_references.keys()
        if service not in service_files and service != "__init__.py"
    ]
    
    # Find unreferenced services (exist but not referenced)
    unreferenced_services = [
        service for service in service_files
        if service not in service_references and service != "__init__.py"
    ]
    
    # Count references to each service
    reference_counts = {
        service: len(references)
        for service, references in service_references.items()
        if service in service_files
    }
    
    return missing_services, unreferenced_services, reference_counts

def main():
    """Main function."""
    print(f"{BLUE}Checking service references...{RESET}")
    
    missing_services, unreferenced_services, reference_counts = check_for_issues()
    
    # Print missing services
    if missing_services:
        print(f"\n{RED}Missing Services (referenced but don't exist):{RESET}")
        for service in sorted(missing_services):
            print(f"  - {service}")
    else:
        print(f"\n{GREEN}No missing services found.{RESET}")
    
    # Print unreferenced services
    if unreferenced_services:
        print(f"\n{YELLOW}Unreferenced Services (exist but not referenced):{RESET}")
        for service in sorted(unreferenced_services):
            print(f"  - {service}")
    else:
        print(f"\n{GREEN}All services are referenced.{RESET}")
    
    # Print reference counts
    print(f"\n{BLUE}Service Reference Counts:{RESET}")
    for service, count in sorted(reference_counts.items(), key=lambda x: x[1], reverse=True):
        color = GREEN if count > 0 else YELLOW
        print(f"  - {color}{service}: {count} references{RESET}")
    
    # Print summary
    print(f"\n{BLUE}Summary:{RESET}")
    print(f"  - Total services: {len(reference_counts)}")
    print(f"  - Missing services: {len(missing_services)}")
    print(f"  - Unreferenced services: {len(unreferenced_services)}")
    
    # Return error code if there are missing services
    return 1 if missing_services else 0

if __name__ == "__main__":
    sys.exit(main())