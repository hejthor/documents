#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p "./output"

# Loop through all .odt files in resources/templates/
for template in resources/templates/*.odt; do
  # Get the template filename without path and extension
  template_name=$(basename "$template" .odt)

  # Loop through .md files in the input directory
  for md_file in ./input/*.md; do
    # Convert the markdown file to .odt using the current template
    pandoc "$md_file" \
      --reference-doc "$template" \
      --metadata=plantumlPath:"./resources/PlantUML 1.2024.8.jar" \
      --lua-filter="./resources/filters/include-files.lua" \
      --lua-filter="./resources/filters/diagram-generator.lua" \
      --lua-filter="./resources/filters/pagebreak.lua" \
      --citeproc \
      --bibliography ./input/bibliographies/*.bib \
      --csl "./resources/styles/apa-eu.csl" \
      -o "output/$(basename "$md_file" .md) ($template_name).odt"
  done
done

# Convert .odt to .pdf using LibreOffice
for odt_file in output/*.odt; do
  pdf_file="output/$(basename "$odt_file" .odt).pdf"
  soffice --headless --convert-to pdf "$odt_file" --outdir "$(dirname "$pdf_file")"
done