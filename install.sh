#!/bin/bash

install -d /usr/bin /etc/systemd/system /usr/share/doc/sbbs /usr/share/sbbs/
install -Dm755 src/sbbs /usr/bin
cp -n src/config /etc/sbbs
chmod 577 /etc/sbbs
install -Dm644 README.md /usr/share/doc/sbbs
install -Dm644 sbbs.service sbbs.timer /etc/systemd/system
