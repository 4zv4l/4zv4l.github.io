#!/usr/bin/env bash
guix shell jekyll ruby bundler gcc-toolchain make pkg-config \
           libxml2 libxslt nss-certs coreutils -C -N -F \
           -- <<EOF
export SSL_CERT_DIR=/etc/ssl/certs
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
bundle exec ./bin/jekyll serve --host 0.0.0.0 --port 8088
EOF
