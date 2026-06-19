import subprocess
import sys
import argparse
import os

def run_git(cmd, cwd):
    """Executes a git command in the specified directory."""
    try:
        result = subprocess.run(
            f"git {cmd}", 
            cwd=cwd, 
            capture_output=True, 
            text=True, 
            shell=True
        )
        return result.returncode == 0, result.stdout.strip() if result.returncode == 0 else result.stderr.strip()
    except Exception as e:
        return False, str(e)

def git_sync(repo_path, message):
    """Atomic workflow: add -> commit -> pull --rebase -> push."""
    print(f"Syncing repository at: {repo_path}")
    
    # 1. Add and Commit
    success, _ = run_git("add .", repo_path)
    if not success: return False, "Failed to stage changes."
    
    success, out = run_git(f'commit -m "{message}"', repo_path)
    if not success and "nothing to commit" not in out:
        return False, f"Commit failed: {out}"

    # 2. Sync with Remote
    print("Rebasing from remote...")
    success, out = run_git("pull --rebase", repo_path)
    if not success: return False, f"Pull failed: {out}"

    print("Pushing to origin...")
    success, out = run_git("push", repo_path)
    if not success: return False, f"Push failed: {out}"

    return True, "Repository synchronized successfully."

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PMCRO Dynamic Git Utility")
    parser.add_argument("--repo", required=True, help="Path to the git repository")
    parser.add_argument("--action", choices=["status", "sync", "log"], required=True)
    parser.add_argument("--message", default="PMCRO: Automated Sync", help="Commit message for sync")

    args = parser.parse_args()

    if args.action == "status":
        success, output = run_git("status --short", args.repo)
    elif args.action == "log":
        success, output = run_git("log -n 5 --oneline", args.repo)
    elif args.action == "sync":
        success, output = git_sync(args.repo, args.message)

    print(output)
    sys.exit(0 if success else 1)