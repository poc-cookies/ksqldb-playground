#!/usr/bin/env bash

# Prerequisites:
#
# 1. tr
# 2. sed
# 3. jq

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

main() {
    local ksqldb_endpoint="http://localhost:8088/ksql"
    local stmts_files=$(find src -type f -name "*.sql" -maxdepth 2)

    for stmts_file in $stmts_files
    do
        deploy_ksqldb_statements_file $ksqldb_endpoint $stmts_file
    done
}

deploy_ksqldb_statements_file() {
    local ksqldb_endpoint="${1}"
    local stmts_file="${2}"

    tr '\n' ' ' < "$stmts_file" | \
    sed 's/;/;\'$'\n''/g' | \
    while read stmt; do
        deploy_ksqldb_statement $ksqldb_endpoint "$stmt"
    done
}

deploy_ksqldb_statement() {
    local ksqldb_endpoint="${1}"
    local stmt="${2}"

    echo '{"ksql":"'$stmt'", "streamsProperties": {}}' | \
        curl -s -X "POST" "$ksqldb_endpoint" \
             -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
             -d @- | \
        jq
}

main "${@}"
