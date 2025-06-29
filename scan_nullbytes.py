import os
import sys
from pathlib import Path

def scan_file_for_nullbytes(filepath):
    try:
        path = Path(filepath)
        if not path.is_file():
            print(f"Skipping {filepath}: Not a file")
            return False
            
        with open(filepath, 'rb') as f:
            content = f.read()
            total_bytes = len(content)
            null_positions = [i for i, byte in enumerate(content) if byte == 0]
            if null_positions:
                print(f"\n{filepath}:")
                print(f"- Total bytes: {total_bytes}")
                print(f"- Found {len(null_positions)} null bytes")
                print(f"- Null byte positions: {null_positions}")
                
                # Print context around first null byte
                if null_positions:
                    pos = null_positions[0]
                    start = max(0, pos - 10)
                    end = min(total_bytes, pos + 10)
                    context = content[start:end]
                    print(f"- Context around first null byte (hex):")
                    print(' '.join(f'{b:02x}' for b in context))
                return True
            return False
    except Exception as e:
        print(f"\nError scanning {filepath}: {e}")
        return False

def scan_directory(directory):
    extensions = {'.py', '.txt', '.md', '.json', '.yml', '.yaml', '.dart', '.sql'}
    found_nullbytes = False
    total_files = 0
    files_with_nullbytes = 0
    
    print(f"\nScanning directory: {directory}")
    print("Looking for files with extensions:", ', '.join(extensions))
    
    for root, _, files in os.walk(directory):
        for file in files:
            if any(file.endswith(ext) for ext in extensions):
                total_files += 1
                filepath = os.path.join(root, file)
                print(f"\rScanning file {total_files}: {filepath}", end='')
                if scan_file_for_nullbytes(filepath):
                    found_nullbytes = True
                    files_with_nullbytes += 1
    
    print(f"\n\nScan complete!")
    print(f"Total files scanned: {total_files}")
    print(f"Files with null bytes: {files_with_nullbytes}")
    
    return found_nullbytes

if __name__ == '__main__':
    directory = '.' if len(sys.argv) < 2 else sys.argv[1]
    scan_directory(directory) 