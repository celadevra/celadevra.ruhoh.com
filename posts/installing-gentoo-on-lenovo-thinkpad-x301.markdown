---
layout: post
title: "在联想 ThinkPad X301 2774HF3 上安装 Gentoo"
date: 2012-03-28 17:07
comments: true
categories: 规
---
我有一台单位发的联想 X301，应该说在 X 系列里还是不错的本子，不过上面的 Windows 越用越不爽，于是打起了换系统的主意。最适合我的需求的系统可能还是 OS X，不过 OSx86 之类项目还非常不成熟，X301 装上后直接四国了，各种 kext 也很难找。于是还是回到 Linux。

用惯了 Gentoo，使用 Linux 的时候基本不会考虑其他发行版了。不过**在我印象中** Gentoo 自己的 LiveCD 对硬件支持不是很好，特别是缺少很多无线网卡的驱动和 firmware。所以我还是用U盘上的 Ubuntu 11.10 启动系统，在它提供的环境里安装 Gentoo，这样惬意得多。

安装步骤基本按照手册。在 Profile 选择时我选了个 Desktop，后来发现如果只想弄一个最简的 X 系统的话它还是会带来很多麻烦，不如直接选默认的 profile。

<!-- more -->

# 网络

本来打算用 `wicd` 管理网络，但可能是 Python 的问题，运行时总是出错，也不能正确连上 AP。一怒之下直接上 `wpa_supplicant` 和 `dhcpcd`，它们在 `wicd` 安装时都自动带上了。单位的无线网分内外，外网是 WPA-PSK 的，`wpa_supplicant.conf` 的配置很简单：

``` lighty
network={
    ssid="waiwang"
    psk="password"
    priority=5
}
```

