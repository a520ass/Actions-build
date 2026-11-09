#!/bin/bash

echo "001sh当前目录:$(pwd)"

# 定义要设置的配置项数组
configs=(
	"CONFIG_MTD=y"
	"CONFIG_MTD_NAND_NANDSIM=m"
    "CONFIG_MTD_UBI=m"
    "CONFIG_MTD_UBI_GLUEBI=m"
    "CONFIG_UBIFS_FS=m"
)

# 指定内核配置文件路径，默认为当前目录下的 .config
##CONFIG_FILE="${1:-.config}"
CONFIG_FILE="config/kernel/linux-meson64-current.config"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件 $CONFIG_FILE 不存在!"
    exit 1
fi

# 循环处理每个配置项
for config in "${configs[@]}"; do
    # 提取键（key）和期望的值（new_value）
    key=$(echo "$config" | cut -d'=' -f1)
    new_value=$(echo "$config" | cut -d'=' -f2)
    
    # 检查当前配置的值
    # 查找以 key= 开头的行，并提取值
    current_value=$(grep -E "^$key=" "$CONFIG_FILE" | cut -d'=' -f2)
    
    # 如果当前值已经是 m 或 y，则跳过
    if [[ "$current_value" == "m" || "$current_value" == "y" ]]; then
        echo "已存在且已启用: $key=$current_value (无需修改)"
        continue
    fi
    
    # 如果配置存在但不是 m 或 y（比如是 n 或者其他值），或者需要修改，则执行删除和添加操作
    # 1. 先删除现有的配置项（如果存在）
    # 使用 sed 删除所有以该 key 开头的行（包括被注释掉的 # CONFIG_XXX is not set 形式）
    sed -i "/^$key=/d" "$CONFIG_FILE"
    sed -i "/^# $key is not set/d" "$CONFIG_FILE"

    # 2. 将新的配置项追加到文件末尾
    echo "$config" >> "$CONFIG_FILE"
    echo "已更新: $config"
done

echo "所有配置项处理完成。"