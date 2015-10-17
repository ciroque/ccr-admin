#!/usr/bin/env bash

sass --update ./src/main/assets/styles/

coffee -c -m ./src/main/assets/scripts/
coffee -c -m ./src/test/spec/
