#!/bin/bash

brew install automake autoconf libtool gettext && \
echo "Installing Tor dependency" && \
carthage update --platform iOS