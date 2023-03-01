#!/bin/sh

# bbc search

# base url and query string
baseurl='https://www.bbc.co.uk/iplayer/search?'
query="${QUERY_STRING}"
url="${baseurl}${query}"

# css selector
css='div.list.search-list'

# css exclude
search='search-list__header'

# output
wget_output='/tmp/wget-w3m.html'
output='/tmp/bbc-search.html'

# wget download page and convert links to absolute url
wget -k "${url}" -O "${wget_output}" 2> /dev/null

# hxnormalize the page
hxnormalize -x "${wget_output}" \
| hxselect -s '\n' -c "${css}" \
| hxprune -c "${search}" \
| sed -e "/<a/ { /href/ s/.*href=['\"]https:\/\/www.bbc.co.uk\/iplayer\/episode\/.*['\"]\([^<]*\)/&play/g }" \
> "${output}"

# W3m-control
printf "%s\r\n" "W3m-control: GOTO ${output}";
# delete previous buffer
printf "%s\r\n" "W3m-control: DELETE_PREVBUF";

# clear screen
printf "\033c"
