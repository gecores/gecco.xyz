#!/bin/bash

.PHONY = help build build-dev local local-dev deploy deploy-dev upgrade

help:
	@echo 'All available makefile commands:'
	@echo '    build          Replace folder public with current state'
	@echo '    build-dev      Replace folder public with dev state'
	@echo '    local          Start Hugo Local Server'
	@echo '    local-dev      Start Hugo Local Server in Dev mode'
	@echo '    deploy         Build and then upload the website'
	@echo '    deploy-dev     Build and then upload the website to a test directory'
	@echo '    upgrade        Download newest hugo version and update theme'

build:
	rm -r public
	hugo

build-dev:
	rm -r public
	hugo -D -b http://test.gecco.xyz

local:
	hugo server

local-dev:
	hugo server -D

deploy: build
	rsync -acuv --delete -e ssh ./public gecco.xyz@ssh.strato.de:~/gecco.xyz

deploy-dev: build-dev
	rsync -acuv --delete -e ssh ./public gecco.xyz@ssh.strato.de:~/test.gecco.xyz
