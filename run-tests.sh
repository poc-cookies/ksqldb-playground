#!/usr/bin/env bash

# Prerequisites:
#
# 1. Docker
# 2. A running multi-container Docker application (defined in the ./docker-compose.yml file)

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

main() {
    local examples=$(find src -type d -mindepth 1 -exec basename {} \;)
    local docker_mount_dir="/opt/app"
    local src_dir="src"
    local test_dir="test"

    for example in $examples
    do
        printf "%s\n" "Testing: ${example}"
        local stmts_file="${docker_mount_dir}/${src_dir}/${example}/statements.sql"
        local input_file="${docker_mount_dir}/${test_dir}/${example}/input.json"
        local output_file="${docker_mount_dir}/${test_dir}/${example}/output.json"
        run_statements_file_tests $stmts_file $input_file $output_file
    done
}

run_statements_file_tests() {
    local stmts_file="${1}"
    local input_file="${2}"
    local output_file="${3}"

    docker exec ksqldb-cli ksql-test-runner \
        -i ${input_file} \
        -o ${output_file} \
        -s ${stmts_file}
}

main "${@}"
