import os
import sys
import shutil
import fnmatch
import argparse
import datetime


def delete_path(target, dry_run=False, glob_pattern=None, backup_dir=None):
    """
    MAF-Native Delete Utility v4.6.3
    TYPE1 action: fs_delete — safe deletion with optional dry-run,
    glob pattern filtering, and backup-before-delete safety net.
    Mirrors MCP 'delete' tool schema for EC-SYS-001 compliance.
    """
    if not os.path.exists(target):
        return False, f"Target not found: {target}"

    # Collect items to delete
    targets = []
    if glob_pattern and os.path.isdir(target):
        for root, dirs, files in os.walk(target):
            for f in files:
                if fnmatch.fnmatch(f, glob_pattern):
                    targets.append(os.path.join(root, f))
        if not targets:
            return False, f"No files matching '{glob_pattern}' found in: {target}"
    else:
        targets = [target]

    results = []
    for item in targets:
        # Optional: backup before delete
        if backup_dir:
            try:
                os.makedirs(backup_dir, exist_ok=True)
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                basename = os.path.basename(item)
                backup_path = os.path.join(backup_dir, f"{timestamp}_{basename}")
                if not dry_run:
                    if os.path.isdir(item):
                        shutil.copytree(item, backup_path)
                    else:
                        shutil.copy2(item, backup_path)
                results.append(f"  [BACKUP] {item} -> {backup_path}")
            except Exception as e:
                return False, f"Backup failed for {item}: {e}"

        # Delete
        if dry_run:
            kind = "DIR" if os.path.isdir(item) else "FILE"
            results.append(f"  [DRY-RUN] Would delete ({kind}): {item}")
        else:
            try:
                if os.path.isdir(item):
                    shutil.rmtree(item)
                    results.append(f"  [DELETED DIR]  {item}")
                else:
                    os.remove(item)
                    results.append(f"  [DELETED FILE] {item}")
            except Exception as e:
                return False, f"Delete failed for {item}: {e}"

    summary = "\n".join(results)
    mode = "DRY-RUN" if dry_run else "COMPLETE"
    return True, f"fs_delete {mode} ({len(targets)} item(s)):\n{summary}"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="MAF-Native Delete Utility — filesystem-agent TYPE1 action"
    )
    parser.add_argument(
        "--target",
        required=True,
        help="Path to the file or directory to delete."
    )
    parser.add_argument(
        "--pattern",
        default=None,
        help="Optional glob pattern (e.g. '*.log') to filter files inside --target directory."
    )
    parser.add_argument(
        "--backup-dir",
        default=None,
        dest="backup_dir",
        help="If provided, copies the target to this directory before deleting."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        dest="dry_run",
        help="Preview what would be deleted without making any changes."
    )

    args = parser.parse_args()

    success, message = delete_path(
        target=args.target,
        dry_run=args.dry_run,
        glob_pattern=args.pattern,
        backup_dir=args.backup_dir
    )
    print(message)
    sys.exit(0 if success else 1)
