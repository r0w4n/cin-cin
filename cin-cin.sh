#!/bin/bash

main() {
    source "${BASH_SOURCE%/*}/settings.cnf"

    for camera in "${cameras[@]}"
    do
      	createSequenceFile $camera
        createSequence $camera
        publish $camera
        cleanUp $camera
    done
}

createSequenceFile() {
   echo -e "file '$(getLastImage $camera)'\nduration 5" >> $workingDir$camera.txt

   for file in $(find $workingDir -type f -newermt "$(/bin/date +"%Y-%m-%d") 08:00:00" ! -newermt now -name $camera-*.$format | sort -n); do
      echo "file '$file'" >> $workingDir$camera.txt
      echo duration $duration >> $workingDir$camera.txt
   done
}

createSequence() {
    /usr/bin/ffmpeg -f concat -i $workingDir$camera.txt -vsync vfr -pix_fmt yuv420p $workingDir$camera-output.mp4 -y
}

publish() {
    /bin/mv $workingDir$camera-output.mp4 $publishedDir/$camera.mp4
}

cleanUp() {
    /bin/rm $workingDir$camera.txt
}

getLastImage() {
    /bin/ls -r $workingDir$1*.$format | head -1
}

main "$@"
