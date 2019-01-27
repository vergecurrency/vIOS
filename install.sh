#!/bin/bash

brew install automake autoconf libtool gettext libevent openssl && \
ln -s /usr/local/bin/glibtoolize /usr/local/bin/libtoolize && \
echo "Installing Tor dependency" && \
carthage update --platform iOS --cache-builds
