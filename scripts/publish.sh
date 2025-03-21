#!/bin/bash

set -e

bash scripts/install-packages.sh

# Delete the dist folder
rm -rf lib

# Run rojo and darklua commands
echo "Running rojo..."
rojo sourcemap default.project.json -o sourcemap.json
echo "Running darklua..."
darklua process --config .darklua.json src/ lib
echo "Running pesde..."
pesde publish