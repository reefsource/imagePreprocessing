#! /bin/bash

supportedCameraModels="GoPro HERO5 Black"
# DNG_CONVERTER_PATH="/Applications/Adobe\ DNG\ Converter.app/Contents/MacOS/Adobe\ DNG\ Converter -l -u"
# DNG_CONVERTER_PATH="wine64 /root/.wine/drive_c/Program\ Files\ \(x86\)/Adobe/Adobe\ DNG\ Converter.exe -l -u"
DNG_CONVERTER_PATH="wine /AdobeDNGConverter.exe -l -u"

# Get the name of the file, remove extenstion
# fileName=$(echo $1 | awk '{id=index($0,"."); print substr($0,0,id-1)}')

inputFileName=$1

fileName=$(echo "${inputFileName%.*}")
echo "Analyzing file: $inputFileName"
echo "File base name: $fileName"

cameraModel=$(exiftool -UniqueCameraModel -s $1 | awk '{id=index($0,":"); print substr($0,id+2)}')
#exiftool -UniqueCameraModel -s $1


if [ "$cameraModel" = "$supportedCameraModels" ]; then
    echo "Detected image from $cameraModel camera."

    jsonFileName=$fileName'.json'
    exiftool -json -c "%+.6f" -d "%Y-%m-%dT%H:%M:%S%Z" $1 > $jsonFileName
    jq '.[0]' $jsonFileName > $jsonFileName".tmp"
    mv $jsonFileName".tmp" $jsonFileName

    # Create a DNG file from GoPro RAW
    START=$(date +%s)
    echo -n "Converting GPR to DNG ... "
    eval $DNG_CONVERTER_PATH $1
    END=$(date +%s)
    DIFF=$((END - START))
    echo "Done! $DIFF sec"

    # Generate preview and thumbnail images
    # exiftool -ThumbnailTIFF -b $fileName".dng" > $fileName"_thumb.tiff"
    exiftool -PreviewImage -b $fileName".dng" > $fileName"_preview.jpg"

    # Check the orientation of the image
    orientation=$(exiftool -Orientation $inputFileName | awk '{id=index($0,":"); print substr($0,id+2)}')
    if [ "$orientation" = "Mirror horizontal" ]; then
        echo "Flipping image orientation"
        convert $fileName"_preview.jpg" -flop $fileName"_preview.jpg"
    fi

    # Raw DNG file is large ~70MB so we don't want to store it.
    rm $fileName".dng"

else
    echo "$cameraModel not supported"
fi
