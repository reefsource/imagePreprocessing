#! /bin/bash

supportedCameraModels="GoPro HERO5 Black"
# DNG_CONVERTER_PATH="/Applications/Adobe\ DNG\ Converter.app/Contents/MacOS/Adobe\ DNG\ Converter -l -u"
# DNG_CONVERTER_PATH="wine64 /root/.wine/drive_c/Program\ Files\ \(x86\)/Adobe/Adobe\ DNG\ Converter.exe -l -u"
DNG_CONVERTER_PATH="wine /AdobeDNGConverter.exe -l -u"

# Get the name of the file, remove extenstion
# fileName=$(echo $1 | awk '{id=index($0,"."); print substr($0,0,id-1)}')

inputFileName=$1

AWS_PATH=$(dirname $inputFileName)
FILE_NAME=$(echo "${inputFileName##*/}")
FILE_NAME=$(echo "${FILE_NAME%.*}")

echo "Analyzing file: $inputFileName"
echo "AWS path: $AWS_PATH"
echo "File name: $FILE_NAME"

aws s3 cp $inputFileName ~/$FILE_NAME.GPR


cameraModel=$(exiftool -UniqueCameraModel -s ~/$FILE_NAME.GPR | awk '{id=index($0,":"); print substr($0,id+2)}')



if [ "$cameraModel" = "$supportedCameraModels" ]; then
    echo "Detected image from $cameraModel camera."

    jsonFileName=~/$FILE_NAME'.json'
    exiftool -json ~/$FILE_NAME > $jsonFileName

    # Create a DNG file from GoPro RAW
    START=$(date +%s)
    echo -n "Converting GPR to DNG ... "
    eval $DNG_CONVERTER_PATH ~/$FILE_NAME.GPR
    END=$(date +%s)
    DIFF=$((END - START))
    echo "Done! $DIFF sec"

    # Generate preview and thumbnail images
    exiftool -ThumbnailTIFF -b ~/$FILE_NAME".dng" > ~/$FILE_NAME"_thumb.tiff"

    # For some the preview image is flipped L-R direction
    exiftool -PreviewImage -b ~/$FILE_NAME".dng" > ~/$FILE_NAME"_preview.jpg"
    convert ~/$FILE_NAME"_preview.jpg" -flop ~/$FILE_NAME"_preview.jpg"

    # Raw DNG file is large ~70MB so we don't want to store it.D
    # rm $fileName".dng"

else
    echo "$cameraModel not supported"
fi

aws s3 cp ~/$FILE_NAME"_preview.jpg" $AWS_PATH/$FILE_NAME"_preview.jpg"
aws s3 cp ~/$FILE_NAME"_thumb.tiff" $AWS_PATH/$FILE_NAME"_thumb.tiff"
aws s3 cp ~/$FILE_NAME.json $AWS_PATH/$FILE_NAME.json
