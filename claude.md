# GymBuddy - Claude Guidelines

## Bash Guidelines

### IMPORTANT: Avoid commands that cause output buffering issues

- DO NOT pipe output through `head`, `tail`, `less`, or `more`
- These commands can cause buffering issues and incomplete output
- Instead, use the Read tool with `limit` and `offset` parameters for file reading
- For command output, capture the full output and process it directly

### Examples

**Bad:**
```bash
cat file.txt | head -n 50
git log | head -20
```

**Good:**
```bash
# Use Read tool with limit parameter instead
# Or capture full output and let Claude process it
git log --oneline -20
```
