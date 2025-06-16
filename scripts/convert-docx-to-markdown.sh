#!/bin/bash

# Script to convert DOCX files to Markdown
# Uses the unzip method to extract text from DOCX files

echo "Converting DOCX files to Markdown..."

# Function to convert a single DOCX file
convert_docx() {
    local input_file="$1"
    local output_file="$2"
    
    echo "Converting: $input_file"
    
    # Extract text from DOCX using unzip
    unzip -p "$input_file" word/document.xml | \
    sed 's/<[^>]*>/ /g' | \
    sed 's/&lt;/</g' | \
    sed 's/&gt;/>/g' | \
    sed 's/&amp;/\&/g' | \
    sed 's/&quot;/"/g' | \
    sed "s/&apos;/'/g" | \
    tr -s ' ' | \
    fold -s -w 80 > "$output_file"
    
    # Add header to the file
    local filename=$(basename "$input_file" .docx)
    echo -e "# $filename\n\n$(cat "$output_file")" > "$output_file"
}

# Convert overview files
convert_docx "0. VDF Database Overview.docx" "docs/markdown/overview/vdf-database-overview.md"
convert_docx "2025-05-17 - checklist.docx" "docs/markdown/overview/database-checklist.md"
convert_docx "_ IMPORTANT_ Linking Tables Needed.docx" "docs/markdown/overview/linking-tables-needed.md"

# Convert Module 1 files
for file in "1. User & Content Infrastructure Module"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        # Clean filename for markdown
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-1/$clean_name.md"
    fi
done

# Convert Module 2 files  
for file in "2. Core Trail Hierarchy Module"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-2/$clean_name.md"
    fi
done

# Convert Module 3 files
for file in "3. Geographical Context Module"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-3/$clean_name.md"
    fi
done

# Convert Module 4 base files
for file in "4. Waypoint Detail Modules"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-4/$clean_name.md"
    fi
done

# Convert Module 4a files
for file in "4a. Waypoint - Accommodations"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-4a/$clean_name.md"
    fi
done

# Convert Module 4b files
for file in "4b. Waypoint - attractions"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-4b/$clean_name.md"
    fi
done

# Convert Module 4c files
for file in "4c. Waypoint - transportation"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-4c/$clean_name.md"
    fi
done

# Convert Module 4d files
for file in "4d. Waypoint - Events"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-4d/$clean_name.md"
    fi
done

# Convert Module 5 files
for file in "5. Dynamic Conditions Module"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-5/$clean_name.md"
    fi
done

# Convert Module 6 files
for file in "6. User Interaction Module"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-6/$clean_name.md"
    fi
done

# Convert Module 7 files
for file in "7. Curated Itinerary Module"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-7/$clean_name.md"
    fi
done

# Convert Module 8 files
for file in "8. Editorial"/*.docx; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .docx)
        clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        convert_docx "$file" "docs/markdown/module-8/$clean_name.md"
    fi
done

echo "Conversion complete! Check docs/markdown/ for the converted files."