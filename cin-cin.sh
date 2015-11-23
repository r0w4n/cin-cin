
#!/bin/bash

main() {
    source settings.cnf

    for camera in "${cameras[@]}"
    do
      	createFirst $camera
        createSequence $camera
        joinVideo $camera
        publish $camera
        cleanUp $camera
    done
}

createSequence() {
    camera=$1
    /usr/bin/ffmpeg -framerate $(getSequenceFrameRate) -pattern_type glob -i "$workingDir$camera-*.$format" -c:v libx264 -r 30 -pix_fmt yuv420p -y $workingDir$camera-sequence.mp4
}

createFirst() {
    camera=$1
    /usr/bin/ffmpeg -loop 1 -i $(getLastImage $camera) -c:v libx264 -t 5 -r 30 -pix_fmt yuv420p -y $workingDir$camera-first.mp4
}

joinVideo() {
    camera=$1
    /usr/bin/MP4Box $workingDir$camera-first.mp4 -cat $workingDir$camera-sequence.mp4 -out $workingDir$camera-output.mp4
}

publish() {
    camera=$1
    /bin/mv $workingDir$camera-output.mp4 $publishedDir/$camera.mp4
}

cleanUp() {
    camera=$1
    /bin/rm $workingDir$camera-sequence.mp4
    /bin/rm $workingDir$camera-first.mp4
}

getLastImage() {
    /bin/ls -r $workingDir$1*.$format | head -1
}

getSequenceFrameRate() {
    /usr/bin/bc <<< "scale=2; $(getSequenceCount)/$videoLength"
}

getSequenceCount() {
    camera=$1
    /bin/ls $workingDir$camera*.$format | /usr/bin/wc -l
}

main "$@"

