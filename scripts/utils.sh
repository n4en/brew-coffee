#!/bin/bash

BUNDLES_DIR="./bundles"

get_brewfiles() {
    local bundle_name="$1"
    local main_file="$BUNDLES_DIR/${bundle_name}.Brewfile"
    local files=("$main_file")

    if [[ "$bundle_name" =~ aws|azure|gcp|k8s ]]; then
        files+=("$BUNDLES_DIR/infra.Brewfile")
    fi

    echo "${files[@]}"
}
