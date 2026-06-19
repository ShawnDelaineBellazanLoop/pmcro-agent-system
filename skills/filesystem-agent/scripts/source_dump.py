import os
import datetime

def generate_source_dump(root_path, output_file=None):
    """
    PMCRO Source Dump Utility v4.6.0
    Traverses the root path and aggregates all text-based source files
    into a single atomic file for context injection or backup.
    """
    if not output_file:
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = f"source_dump_{timestamp}.txt"

    dump_content = [
        f"=== PMCRO SOURCE DUMP ===",
        f"Generated: {datetime.datetime.now().isoformat()}",
        f"Root:      {root_path}\n"
    ]

    # Extensions to include
    valid_exts = ('.cs', '.csproj', '.json', '.proto', '.md', '.yaml', '.props', '.targets', '.slnx', '.sln')
    # Folders to skip
    skip_dirs = {'bin', 'obj', '.vs', '.git', 'node_modules', 'backups', '_dumps'}

    for root, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        
        for file in files:
            if file.endswith(valid_exts):
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, root_path)
                
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        dump_content.append(f"--- FILE: {rel_path} ---")
                        dump_content.append(f.read())
                        dump_content.append("\n")
                except Exception as e:
                    dump_content.append(f"--- FILE: {rel_path} (ERROR READING: {e}) ---")

    final_dump = "\n".join(dump_content)
    
    with open(output_file, 'w', encoding='utf-8') as out:
        out.write(final_dump)
    
    return output_file

if __name__ == "__main__":
    # Default behavior: dump the current directory
    path = generate_source_dump(".")
    print(f"Dump complete: {path}")