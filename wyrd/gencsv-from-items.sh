#!/bin/bash

# generates csv for all given asset files

ipath="$1"
back="$2"
file=$(basename "$1")
out=""


if [ -z "$file" ]; then
    echo "Usage:"
    echo "gencsv-from-items.sh path [back]"
    echo "where 'path' is path to image files"
    echo "you can also use: path/*.png to select only given filetypes"
    echo
    echo "where 'back' is optional part of filename"
    echo "which is present in back filename"
    echo
    echo "example:"
    echo "gencsv-from-items.sh images back"
    echo "in images, we have:"
    echo "01card.png"
    echo "01card-back.png"
    echo
    echo "In csv, there is workaround for back images used."
    exit 1
fi

objs=$(ls "$ipath/")

found=$(echo "$objs" | wc -l)

echo -e "Found $found matching objects.\n"

out="@card,image,BACK,+,image\n"
frontfile=""
backfile=""

for line in $(echo "$objs"); do

    if [[ "$back" != "" && "$line" == *"$back"* ]]; then
        backfile="$line"
    else
        if [[ "$frontfile" != "" ]]; then
            out+=",$frontfile,\n"
            echo "front file without back: $frontfile"
        fi
        frontfile="$line"
    fi

    
    if [[ "$frontfile" != "" && "$backfile" != "" ]]; then
        out+=",$frontfile,y,@card,$backfile\n"
        echo "have front and back: $frontfile, $backfile"
        frontfile=""
        backfile=""
    fi
    
    #if [ $i -ne $found ]; then
        #out+="\n\n"
    #fi
    ((i+=1))
done

# solve problem with last item
if [[ "$back" != "" && "$backfile" != "" ]]; then
    out+=",$frontfile,y,@card,$backfile\n"
    echo "have front and back: $frontfile, $backfile"
else
    out+=",$frontfile,\n"
    echo "front file without back: $frontfile"
fi


out=$(echo "$out" | tr -d '\n')

echo -e "$out" > $file.csv
echo "Generated $file.csv"
echo
echo "In inkscape:"
echo "  - import one of cards, resize it to card size (maybe slightly bigger for bleed), name object 'image'"
echo "  - create rectangle with final card size, name it 'card'"
