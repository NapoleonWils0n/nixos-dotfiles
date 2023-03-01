#!/bin/sh

# bbc episodes

# current link under cursor in w3m
url="${W3M_CURRENT_LINK}"   

# css selector
css='div.tleo-list'

# css exclude
secondary='content-item__info__secondary'

# output
wget_output='/tmp/wget-w3m.html'
output='/tmp/bbc-episodes.html'

# wget download page and convert links to absolute url
wget -k "${url}" -O "${wget_output}" 2> /dev/null

# hxnormalize the page
hxnormalize -x "${wget_output}" \
| hxselect -s '\n' -c "${css}" \
| hxprune -c "${secondary}" \
| sed -e "/<a/ { /href/ s/.*href=['\"]https:\/\/www.bbc.co.uk\/iplayer\/episode\/.*['\"]\([^<]*\)/&play/g }" \
> "${output}"

# W3m-control
printf "%s\r\n" "W3m-control: GOTO ${output}";
# delete previous buffer
printf "%s\r\n" "W3m-control: DELETE_PREVBUF";

# clear screen
printf "\033c"
