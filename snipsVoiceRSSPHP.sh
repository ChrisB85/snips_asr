#!/usr/bin/env bash
cd "${0%/*}"
# Shell script to use Google Wavenet as Snips TTS
# Install mpg123: sudo apt-get install mpg123
# Install Google SDK: https://cloud.google.com/text-to-speech/docs/quickstart-protocol.
# Follow point 6. to initialize the sdk after creating your service account. There is an apt-get install procedure!!
# Set your cache path
cache="/usr/share/snips/tts_cache/"

# API key
apiKey="bbb1ba806a254ca5882a8f84b296b9c4"
# Edit /etc/snips.toml
# Set "customtts" as snips-tts provider
#
# Add as customtts: command = ["/home/pi/ProjectAlice/shell/snipsWavenet.sh", "%%OUTPUT_FILE%%", "%%LANG%%", "PL", "%%TEXT%%"]
# Change "PL" to another language country code, "GB" per exemple for a british voice
# Restart snips: systemctl restart snips-*

outfile="$1"
lang="$2"
country="$3"
text="$4"
sampleRate="44100"

mkdir -pv "$cache"

languageCode="$lang"-"$country"
echo $languageCode
googleVoice="$languageCode"-"$voice"
echo $googleVoice
text=${text//\'/\\\'}
echo $text
md5string="$text""$googleVoice""$sampleRate"
hash="$(echo -n "$md5string" | md5sum | sed 's/ .*$//')"

cachefile="$cache""$hash".wav
echo $cachefile
downloadFile="/tmp/""$hash"
echo "$downloadFile.mp3"
#exit

if [[ ! -f "$cachefile" ]]; then
    php voice.php "$apiKey" "$languageCode" "$text" "$downloadFile.mp3"
#    curl -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
#    -H "Content-Type: application/json; charset=utf-8" \
#    --data "{
#      'input':{
#        'text': '$text'
#      },
#      'voice':{
#        'languageCode':'$languageCode',
#        'name':'$googleVoice',
#        'ssmlGender':'$gender'
#      },
#      'audioConfig':{
#        'audioEncoding':'MP3',
#        'pitch': '0.00',
#        'speakingRate': '1.00'
#      }
#    }" "https://texttospeech.googleapis.com/v1beta1/text:synthesize" > "$downloadFile"

#    sed -i 's/audioContent//' "$downloadFile" && \
#    tr -d '\n ":{}' < "$downloadFile" > "$downloadFile".tmp && \
#    base64 "$downloadFile".tmp --decode > "$downloadFile".mp3

    mpg123 --quiet --wav "$cachefile" "$downloadFile".mp3
#    rm "$downloadFile" && \
#    rm "$downloadFile".tmp && \
    rm "$downloadFile.mp3"
fi

cp "$cachefile" "$outfile"
