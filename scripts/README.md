# Scripts

This directory contains build scripts, deployment scripts, and utility scripts for the TechLingual Quest project.

## Structure

```
scripts/
├── build/                    # Build-related scripts
│   ├── build_android.sh      # Android build script
│   ├── build_ios.sh          # iOS build script
│   └── build_web.sh          # Web build script
├── deploy/                   # Deployment scripts
│   ├── deploy_staging.sh     # Staging deployment
│   └── deploy_production.sh  # Production deployment
├── setup/                    # Setup and installation scripts
│   ├── setup_dev.sh          # Development environment setup
│   └── install_deps.sh       # Install dependencies
└── utils/                    # Utility scripts
    ├── cleanup.sh            # Clean build artifacts
    ├── generate_icons.sh     # Generate app icons
    └── backup_db.sh          # Database backup
```

## Guidelines

- Make scripts executable (`chmod +x script_name.sh`)
- Include error handling and validation
- Document script parameters and usage
- Use consistent naming conventions
- Test scripts in different environments

## Usage

```bash
# Make script executable
chmod +x scripts/build/build_android.sh

# Run script
./scripts/build/build_android.sh
```