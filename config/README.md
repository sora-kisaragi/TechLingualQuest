# Configuration

This directory contains configuration files for different environments and services.

## Structure

```
config/
├── environments/             # Environment-specific configs
│   ├── development.json      # Development environment
│   ├── staging.json          # Staging environment
│   └── production.json       # Production environment
├── firebase/                 # Firebase configurations
│   ├── dev-firebase-config.json
│   ├── staging-firebase-config.json
│   └── prod-firebase-config.json
├── api/                      # API configurations
│   ├── endpoints.json        # API endpoint URLs
│   └── api_keys.template.json # API key template (no real keys)
└── app/                      # App-specific configs
    ├── features.json         # Feature flags
    ├── themes.json           # Theme configurations
    └── constants.json        # App constants
```

## Guidelines

- **Never commit sensitive data** (API keys, passwords, secrets)
- Use template files for sensitive configurations
- Environment-specific configs should be clearly labeled
- Use JSON or YAML format for configuration files
- Document all configuration options
- Validate configuration files before deployment

## Security Notes

- Add `*.key`, `*secret*`, `*password*` to .gitignore
- Use environment variables for sensitive data in production
- Provide template files with example values
- Use different configurations for each environment