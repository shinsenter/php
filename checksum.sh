#!/bin/sh

BASE_DIR="$(git rev-parse --show-toplevel)"
HASH_DIR="$BASE_DIR/versions"

curlhash () {
    local output
    local url

    output=${HASH_DIR}/${1:-checksums.txt}
    url=$2

    echo "$(curl -sL "$url" | shasum | cut -c1-40) - $url" >$output
}

treehash() {
    local output
    local location

    output=${HASH_DIR}/${1:-checksums.txt};shift
    location=$@

    rm -f $output && touch $output
    for path in $location; do
        if [ -f ${HASH_DIR}/$path ]; then
            cat ${HASH_DIR}/$path >>$output
        else
            echo "$(git rev-parse HEAD:$path 2>/dev/null| cut -c1-40) - $path" >>$output
        fi
    done
}

mkdir -p $HASH_DIR

curlhash .dep-ondrej-php.txt    'http://ppa.launchpad.net/ondrej/php/ubuntu/dists/?C=M;O=D'
curlhash .dep-ondrej-apache.txt 'http://ppa.launchpadcontent.net/ondrej/apache2/ubuntu/dists/?C=M;O=D'
curlhash .dep-ondrej-nginx.txt  'http://ppa.launchpadcontent.net/ondrej/nginx-mainline/ubuntu/dists/?C=M;O=D'

treehash base.txt    S6_VERSION.txt src/base-ubuntu/
treehash cli.txt     base.txt .dep-ondrej-php.txt src/php/cli/
treehash fpm.txt     cli.txt src/php/fpm/
treehash servers.txt fpm.txt .dep-ondrej-apache.txt .dep-ondrej-nginx.txt src/servers/
treehash webapps.txt servers.txt src/webapps/
