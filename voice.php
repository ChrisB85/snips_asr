<?php
require_once('./voicerss_tts.php');

$apiKey = (string)$argv[1];
$language = (string)$argv[2];
$text = (string)$argv[3];
$outFile = (string)$argv[4];
//var_dump($argv);
//exit;

$tts = new VoiceRSS;
$voice = $tts->speech([
    'key' => $apiKey,
    'hl' => $language,
    'src' => $text,
    'r' => '0',
    'c' => 'mp3',
    'f' => '44khz_16bit_stereo',
    'ssml' => 'false',
    'b64' => 'false'
]);

file_put_contents($outFile, $voice);
?>
