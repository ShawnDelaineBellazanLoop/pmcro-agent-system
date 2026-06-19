# Jira-Agent — JQL Patterns Reference
schema_version: "2.0"
agent: jira-agent

## Common Patterns

### Open issues in project
```jql
project = {{project_key}} AND statusCategory != Done ORDER BY created DESC
```

### Issues assigned to current user
```jql
project = {{project_key}} AND assignee = currentUser() AND statusCategory != Done
```

### Bulk close — all open in project
```jql
project = {{project_key}} AND statusCategory in (new, indeterminate)
```

### Issues updated in last N days
```jql
project = {{project_key}} AND updated >= -{{days}}d ORDER BY updated DESC
```

### Issues by label
```jql
project = {{project_key}} AND labels = {{label}}
```

## Safety Rules (JIRA-002)
- NEVER inject raw user strings into JQL without escaping
- Escape single quotes: replace `'` with `\'`
- Project keys MUST be resolved from getVisibleJiraProjects — never hardcoded
- cloudId MUST be resolved from getAccessibleAtlassianResources — never hardcoded
