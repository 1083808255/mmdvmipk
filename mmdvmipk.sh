#!/bin/bash

echo "================ 开始注入 MMDVM 编译配置 ================"

# 1. 强制选中 MMDVM 核心程序和网关
echo "CONFIG_PACKAGE_mmdvm-host=y" >> .config
echo "CONFIG_PACKAGE_dmrgateway=y" >> .config
echo "CONFIG_PACKAGE_libmosquitto=y" >> .config
echo "CONFIG_PACKAGE_nlohmannjson=y" >> .config

# 2. 强制开启 LuCI 网页界面及中文包
echo "CONFIG_PACKAGE_luci-app-mmdvm=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-mmdvm-zh-cn=y" >> .config

echo "================ 配置注入完成 ================"
