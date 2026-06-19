import os
import subprocess
import sys

def run_batch():
    skills_root = "S:/skills"
    output_dir = "S:/backups"
    util_path = "S:/skills/filesystem-agent/scripts/archive_util.py"

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    skills = [d for d in os.listdir(skills_root) if os.path.isdir(os.path.join(skills_root, d))]
    
    for skill in skills:
        source = os.path.join(skills_root, skill)
        output = os.path.join(output_dir, f"{skill}.zip")
        
        print(f"--- Packaging {skill} ---")
        cmd = [sys.executable, util_path, "--source", source, "--output", output]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(result.stdout.strip())

if __name__ == "__main__":
    run_batch()