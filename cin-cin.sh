!/bin/bash

main() {
    source "${BASH_SOURCE%/*}/settings2.cnf"

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

   duration=$(getSequenceFrameRate $camera)
   for file in $(ls -1 $workingDir$camera-*.$format); do
      echo "file '$file'" >> $workingDir$camera.txt
      echo duration $duration >> $workingDir$camera.txt
   done
}

createSequence() {
    camera=$1
    /usr/bin/ffmpeg -f concat -i $workingDir$camera.txt -vsync vfr -pix_fmt yuv420p $workingDir$camera-output.mp4 -y
}

publish() {
    camera=$1
    /bin/mv $workingDir$camera-output.mp4 $publishedDir/$camera.mp4
}

cleanUp() {
    camera=$1
    /bin/rm $workingDir$camera.txt
}

getLastImage() {
    /bin/ls -r $workingDir$1*.$format | head -1
}

getSequenceFrameRate() {
    camera=$1
    /usr/bin/bc -l <<< "scale=2; $videoLength/$(getSequenceCount $camera)" | /usr/bin/awk '{printf "%.4f\n", $0}'
}

getSequenceCount() {
    camera=$1
    /bin/ls $workingDir$camera*.$format | /usr/bin/wc -l
}

main "$@"
