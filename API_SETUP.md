# API Key Setup Instructions

## Google Maps API Key Configuration

The Google Maps API key is stored in separate configuration files that are not committed to version control for security reasons.

### Setup Steps:

#### For iOS Development:

1. Copy the iOS template configuration file:
   ```bash
   cp ios/Runner/Config.template.plist ios/Runner/Config.plist
   ```

2. Edit `ios/Runner/Config.plist` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual Google Maps API key:
   ```xml
   <key>GOOGLE_MAPS_API_KEY</key>
   <string>YOUR_ACTUAL_API_KEY_HERE</string>
   ```

#### For Android Development:

1. Copy the Android template configuration file:
   ```bash
   cp android/secrets.template.properties android/secrets.properties
   ```

2. Edit `android/secrets.properties` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual Google Maps API key:
   ```properties
   GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
   ```

### Important Notes:

- Never commit the `Config.plist` or `secrets.properties` files to version control
- Each developer needs to create their own configuration files
- Keep your API keys secure and never share them publicly
- The template files should be committed to help other developers set up their environment
- Both files are automatically ignored by Git via `.gitignore`

### How It Works:

- **iOS**: The app automatically loads the API key from `Config.plist` during startup
- **Android**: The build system injects the API key from `secrets.properties` into the AndroidManifest.xml during compilation

If the configuration files are missing or the keys are not found, you'll see warnings and the Google Maps functionality may not work properly.
