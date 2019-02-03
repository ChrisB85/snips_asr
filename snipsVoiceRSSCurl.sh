#!/usr/bin/env bash
cd "${0%/*}"
# Shell script to use VoiceRSS as Snips TTS
# Install mpg123: sudo apt-get install mpg123

./config.sh

# Edit /etc/snips.toml
# Set "customtts" as snips-tts provider
#
# Add as customtts f.ex.: command = ["/home/pi/snipsWavenet.sh", "%%OUTPUT_FILE%%", "%%LANG%%", "PL", "%%TEXT%%"]
# Change "PL" to another language country code, "GB" per exemple for a british voice
# Restart snips: systemctl restart snips-*

outfile="$1"
lang="$2"
country="$3"
text="$4"
sampleRate="44khz_16bit_stereo"

mkdir -pv "$cache"

languageCode="$lang"-"$country"
googleVoice="$languageCode"-"$voice"
text=${text//\'/\\\'}
md5string="$text""$googleVoice""$sampleRate"
hash="$(echo -n "$md5string" | md5sum | sed 's/ .*$//')"

cachefile="$cache""$hash".wav
downloadFile="/tmp/""$hash"

if [[ ! -f "$cachefile" ]]; then
    curl -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
    -X POST \
    --data-urlencode "key=$apiKey" \
    --data-urlencode "src=$text" \
    --data-urlencode "hl=$languageCode" \
    --data-urlencode "r=0" \
    --data-urlencode "c=mp3" \
    --data-urlencode "f=$sampleRate" \
    --data-urlencode "ssml=false" \
    --data-urlencode "b64=false" \
    "https://api.voicerss.org/" > "$downloadFile.mp3"

    mpg123 --quiet --wav "$cachefile" "$downloadFile".mp3
    rm "$downloadFile.mp3"
fi

cp "$cachefile" "$outfile"
