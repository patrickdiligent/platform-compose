#!/bin/bash

abs_path() {
    echo "$( cd -- "$(dirname "$1")" >/dev/null 2>&1 ; pwd -P )/$(basename "$1")"
}
