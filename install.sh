#!/bin/bash

brew install automake autoconf libtool gettext libevent && \
echo "Installing Tor dependency" && \
carthage update --platform iOS
