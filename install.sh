#!/bin/bash

brew install automake autoconf libtool gettext libevent openssl && \
echo "Installing Tor dependency" && \
carthage update --platform iOS
