#!/bin/bash
################################################################################
# Script to activate GitHub Actions status badges after workflows are committed
################################################################################

echo "Activating GitHub Actions status badges..."

# Function to uncomment badges in a file
uncomment_badges() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "Updating $file..."
        # Remove HTML comment wrapper around badges
        sed -i.bak '/<!-- $/,/-->$/c\
<!-- Badges activated automatically -->' "$file"
        
        # Uncomment the actual badge lines
        sed -i '' 's/^<!-- \(.*badge.*\).*-->$/\1/' "$file"
        
        echo "✅ Updated $file"
    else
        echo "⚠️  File not found: $file"
    fi
}

# Activate badges in main README
uncomment_badges "../../README.md"

# Activate badges in workflow README  
uncomment_badges "README.md"

echo ""
echo "🎉 Badge activation complete!"
echo "📝 Don't forget to commit these changes after verifying the workflows work."