alias t='tmux new-session -A -s remote'
alias mp3='youtube-dlc -x --audio-format mp3 --audio-quality 0'
alias mp3p='youtube-dlc -x --audio-format mp3 --audio-quality 0 -o "%(playlist_index)s-%(title)s.%(ext)s" --yes-playlist'
alias megadl='docker run --rm -v $(pwd):$(pwd)  -w $(pwd) megatools:local dl '
