#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 拉取 MMDVM 核心源码包
git clone https://github.com/fndsz/mmdvm-op.git package/mmdvm/mmdvm-openwrt

# =====================================================================
# 修复 MMDVMHost 缺失头文件的致命报错 (不包含 OLED)
# =====================================================================
echo "========== 修复 MMDVMHost 基础编译依赖 =========="

# 找到 mmdvm-host 的 Makefile
MMDVM_MAKEFILE="package/mmdvm/mmdvm-openwrt/mmdvm-host/Makefile"

if [ -f "$MMDVM_MAKEFILE" ]; then
    echo "找到 mmdvm-host Makefile，注入基础头文件修复..."
    # 强行给源码注入缺失的 cstring 和 cstdio，防止 GCC 报错
    sed -i '/define Build\/Compile/a \	find $(PKG_BUILD_DIR) -name "*.cpp" -exec sed -i '\''1i #include <cstring>\\n#include <cstdio>'\'' {} +' $MMDVM_MAKEFILE
fi

echo "========== 基础依赖修复完成 =========="
