#!/bin/bash

# export layers from svg files as pdf, at the end merge them to one pdf file

# dependencies: inkscape, 

file="$1"

# it is ment to be used with Countersheet inkscape extension
# but if your layers begins with word "layer" than change line below
layername="cs_layer"

# background is part of layername, if found,
# this layer is threated as background and is merged with
# all layers
background="background"

outdir="pdf"
combined="combined"

dpi=300

mkdir -p "$outdir/$combined"


if [ -z "$file" ]; then
    echo "Usage:"
    echo "export-pdf-from-layers.sh file.svg"
    echo "Exported files are written to pdf dir (created if needed)"
    exit 1
fi

layers=$(inkscape "$file" --query-all -X | grep "^$layername"| cut -d',' -f1 | sort)

found=$(echo "$layers" | wc -l)

echo -e "Found $found matching layers.\n"

for layer in $(echo "$layers"); do
    inkscape $file -i "$layer" -j -d $dpi -C -o "$outdir/$file-$layer.pdf"
done

echo "Exported layers as pdf/* pdf files."

echo "Merging..."

# look for background
for layer in $(echo "$layers"); do
    if [[ $layer == *"$background"* ]]; then
        echo "Found background: $layer"
        back="$layer"
    fi
done

if [[ ! -z "$back" ]]; then
    for layer in $(echo "$layers"); do
        if [[ $layer == *"$background"* ]]; then
            continue # skip adding background to background
        fi
        pdftk "$outdir/$file-$layer.pdf" background "$outdir/$file-$back.pdf" output "$outdir/$combined/$file-$layer.pdf"
    done
    
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=$file-final.pdf $outdir/$combined/$file-*.pdf
else
    # we do not combine with background
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=$file-final.pdf $outdir/$file-*.pdf

fi

