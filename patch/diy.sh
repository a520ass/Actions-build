#!/bin/bash

echo "==== diy.sh 钩子加载器 ===="

SCRIPT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PATCH_VER="${1:?需要传入版本目录名，例如 msm8916-7.3}"
KERNEL_ROOT="$(pwd)"

PATCH_DIR="${SCRIPT_ROOT}/${PATCH_VER}"

echo "PATCH_VER: ${PATCH_VER}"
echo "PATCH_DIR: ${PATCH_DIR}"
echo "KERNEL_ROOT: ${KERNEL_ROOT}"
echo "=========================="

if [ ! -d "${PATCH_DIR}" ]; then
    echo "patch目录不存在 ${PATCH_DIR}"
fi

find "${PATCH_DIR}" -maxdepth 1 -type f -name "*.sh" -print0 | LC_ALL=C sort -z | while IFS= read -r -d '' shshell
do
    echo -e "------ 执行钩子: ${shshell} ------"
    chmod +x "${shshell}"
    "${shshell}" "${PATCH_VER}" "${KERNEL_ROOT}"
    ret=$?
    if [ ${ret} -eq 0 ]; then
        echo "<== [S] shshell file ${shshell}"
    else
        echo "<== [F] shshell file ${shshell}, ret=${ret}"
    fi
done

echo "钩子执行结束"
