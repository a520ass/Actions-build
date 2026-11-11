#!/bin/bash
set -e

# ========= 可改配置 =========
# 要扫描dts的目录
DTS_DIR="./arch/arm64/boot/dts/amlogic"
# 目标Makefile
MK_FILE="${DTS_DIR}/Makefile"
# 对应的CONFIG宏
CFG="CONFIG_ARCH_MESON"
# ============================

usage() {
    echo "用法："
    echo "  $0                    # 使用上面默认配置"
    echo "  $0 <dts目录> <Makefile> <CONFIG>  # 自定义参数"
    echo "示例："
    echo "  $0 ./dts ./dts/Makefile CONFIG_ARCH_MESON"
}

# 支持传参覆盖默认值
if [ $# -eq 3 ]; then
    DTS_DIR="$1"
    MK_FILE="$2"
    CFG="$3"
elif [ $# -ne 0 ]; then
    usage
    exit 1
fi

# 检查目录
if [ ! -d "${DTS_DIR}" ]; then
    echo "ERROR: DTS目录不存在: ${DTS_DIR}"
    exit 1
fi
if [ ! -f "${MK_FILE}" ]; then
    echo "ERROR: Makefile不存在: ${MK_FILE}"
    exit 1
fi

echo "====================================="
echo "DTS目录: ${DTS_DIR}"
echo "Makefile: ${MK_FILE}"
echo "CONFIG: ${CFG}"
echo "====================================="

# 遍历所有 *.dts
find "${DTS_DIR}" -maxdepth 1 -type f -name "*.dts" | sort | while read -r dtsfile; do
    dtsname=$(basename "${dtsfile}")
    base="${dtsname%.*}"
    dtb_line="dtb-\$(${CFG}) += ${base}.dtb"

    echo "处理: ${dtsname}  ->  ${dtb_line}"

    # 已存在则跳过
    if grep -qxF "${dtb_line}" "${MK_FILE}"; then
        echo "  -> 已存在，跳过"
        continue
    fi

    # 查找同CONFIG最后一行行号
    last_ln=$(grep -n "dtb-\$(${CFG}) +=" "${MK_FILE}" | tail -n1 | cut -d: -f1)
    if [ -n "${last_ln}" ]; then
        sed -i "${last_ln}a\\${dtb_line}" "${MK_FILE}"
        echo "  -> 插入到同CONFIG块内"
    else
        echo "${dtb_line}" >> "${MK_FILE}"
        echo "  -> 追加到文件末尾"
    fi
done

echo -e "\n✅ 全部处理完成"
