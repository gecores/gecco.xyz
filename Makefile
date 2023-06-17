#!/bin/bash

.PHONY = help build local deploy-dev deploy upgrade

help:
	@echo 'All available makefile commands:'
	@echo '    build          Replace folder public with current state'
	@echo '    local          Start Hugo Local Server'
	@echo '    local-dev      Start Hugo Local Server in Dev mode'
	@echo '    deploy         Build and then upload the website'
	@echo '    deploy-dev     Build and then upload the website to a test directory'
	@echo '    upgrade        Download newest hugo version and update theme'

build:
	rm -r public
	hugo

local:
	hugo server

local-dev:
	hugo server -D

deploy: build
	ssh gecco.xyz@ssh.strato.de rm -r gecco.xyz/*
	scp -r public/* gecco.xyz@ssh.strato.de:/gecco.xyz/

deploy-dev:
	rm -r public
	hugo -D -b http://test.gecco.xyz
	ssh gecco.xyz@ssh.strato.de rm -r test.gecco.xyz/*
	scp -r public/* gecco.xyz@ssh.strato.de:/test.gecco.xyz/

upgrade:
	choco upgrade chocolatey
	choco upgrade hugo-extended
	git submodule update --remote --merge
