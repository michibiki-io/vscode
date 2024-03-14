#!/bin/bash

exec ./bin/code-server-oss --port ${VSCODE_REH_WEB_PORT} --host ${VSCODE_REH_WEB_HOST} "$@"
