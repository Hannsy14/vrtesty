#!/bin/sh

PROJECT_DIR=$1

if [ -z "${PROJECT_DIR}" ]; then
    PROJECT_DIR=$(pwd)
fi

PLIST_BUDDY=/usr/libexec/PlistBuddy
if [ ! -f ${PLIST_BUDDY} ]; then
    echo "PlistBuddy is not available."
    exit 1
fi

DERIVED_DATA_DIR="${HOME}/Library/Developer/Xcode/DerivedData"

findup()
{
    TARGET=$1
    PWD=$(pwd)
    START="${PWD}"
    while [ ! "${PWD}" -ef .. ]; do
        [ -e "${TARGET}" ] && echo "$PWD" && return
        cd .. || return
        PWD=$(pwd)
    done
}

read_build_dir()
{
    BUILD_DIR=$1

    INFO_PLIST="${BUILD_DIR}/info.plist"
    if [ ! -f "${INFO_PLIST}" ]; then
        return
    fi

    WORKSPACE_PATH=$(${PLIST_BUDDY} -c "Print WorkspacePath" "${INFO_PLIST}")

    if [ -z "${WORKSPACE_PATH}" ]; then
        return
    fi
    
    EFFECTIVE_WORKSPACE_PATH=$(findup README.md)

    if [ "${PROJECT_DIR}" == "${EFFECTIVE_WORKSPACE_PATH}" ] ; then
        echo "${BUILD_DIR}"
        exit 0
    fi
}

read_build_dirs()
{
    for BUILD_DIR in $(find "${DERIVED_DATA_DIR}" -type d -maxdepth 1); do
        read_build_dir ${BUILD_DIR}
    done
    exit 0
}

read_build_dirs
