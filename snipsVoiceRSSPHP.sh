#!/usr/bin/env bash
cd "${0%/*}"
# Shell script to use Google Translator as Snips TTS
# Install mpg123: sudo apt-get install mpg123

source ./config.sh

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
googleVoice="$languageCode"-"$voice"
text=${text//\'/\\\'}
md5string="$text""$googleVoice""$sampleRate"
hash="$(echo -n "$md5string" | md5sum | sed 's/ .*$//')"

cachefile="$cache""$hash".wav
downloadFile="/tmp/""$hash"

if [[ ! -f "$cachefile" ]]; then
    php voice.php "$apiKey" "$languageCode" "$text" "$downloadFile.mp3"
    mpg123 --quiet --wav "$cachefile" "$downloadFile".mp3
    rm "$downloadFile.mp3"
fi

cp "$cachefile" "$outfile"
