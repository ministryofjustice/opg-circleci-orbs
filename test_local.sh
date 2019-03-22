#!/usr/bin/env bash

circleci config validate &&\
docker run -v `pwd`:/src/ singapore/lint-condo
