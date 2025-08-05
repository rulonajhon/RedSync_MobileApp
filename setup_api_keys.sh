#!/bin/bash

# API Key Setup Script for RedSync Mobile App
# This script helps developers set up their API key configuration files

echo "🔧 Setting up API key configuration files..."

# Setup iOS configuration
if [ ! -f "ios/Runner/Config.plist" ]; then
    echo "📱 Creating iOS Config.plist from template..."
    cp ios/Runner/Config.template.plist ios/Runner/Config.plist
    echo "✅ Created ios/Runner/Config.plist"
    echo "⚠️  Please edit ios/Runner/Config.plist and add your Google Maps API key"
else
    echo "📱 iOS Config.plist already exists"
fi

# Setup Android configuration
if [ ! -f "android/secrets.properties" ]; then
    echo "🤖 Creating Android secrets.properties from template..."
    cp android/secrets.template.properties android/secrets.properties
    echo "✅ Created android/secrets.properties"
    echo "⚠️  Please edit android/secrets.properties and add your Google Maps API key"
else
    echo "🤖 Android secrets.properties already exists"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit ios/Runner/Config.plist and replace YOUR_GOOGLE_MAPS_API_KEY_HERE with your actual API key"
echo "2. Edit android/secrets.properties and replace YOUR_GOOGLE_MAPS_API_KEY_HERE with your actual API key"
echo "3. Run 'flutter pub get' to install dependencies"
echo "4. Run 'flutter run' to start the app"
echo ""
echo "🔒 Security reminder: Never commit these files to version control!"
