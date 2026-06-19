# Filesystem Agent — Dynamic Operations
**Version:** 4.6.3

## 🏗️ Dynamic Tool Pattern
To ensure 1:1 mirroring with future MCP integrations, all scripts must be 
**location-agnostic**. 

### The 'fs_zip' Protocol
Logic is no longer hardcoded to the 'S:/skills' path. The Planner must 
now provide the specific paths as arguments to the `fs_zip` script.

**Example Planner Dispatch:**
- `domain_action: fs_zip`
- `params: { "source": "S:/skills/git-agent", "output": "S:/backups/git-agent.zip" }`

This allows the same script to handle vault backups, individual skill 
packaging, and log archiving without code changes.