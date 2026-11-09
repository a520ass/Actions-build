#!/bin/bash

echo "002sh当前目录:$(pwd)"

echo "复制dts文件到armbian的dt目录"
cp -rf ../patch/armbian/${1}/dts/*.dts patch/kernel/archive/${1}/dt/

