#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Runs every gjs test suite for the GNOME extension. Compiles the schema first
# because settings.js resolves it from the extension's own schemas/ directory.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

glib-compile-schemas schemas/ || exit 1

STATUS=0
for test in tests/*-test.js; do
    echo "── $test"
    gjs -m "$test" || STATUS=1
done

exit "$STATUS"
