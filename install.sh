#!/bin/bash

install -d /usr/bin /etc/systemd/system /usr/share/doc/sbbs
install -Dm755 src/sbbs /usr/bin
install -m755 src/config /etc/sbbs
install -Dm644 README.md /usr/share/doc/sbbs
install -Dm644 sbbs.service sbbs.timer /etc/systemd/system
