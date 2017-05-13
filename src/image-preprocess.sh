#! /bin/bash

supportedCameraModels="GoPro HERO5 Black"
# DNG_CONVERTER_PATH="/Applications/Adobe\ DNG\ Converter.app/Contents/MacOS/Adobe\ DNG\ Converter -l -u"
# DNG_CONVERTER_PATH="wine64 /root/.wine/drive_c/Program\ Files\ \(x86\)/Adobe/Adobe\ DNG\ Converter.exe -l -u"
DNG_CONVERTER_PATH="wine /AdobeDNGConverter.exe -l -u"

# Get the name of the file, remove extenstion
# fileName=$(echo $1 | awk '{id=index($0,"."); print substr($0,0,id-1)}')

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2

inputFileName=$3

fileName=$(echo "${inputFileName%.*}")
echo "Analyzing file: $3"
echo "File base name: $fileName"

aws s3 cp

cameraModel=$(exiftool -UniqueCameraModel -s $1 | awk '{id=index($0,":"); print substr($0,id+2)}')
#exiftool -UniqueCameraModel -s $1


if [ "$cameraModel" = "$supportedCameraModels" ]; then
    echo "Detected image from $cameraModel camera."

    jsonFileName=$fileName'.json'
    exiftool -json $1 > $jsonFileName

    # Create a DNG file from GoPro RAW
    START=$(date +%s)
    echo -n "Converting GPR to DNG ... "
    eval $DNG_CONVERTER_PATH $1
    END=$(date +%s)
    DIFF=$((END - START))
    echo "Done! $DIFF sec"

    # Generate preview and thumbnail images
    exiftool -ThumbnailTIFF -b $fileName".dng" > $fileName"_thumb.tiff"

    # For some the preview image is flipped L-R direction
    exiftool -PreviewImage -b $fileName".dng" > $fileName"_preview.jpg"
    convert $fileName"_preview.jpg" -flop $fileName"_preview.jpg"

    # Raw DNG file is large ~70MB so we don't want to store it.D
    # rm $fileName".dng"

else
    echo "$cameraModel not supported"
fi
