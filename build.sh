#!/bin/bash
echo "📦 Starting build process..."
# Create a distribution directory
rm -rf dist
mkdir -p dist/tools
# Copy the core tools into the tools directory
cp manus-core dist/tools/
cp manus_bot.py dist/tools/
# Create the final compressed package
(cd dist && tar -czvf mukh-ide-tools.tar.gz tools)
echo "✅ Build complete! Package is at: dist/mukh-ide-tools.tar.gz"
