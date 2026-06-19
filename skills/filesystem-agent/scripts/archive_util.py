import os
import zipfile
import sys
import argparse

def archive_path(source_path, output_zip):
    """
    Generic Compression Utility v4.6.3
    Designed to mirror MCP 'compress' tool schema.
    """
    if not os.path.exists(source_path):
        return False, f"Source path not found: {source_path}"

    try:
        with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
            if os.path.isdir(source_path):
                for root, dirs, files in os.walk(source_path):
                    rel_root = os.path.relpath(root, source_path)
                    if not files and not dirs:
                        # Preserve empty directories with an explicit zip entry
                        dir_rel_path = "" if rel_root == "." else rel_root
                        if dir_rel_path:
                            zf.write(root, dir_rel_path + "/")
                            continue
                    for file in files:
                        full_path = os.path.join(root, file)
                        rel_path = os.path.relpath(full_path, source_path)
                        zf.write(full_path, rel_path)
            else:
                zf.write(source_path, os.path.basename(source_path))
        return True, f"Successfully archived {source_path} to {output_zip}"
    except Exception as e:
        return False, str(e)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="MAF-Native Dynamic Archiver")
    parser.add_argument("--source", required=True, help="Path to file or directory to zip")
    parser.add_argument("--output", required=True, help="Full path for the resulting .zip file")
    
    args = parser.parse_args()
    success, message = archive_path(args.source, args.output)
    print(message)
    sys.exit(0 if success else 1)
