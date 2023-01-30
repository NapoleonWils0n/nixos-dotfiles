#!/bin/sh

# sauron - w3m

# current link under cursor in w3m
url="${W3M_CURRENT_LINK}"   

if [ ! -z "${url}" ]; then
   result=$(echo "${url}" | \
            grep -oP '(?<=google.com\/url\?q=)[^&]*(?=&)' \
            | sed -e "s/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g" | xargs -0 echo -e)
   [ ! -z "${result}" ] && url="${result}"
else
    url="${W3M_URL}"
fi

# mpd and taskspooler
audio() {
      ts pinch -i "${url}" 1>/dev/null 
}

open_link() {
      xdg-open "${url}"
}

# youtube-dl and taskspooler
download() {
      ts \
      yt-dlp -f 'bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best' \
      --restrict-filenames \
      --no-playlist \
      --ignore-config \
       -o "${HOME}/Downloads/%(title)s.%(ext)s" \
      "${url}" 1>/dev/null
}

# mpv fullscreen on second display and taskspooler
fullscreen() {
      ts mpv --fs "${url}" 1>/dev/null 
}

# mpv and taskspooler
video() {
      ts mpv --no-terminal "${url}" 1>/dev/null
}

# fzf prompt variables spaces to line up menu options
audio_ts='audio      - mpd play audio'
open_ts='open       - open link with your browser'
download_ts='download   - youtube-dl download links'
fullscreen_ts='fullscreen - mpv play fullscreen on second display'
video_ts='video      - mpv play video on current display'

# fzf prompt to specify function to run on links from ytfzf
menu=$(printf "%s\n" \
	      "${audio_ts}" \
	      "${open_ts}" \
	      "${download_ts}" \
	      "${fullscreen_ts}" \
	      "${video_ts}" \
	      | fzf-tmux -d 15% --delimiter='\n' --prompt='Pipe links to: ' --info=inline --layout=reverse --no-multi)

# case statement to run function based on fzf prompt output
case "${menu}" in
   audio*) audio;;
   open*) open_link;;
   download*) download;;
   fullscreen*) fullscreen;;
   video*) video;;
   *) exit;;
esac
