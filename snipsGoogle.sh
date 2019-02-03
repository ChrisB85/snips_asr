#!/usr/bin/env bash
cd "${0%/*}"
# Shell script to use VoiceRSS as Snips TTS
# Install mpg123: sudo apt-get install mpg123
# Set your cache path
cache="/usr/share/snips/tts_cache/"

# API key
apiKey="bbb1ba806a254ca5882a8f84b296b9c4"
# Edit /etc/snips.toml
# Set "customtts" as snips-tts provider
#
# Add as customtts f.ex.: command = ["/home/pi/snipsWavenet.sh", "%%OUTPUT_FILE%%", "%%LANG%%", "%%TEXT%%"]
# Change "PL" to another language country code, "GB" per exemple for a british voice
# Restart snips: systemctl restart snips-*

outfile="$1"
lang="$2"
text="$3"

mkdir -pv "$cache"

languageCode="$lang"-"$country"
#echo $languageCode
googleVoice="$languageCode"-"$voice"
#echo $googleVoice
text=${text//\'/\\\'}
#echo $text
md5string="$text""$lang"
hash="$(echo -n "$md5string" | md5sum | sed 's/ .*$//')"

cachefile="$cache""$hash".wav
downloadFile="/tmp/""$hash"

if [[ ! -f "$cachefile" ]]; then
    curl -G -v \
    -A "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.125 Safari/537.36" \
    --data-urlencode "ie=UTF-8" \
    --data-urlencode "client=tw-ob" \
    --data-urlencode "q=$text" \
    --data-urlencode "tl=$lang" \
    --data-urlencode "total=1" \
    --data-urlencode "idx=0" \
    --data-urlencode "textlen=1" \
    "https://translate.google.com/translate_tts" > "$downloadFile.mp3"

    mpg123 --quiet --wav "$cachefile" "$downloadFile".mp3
    rm "$downloadFile.mp3"
fi

cp "$cachefile" "$outfile"
