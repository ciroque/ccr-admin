#!/usr/bin/env bash

echo Transpiling styles...
sass --update ./src/main/

echo Transpiling scripts...
coffee -c -m ./src/main/

echo Transpiling test scripts...
coffee -c -m ./src/test/spec/
