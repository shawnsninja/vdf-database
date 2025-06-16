#!/bin/bash
# Script to convert all DOCX files to Markdown

echo "Converting all DOCX files to Markdown..."

# Find all .docx files and convert them
find . -name "*.docx" -type f | while read -r file; do
    # Get the directory and filename without extension
    dir=$(dirname "$file")
    basename=$(basename "$file" .docx)
    
    # Create markdown filename
    mdfile="$dir/$basename.md"
    
    echo "Converting: $file -> $mdfile"
    
    # The actual conversion will be done via MCP
    # This is a placeholder for the command structure
done

echo "Conversion complete!"