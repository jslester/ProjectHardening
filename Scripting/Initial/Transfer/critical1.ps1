$PlayWav = New-Object System.Media.SoundPlayer
$PlayWav.SoundLocation = 'C:\Users\Robert\Desktop\critical\youGotmail.wav'
$PlayWav.PlaySync()
echo "Sound Played"