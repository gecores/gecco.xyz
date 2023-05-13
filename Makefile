#!/bin/bash

.PHONY = help build dev deploy

help:
	@echo 'All available makefile commands:'
	@echo '    build          Replace folder public with current state'
	@echo '    dev            Start Hugo Dev Server'
	@echo '    deploy         Build and then upload the website'

build:
	rm -r public
	hugo

dev:
	hugo server

deploy: build
	ssh gecco.xyz@ssh.strato.de rm -r gecco.xyz/*
	scp -r public/* gecco.xyz@ssh.strato.de:/gecco.xyz/
