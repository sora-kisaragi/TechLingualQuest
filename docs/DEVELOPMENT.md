# Development Setup Guide

## Local Development Configuration

### Gradle Memory Settings

The project is configured with sensible defaults for both local development and CI/CD environments:

- **Local Development**: 2GB heap size (default in `android/gradle.properties`)
- **CI/CD Environment**: 4GB heap size (set via environment variables)

### Customizing Local Memory Settings

If you experience memory issues or crashes during local development, you can customize the Gradle heap size:

#### Option 1: Environment Variable (Recommended)
Set the `GRADLE_OPTS` environment variable before running Flutter commands:

```bash
# For smaller heap size (if experiencing crashes)
export GRADLE_OPTS="-Xmx1G -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m"
flutter build apk --debug

# For larger heap size (if build fails with OutOfMemoryError)
export GRADLE_OPTS="-Xmx3G -XX:MaxMetaspaceSize=768m -XX:ReservedCodeCacheSize=384m"
flutter build apk --release
```

#### Option 2: Local gradle.properties Override
Create a local `android/gradle.properties.local` file (git-ignored) with your preferred settings:

```properties
org.gradle.jvmargs=-Xmx1G -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m
```

Then copy it over the main file temporarily:
```bash
cp android/gradle.properties.local android/gradle.properties
# Run your build
flutter build apk --debug
# Restore original
git checkout android/gradle.properties
```

### Memory Recommendations by System

- **8GB RAM or less**: Use 1GB heap (`-Xmx1G`)
- **8-16GB RAM**: Use 2GB heap (default)
- **16GB+ RAM**: Can use 3GB+ heap if needed

### CI/CD vs Local Development

The CI/CD pipeline automatically uses higher memory settings (4GB heap) to ensure reliable builds in the cloud environment. Local developers keep the more conservative 2GB default to avoid system crashes.

## Troubleshooting

### Common Memory Issues

1. **OutOfMemoryError during build**: Increase heap size
2. **System becomes unresponsive**: Decrease heap size
3. **Build takes too long**: Try increasing heap size if system allows

### Android Build Commands

```bash
# Debug build (faster, smaller memory usage)
flutter build apk --debug

# Release build (slower, requires more memory)
flutter build apk --release

# Profile build (good middle ground)
flutter build apk --profile
```