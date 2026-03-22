# VHS Encoding

Digitizing VHS tapes via OBS using these instructions: https://obsproject.com/forum/threads/correct-settings-for-capturing-vhs-please-help-a-newbie.131241/

Recorded at 720x576 in 50 PAL, adding a noise suppression filter with Speex on -30 dB.

## deinterlacing with size change

```bash
ffmpeg -i recording.mp4 -vf "yadif=mode=1:parity=auto:deint=all,hqdn3d=1.5:1.5:6:6,scale=360:288" -r25 -c:v libx264 -crf 18 -preset slow -c:a copy recording_resized.mp4
```

## cutting without reencoding

```bash
ffmpeg -i recording_resized.mp4 -ss 00:01:41 -to 00:28:01 -c copy -avoid_negative_ts 1 vhs2-1.mp4
```
