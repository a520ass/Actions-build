#!/bin/bash

echo "002.sh 钩子开始"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PATCH_VER="${1:?缺少版本名}"
KERNEL_ROOT="${2:?缺少内核根路径}"

# 本版本dts目录
DTS_SRC="${SCRIPT_DIR}/dts"
DTS_DST="${KERNEL_ROOT}/arch/arm64/boot/dts/qcom"
MAKEFILE="${DTS_DST}/Makefile"
CONFIG_TAG="CONFIG_ARCH_QCOM"

echo "DTS_SRC=${DTS_SRC}"
echo "DTS_DST=${DTS_DST}"

cp -rf "${DTS_SRC}"/*.dts "${DTS_DST}/"

# 调用同目录 addMakefileDtb.sh
"${SCRIPT_DIR}/addMakefileDtb.sh" "${DTS_SRC}" "${MAKEFILE}" "${CONFIG_TAG}"

echo "002.sh 钩子执行完成"