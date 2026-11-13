#!/bin/bash
# DIY脚本
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-part1.sh
# 功能说明: OpenWrt DIY脚本第1部分（更新feeds之前）
# 版权: (c) 2019-2024 P3TERX <https://p3terx.com>
# 基于 MIT 开源协议，详见 /LICENSE

# 取消注释一个源
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# 添加第三方 feed 源（small-package 包含 openclash/passwall/ssr-plus 等常用插件）
echo 'src-git smpackage https://github.com/kenzok8/small-package' >> feeds.conf.default
# 添加第三方源，下面 iStore 应用商店了，然后在编译时候包输入luci-app-store
# echo 'src-git store https://github.com/linkease/istore.git;main' >> feeds.conf.default


# OpenClash代理
# git clone --depth 1 https://github.com/vernesong/OpenClash.git OpenClash

# turboacc网络加速
# curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# 调试
# sed -i 's|src-git-full openstick https://github.com/lkiuyu/openstick-feeds.git|src-git-full openstick https://github.com/xuxin1955/openstick-feeds|g' feeds.conf.default

# ===== 补回 libffi 包 =====
# lkiuyu/immortalwrt 的 package/libs 里删掉了 libffi，
# 但 feeds/packages 的 glib2（modemmanager 依赖它）需要它，
# 缺失会报 "dependency on 'libffi', which does not exist" 导致编译中断。
if [ ! -f package/libs/libffi/Makefile ]; then
  echo ">>> 补回 libffi 包"
  B=https://raw.githubusercontent.com/immortalwrt/immortalwrt/master/package/libs/libffi
  mkdir -p package/libs/libffi/patches
  curl -fsSL -o package/libs/libffi/Makefile "$B/Makefile" || exit 1
  for p in \
001-arm-fix-big-endian-sub-word-argument-offsets-in-closures.patch \
002-closures-handle-page-size-lookup-failure.patch \
003-powerpc64-fix-_Complex-long-double-when-long-double-is-64-bits.patch \
004-powerpc64-keep-_Complex-long-double-in-step-with-the-abi-s-long-double.patch \
005-testsuite-check-complex-arguments-when-argument-registers-run-low.patch \
006-testsuite-check-integer-complex-types-smaller-than-a-register.patch \
007-testsuite-use-register-sized-complex-return-storage.patch \
008-x86-pass-complex-arguments-of-up-to-4-bytes-like-structs-on-i386.patch \
009-x86-leave-complex-arguments-out-of-native-raw-calls.patch \
010-powerpc64-fix-big-endian-ELFv2-closure-returns-of-1-to-4-byte-structs.patch \
011-powerpc-fix-big-endian-SVR4-closure-returns-of-1-and-2-byte-structs.patch \
012-powerpc-add-complex-type-support-for-32-bit-SYSV.patch \
013-mips-fix-big-endian-N32-N64-closure-returns-of-small-integers.patch \
014-testsuite-check-return-values-of-structs-with-one-or-two-floating-point-fields.patch \
015-mips-fix-N32-N64-soft-float-returns-of-floating-point-structs.patch \
016-testsuite-use-register-sized-struct-return-storage.patch \
017-riscv-add-support-for-complex-types.patch \
018-loongarch-add-support-for-complex-types.patch \
019-arm-lay-out-the-arguments-behind-the-hidden-struct-return-pointer.patch \
020-arm-pass-sub-word-complex-arguments-to-big-endian-closures-in-place.patch \
021-mips-fix-O32-complex-call-and-closure-returns.patch \
022-mips-bound-small-complex-return-stores.patch ; do
    curl -fsSL -o "package/libs/libffi/patches/$p" "$B/patches/$p" || exit 1
  done
  echo ">>> libffi 就绪，补丁数: $(ls package/libs/libffi/patches | wc -l)"
else
  echo ">>> libffi 已存在，跳过"
fi



