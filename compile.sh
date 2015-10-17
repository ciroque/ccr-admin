#!/usr/bin/env bash

echo Transpiling styles...
sass --update ./src/main/assets/styles/

echo Transpiling scripts...
coffee -c -m ./src/main/assets/scripts/

echo Transpiling test scripts...
coffee -c -m ./src/test/spec/
