#!/bin/bash
set -x

if [ "$PY_VER" == "py27" -o "$PY_VER" == "py34" ]; then
    bash ryu/tests/integrated/common/install_docker_test_pkg_for_travis.sh
    python ryu/tests/integrated/run_test.py
fi
