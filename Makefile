#!/bin/bash

help:
	@echo All available makefile commands:
	@echo     build          Replace folder public with current state
	@echo     run-local      Start Hugo Dev Server

build:
	rm -r public
	hugo

run-local:
	hugo server

deploy:
	@echo 'deploy'
	ssh gecco.xyz@ssh.strato.de rm -r gecco.xyz/*
	scp -r public/* gecco.xyz@ssh.strato.de:/gecco.xyz/
