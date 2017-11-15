#!/usr/bin/make -f
export DH_VERBOSE=1
# hardened using nim.cfg

%:
	dh $@ --with systemd

override_dh_auto_build:
	nimble build

override_dh_auto_test:
	true