这样就直接连上了。内网是使用 802.1x 认证的 WPA2，相对复杂很多，也正是因为它配置麻烦我才想用 `wicd` 管理。`wpa_supplicant` 主要的麻烦是不知道内网的认证到底是采用哪一种 [EAP](https://en.wikipedia.org/wiki/Extensible_Authentication_Protocol) 方法，这次抱着试试看的态度，把 .cer 格式的证书放到 `/etc/cert/` 下，然后方法选 [LEAP](https://en.wikipedia.org/wiki/Lightweight_Extensible_Authentication_Protocol)，居然成功了。不过根据 Wikipedia 上的说法，EAP-LEAP 其实不是很安全，而且当使用弱密码的时候更是如此，看来单位内网也只是没有被骇客看上而已。有关的配置如下：

``` lighty
network={
        ssid="neiwang"
        scan_ssid=1
        key_mgmt=WPA-EAP
        group=TKIP
        pairwise=CCMP
        eap=LEAP
        identity="user"
        password="password"
        ca_cert="/etc/cert/CA.cer"
        priority=5
}
```

在 `wpa_cli` 里选择 neiwang，一下就连上了。上次被这个 EAP 配置搞得头晕眼花的我表示很惊喜，不知道这算不算是经验值上升的表现。

之后可以修改 `/etc/conf.d/net` 如下：

``` lighty
# This blank configuration will automatically use DHCP for any net.*
# scripts in /etc/init.d.  To create a more complete configuration,
# please review /usr/share/doc/openrc*/net.example* and save your configuration
# in /etc/conf.d/net (this file :]!).
modules="wpa_supplicant"
config_wlan0="dhcp"
wpa_cli_wlan0="-G3600"
wpa_supplicant_wlan0="-D nl80211"
dhcp_wlan0="nodns"
dns_servers="8.8.8.8 8.8.4.4"
#config_eth0="dhcp"
```

晚上搜索了一下，原来 Python 安装完之后需要运行一下 `python-updater`，即使是全新的安装也是一样，否则会报错，类似这样：

{% codeblock %}
File "setup.py", line 22, in <module>
from setuptools import setup, Extension, find_packages
ImportError: No module named setuptools
* ERROR: sys-libs/cracklib-2.8.16 failed (compile phase):
* Building failed with CPython 2.7 in distutils_building() function
*
* Call stack:
* ebuild.sh, line 56: Called src_compile
* environment, line 5094: Called do_python
* environment, line 1389: Called distutils_src_compile
* environment, line 1238: Called python_execute_function
'distutils_building'
* environment, line 3662: Called die
* The specific snippet of code:
* die "${failure_message}";
*
* If you need support, post the output of 'emerge --info
=sys-libs/cracklib-2.8.16',
* the complete build log and the output of 'emerge -pqv
=sys-libs/cracklib-2.8.16'.
* The complete build log is located at
'/var/tmp/portage/sys-libs/cracklib-2.8.16/temp/build.log'.
* The ebuild environment file is located at
'/var/tmp/portage/sys-libs/cracklib-2.8.16/temp/environment'.
* S: '/var/tmp/portage/sys-libs/cracklib-2.8.16/work/cracklib-2.8.16'
{% endcodeblock %}

之前 VPS 上的 Python 也是这样的，只是这次没看到 `emerge` 后的提示信息，忘了有这茬。不过要不是有这个错，说不定现在还是搞不清单位内网用的什么认证方式。

## VPN
VPN 的配置如下：
``` nginx
client
dev tun
proto udp
remote yourserver.com 443
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
auth-user-pass pass.txt
#auth-user-pass user.txt
ns-cert-type server
comp-lzo
verb 3
auth-nocache
tun-mtu 1472
tun-mtu-extra 32
mssfix 1400
script-security 2 
reneg-sec 0
explicit-exit-notify
push "redirect-gateway defl local"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
max-routes 3600

(chnroutes.py 生成的路由表）
```

这个路由表全部加到系统路由中需要一点时间，这段时间里网页可能会打不开，耐心等待一下即可。新版的 OpenVPN 中加入了 `redirect-gateway` 这个选项，和 `dhcp-option` 配合可以实现 DNS 流量全部通过 VPN，也就是说不怕 DNS 污染了。

# X Window

首先按照[文档](http://www.gentoo.org/doc/en/xorg-config.xml)，确认内核配置符合要求。特别需要注意编译进“Enable modesetting on intel by default”这个选项。然后修改 `/etc/make.conf`，加入如下语句：

```
INPUT_DEVICES="evdev keyboard mouse synaptics"
VIDEO_CARDS="intel"
```

要注意的是如果没有安装 xterm，也没有 ~/.xinitrc，有可能 X 会直接退出，这时候在终端可能看到 X 报错说 ALPS DualPoint TouchPad 无法轮询和初始化，但其实这并不影响使用。安装一个窗口管理器，比如 [Awesome](http://awesome.naquadah.org/)，然后在 ~/.xinitrc 里写上

``` bash
exec awesome
```

就可以正常启动 X Window 了。

如果使用 KDE 的话，先安装 `kde-base/kde-meta`，然后安装 `kde-base/kdeplasma-addons`，后者提供了不少有用的小工具。要开机直接启动 `kdm`，可以修改 `/etc/conf.d/xdm`，并将 xdm 服务加入默认服务级别中：`sudo rc-update add xdm default`。

# 中文支持

`locale` 建议用 en_US.UTF-8 和 zh_CN.UTF-8。需要英文界面同时支持中文输入（这样 ssh 到本机时不用担心客户端支持中文的问题）的话，可以设置 LANG=en_US.UTF-8，LC_CTYPE 和 LC_COLLATE 设置成 zh_CN.UTF-8。

首先在 make.conf 中加入 unicode 和 cjk 这两个 USE，然后安装基本的字体，具体可以参考 [Gentoo-Portage](http://gentoo-portage.com/media-fonts)。

确认内核的编译选项中有

```
File Systems -->
  Native Language Support -->
    (utf8) Default NLS Option
    <*> NLS UTF8
```

对 FAT 还有

```
File Systems -->
  DOS/FAT/NT Filesystems  -->
    (437) Default codepage for fat
```

Default iocharset for fat 设为空。

如果改变了内核选项，先编译内核，再 `emerge -DNlav world`。

输入法方面，`ibus` 的理念很炫，但目前的几个输入法都不太好用。`fcitx`
重获新生，现在势头不错。安装 `fcitx` 后，可以先新建 `/etc/env.d/20fcitx`，加入如下环境变量设置：

``` bash
XMODIFIERS="@im=fcitx"
XIM=fcitx
XIM_PROGRAM=fcitx
```

当然也可以在每个用户的 .xinitrc 等文件中加入 `export` 形式的设置。如果使用的是 KDE 的话，直接启动 fcitx 后看不到输入条和选字界面。如果安装了 kdeplasma-addons 的话可以添加一个叫 `kimpanel` 的 widget，就可以正常使用 fcitx 了。

# 电源管理和休眠

内核编译时，选中 ACPI 相关的模块，Device Drivers -> X86 Platform Specific Device Drivers 下的 ThinkPad ACPI Laptop Extras 几项也可以根据自己的需要选择。
