import os
import sys
import traceback

OUTPUT_FILE = os.path.join(os.path.dirname(__file__), 'tmp_openapi_output.txt')

print("[tmp_openapi] Starting OpenAPI generation")
try:
    # Ensure project root (backend) is on sys.path
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
    if project_root not in sys.path:
        sys.path.insert(0, project_root)

    from app.main import app

    data = app.openapi()

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("OpenAPI generated successfully\n")
        f.write(f"Paths count: {len(data.get('paths', {}))}\n")
        for i, p in enumerate(sorted(data.get('paths', {}).keys())):
            if i >= 20:
                break
            f.write(f"path: {p}\n")
except Exception as e:
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("Error generating OpenAPI:\n")
        f.write(repr(e) + "\n")
        f.write('Traceback:\n')
        f.write(traceback.format_exc())