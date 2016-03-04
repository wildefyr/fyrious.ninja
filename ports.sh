#!/bin/sh
#
# wildefyr - 2016 (c) wtfpl
# build individual ports index.html to show hidden files

HTMLROOT="/builds/wildefyr.net"

generate() {
    # generate main index.html using crux specific tools
    type crux 2>&1 > /dev/null && {

        rsync -aq /usr/ports/wild-crux-ports/* ./

        httpup-repgen && portspage . | sed '1,43d' | sed -n '/Generated by/q;p' \
            > index.html
        printf '%s\n' "<li><a href="/ports/wildefyr.git">Git Sync</a></li>" \
            >> index.html
        printf '%s\n' "<li><a href="/ports/wildefyr.httpup">Httpup Sync</a></li>" \
            >> index.html
    }

    # generate html
    for port in $(find -type d | sed '1d'); do
        cd $port

        printf '%s' "<pre><code>" > index.html
        printf "<a href=\"../\">../</a>\n" >> index.html

        for file in $(ls -A); do
            test "$file" = "index.html" && continue
            date=$(du --time ${file} | awk '{print $2,$3}')
            size=$(du -hs ${file} | awk '{print $1}')

            test "$size" = "0" && size="-"

            printf "\
<div id=\"alignfile\">\
<a href=\"${file}\">${file}</a>\
</div>\
<div id=\"aligndata\">\
<span id=\"alignsize\">${size}</span>\t\
<span id=\"aligndate\">${date}</span>\t\
</div>\n" >> index.html
        done

        printf '%s\n' "</code></pre>" >> index.html

        cd ../
    done
}

clean() {
    for port in $(find -type d | sed '1d'); do
        cd $port
        test -f index.html && rm index.html
        cd ../
    done
}

cd "$HTMLROOT/ports"

case $1 in
    clean) clean    ;;
    *)     generate ;;
esac
