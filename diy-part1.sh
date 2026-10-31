#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#sed -i '$a src-git mmdvm https://github.com/fndsz/mmdvm-op' feeds.conf.default
git clone https://github.com/fndsz/mmdvm-op.git package/mmdvm/mmdvm-openwrt

# =====================================================================
# 强制修复 MMDVMHost 编译时缺少 OLED 库的问题
# =====================================================================
echo "========== 修复 OLED 依赖 =========="

# 1. 确保系统开启了 I2C 支持
echo "CONFIG_PACKAGE_kmod-i2c-core=y" >> .config
echo "CONFIG_PACKAGE_kmod-i2c-mt7621=y" >> .config

# 2. 从 GitHub 下载 ArduiPi_OLED 源码，塞进 package 目录
git clone https://github.com/hallard/ArduiPi_OLED.git package/libaruipoled
# 删掉它自带的乱七八糟的编译文件，只留源码
rm -rf package/libaruipoled/.git

# 3. 动态写一个 OpenWrt 的 Makefile 给它
cat > package/libaruipoled/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=libaruipoled
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/libaruipoled
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=ArduiPi OLED Library for MMDVM
  DEPENDS:=+kmod-i2c-core
endef

define Build/Compile
	$(TARGET_CXX) -c -o $(PKG_BUILD_DIR)/ArduiPi_OLED.o $(PKG_BUILD_DIR)/ArduiPi_OLED.cpp -I$(PKG_BUILD_DIR)
	$(AR) rcs $(PKG_BUILD_DIR)/libArduiPi_OLED.a $(PKG_BUILD_DIR)/ArduiPi_OLED.o
endef

define Package/libaruipoled/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libArduiPi_OLED.a $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ArduiPi_OLED_lib.h $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ArduiPi_OLED.h $(1)/usr/include/
endef

$(eval $(call BuildPackage,libaruipoled))
EOF

# 4. 强行修改 mmdvm-host 的源码 Makefile，让它去链接这个库
# 找到 mmdvm-host 的 Makefile（由于拉取路径不同，这里多写几个可能的位置）
MMDVM_MAKEFILE="feeds/mmdvm/mmdvm-openwrt/mmdvm-host/Makefile"
if [ ! -f "$MMDVM_MAKEFILE" ]; then
    MMDVM_MAKEFILE="package/mmdvm/mmdvm-openwrt/mmdvm-host/Makefile"
fi

if [ -f "$MMDVM_MAKEFILE" ]; then
    echo "找到 mmdvm-host Makefile，注入 OLED 依赖..."
    # 修改 DEPENDS，加上我们刚才写的库
    sed -i 's/DEPENDS:=+libstdcpp/DEPENDS:=+libstdcpp +libaruipoled/g' $MMDVM_MAKEFILE
    # 在编译规则里加上头文件搜索路径
    sed -i 's/CXXFLAGS="$(TARGET_CXXFLAGS)"/CXXFLAGS="$(TARGET_CXXFLAGS) -I$(STAGING_DIR)\/usr\/include"/g' $MMDVM_MAKEFILE
fi

echo "========== OLED 依赖修复完成 =========="
