#!/bin/sh

# sauron - w3m

# current link under cursor in w3m
url="${W3M_CURRENT_LINK}"   

if [ -n "${url}" ]; then
   result=$(echo "${url}" | \
            grep -oP '(?<=google.com\/url\?q=)[^&]*(?=&)' \
            | sed -e "s/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g" | xargs -0 echo -e)
   [ -n "${result}" ] && url="${result}"
else
    url="${W3M_URL}"
fi

# mpd and taskspooler
audio() {
      ts pinch -i "${url}" 1>/dev/null 
}

copy() {
    printf "%s\n" "${url}" | xclip -i -selection clipboard 1>/dev/null
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
      ts mpv --no-terminal --fs "${url}" 1>/dev/null 
}

# download with yt-dlp with sponsorblock to remove sponsor
sponsorblock_download() {
      ts \
      yt-dlp \
      --no-playlist \
      --sponsorblock-remove all \
      -f 'bestvideo[height<=1080][vcodec!=?vp9]+bestaudio[acodec!=?opus]' \
      -o "$HOME/Downloads/%(title)s.%(ext)s" \
      "${url}" 1>/dev/null
}

# mpv and taskspooler
video() {
      ts mpv --no-terminal "${url}" 1>/dev/null
}

# fzf prompt variables spaces to line up menu options
audio_ts='audio      - mpd play audio'
download_ts='download   - youtube-dl download links'
copy_ts='copy       - copy url'
open_ts='open       - open link with your browser'
fullscreen_ts='fullscreen - mpv play fullscreen on second display'
sponsorblock_ts='sponsorblock - sponsorblock yt-dlp'
video_ts='video      - mpv play video on current display'

# fzf prompt to specify function to run on links from ytfzf
menu=$(printf "%s\n" \
	      "${video_ts}" \
	      "${fullscreen_ts}" \
	      "${download_ts}" \
	      "${copy_ts}" \
	      "${open_ts}" \
	      "${audio_ts}" \
	      "${sponsorblock_ts}" \
	      | fzf-tmux -d 22% --delimiter='\n' --prompt='Pipe links to: ' --info=inline --layout=reverse --no-multi)

# case statement to run function based on fzf prompt output
case "${menu}" in
   audio*) audio;;
   copy*) copy;;
   download*) download;;
   open*) open_link;;
   fullscreen*) fullscreen;;
   sponsor*)sponsorblock_download ;;
   video*) video;;
   *) exit;;
esac
