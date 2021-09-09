<img src="https://github.com/KangRuiYu/voice_scribe/blob/aa04a8135edbc159d65bb11829c596333075ec05/assets/icon.png" width="128"> 

# Voice Scribe

## Demo

<img src="https://user-images.githubusercontent.com/48875810/132606729-7db6f3b5-085e-47ce-bf43-026fa3290a21.gif" width="320">

https://user-images.githubusercontent.com/48875810/132607368-e7362195-63eb-4d3f-8f1c-4b1edf2be8b9.mov

Audio used in demo **(2:40)**: [Lec 1 | MIT 9.00SC Introduction to Psychology, Spring 2011](https://www.youtube.com/watch?v=2fbrl6WoIyo&t=320s)

Audio license: [Creative Commons BY-NC-SA](https://ocw.mit.edu/terms/)

## About

Audio recording and playback app that transcribes speech in real time. All transcription is done offline and on device. This means that transcription speed and performance may vary depending on your device's hardware. The only time when a network connection is made is to download the transcription model on first launch. Currently only Android devices are supported.

Voice Scribe makes use of the [Vosk API](https://github.com/alphacep/vosk-api) for transcription.

## Installing (Android)

Pre-built .apk files are available in the [releases page](https://github.com/KangRuiYu/voice_scribe/releases).
Only Android devices running Android 5 or newer are supported.

1. Download the .apk file from the latest release.
2. (Optional) Check the file hash against the one available to verify integrity.
3. Open the .apk file on an Android device and follow install instructions.

## Building (Android)

You can also build the .apk yourself if you do not want to use the supplied ones.

1. Download the Flutter SDK, following the [official instructions](https://flutter.dev/docs/get-started/install) based on your platform.
2. Download Andoird Studio, following the same documentation as before. Setting up a device and/or emulator should not be needed.
3. Copy the repository onto your device (ie. via <code>git clone https://github.com/KangRuiYu/voice_scribe.git</code>.
4. Open a terminal and navigate to the downloaded repository and run <code>flutter build apk</code>.
5. The output location of the .apk will be noted by the output of the previous command.
