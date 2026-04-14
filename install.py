#!/usr/bin/env python3
import os
import sys
import shutil
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Install ARC-7 skills and agents into a target tool directory.")
    parser.add_argument("--target", required=True, help="Target tool directory (e.g., .opencode, .agents, or a custom path)")
    parser.add_argument("--mode", choices=["copy", "symlink"], default="copy", 
                        help="Installation mode: 'copy' (default, safe for all OS) or 'symlink' (dev mode)")
    
    args = parser.parse_args()
    target_dir = Path(args.target).resolve()
    repo_root = Path(__file__).parent.resolve()
    
    print(f"Installing ARC-7 to {target_dir} (Mode: {args.mode})...")
    
    # Define source to destination mappings
    mappings = {
        "skills/ARC-7": "skills/ARC-7",
        "commands/ARC-7.md": "commands/ARC-7.md",
        "agents/ARC-7": "agent/ARC-7" # Tool agent folders are usually singular 'agent'
    }

    try:
        for src_rel, dst_rel in mappings.items():
            src_path = repo_root / src_rel
            dst_path = target_dir / dst_rel
            
            if not src_path.exists():
                print(f"  [!] Source not found: {src_path}")
                continue
                
            # Ensure parent directories exist
            dst_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Clean up existing
            if dst_path.is_symlink() or dst_path.exists():
                if dst_path.is_dir() and not dst_path.is_symlink():
                    shutil.rmtree(dst_path)
                else:
                    dst_path.unlink()
            
            if args.mode == "symlink":
                try:
                    # Create relative symlink
                    rel_target = os.path.relpath(src_path, dst_path.parent)
                    os.symlink(rel_target, dst_path)
                    print(f"  [+] Symlinked: {dst_rel} -> {rel_target}")
                except OSError as e:
                    print(f"  [!] Symlink failed (requires admin on Windows): {e}")
                    print("      Falling back to copy mode...")
                    args.mode = "copy" # Fallback for the rest of the loop
                    
            if args.mode == "copy":
                if src_path.is_dir():
                    shutil.copytree(src_path, dst_path)
                else:
                    shutil.copy2(src_path, dst_path)
                print(f"  [+] Copied: {dst_rel}")

        print("\n✅ ARC-7 installation complete!")
        print(f"  Target: {target_dir}")
        print("\nNext steps:")
        print("  1. Check model-mappings.example.json to configure your AI provider.")
        print("  2. Restart your agent tool to load the /ARC-7 command.")
        
    except Exception as e:
        print(f"\n❌ Installation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
