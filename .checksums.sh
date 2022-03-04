#!/bin/sh

BASE_DIR="$(git rev-parse --show-toplevel)"
HASH_DIR="$BASE_DIR/.checksums"
WORKFLOW=.github/workflows/production.yml

curlhash () {
    local output
    local url

    output=${HASH_DIR}/${1:-checksums.txt}
    url=$2

    echo "$(curl -sL "$url" | shasum -a 256 | cut -c1-40) $url" >$output
}

treehash() {
    local output
    local location

    output=${HASH_DIR}/${1:-checksums.txt};shift
    location=$@

    echo >$output
    for path in $location; do
        if [ -f ${HASH_DIR}/$path ]; then
            cat ${HASH_DIR}/$path >>$output
        else
            echo "$(git rev-parse HEAD:$path | cut -c1-40) $path" >>$output
        fi
    done
}

mkdir -p $HASH_DIR

curlhash ondrej-php.txt     http://ppa.launchpad.net/ondrej/php/ubuntu
curlhash ondrej-apache.txt  http://ppa.launchpadcontent.net/ondrej/apache2/ubuntu
curlhash ondrej-nginx.txt   http://ppa.launchpadcontent.net/ondrej/nginx-mainline/ubuntu

treehash base.txt           $WORKFLOW src/base/
treehash cli.txt            base.txt ondrej-php.txt src/php/cli/
treehash fpm.txt            cli.txt src/php/fpm/
treehash servers.txt        fpm.txt ondrej-apache.txt ondrej-nginx.txt src/servers/
treehash webapps.txt        servers.txt src/webapps/
