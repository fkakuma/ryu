#!/bin/bash
set -x

if [ "$TOX_TARGET" == "py27" -o "$TOX_TARGET" == "py34" ]; then
    bash ryu/tests/integrated/common/install_docker_test_pkg_for_travis.sh
    python ryu/tests/integrated/run_test.py
fi
