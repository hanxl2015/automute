# AutoMute+

macOS 菜单栏小工具，在下面这些时刻自动静音：

- **耳机断开连接** —— 有线和蓝牙都适用（走的是系统默认输出设备的变化）
- **Mac 睡眠 / 关机**
- **Mac 锁屏 / 进入屏保**

三个触发条件都能单独开关。除此之外还有：隐藏菜单栏图标、登录时启动、临时禁用静音（1 / 6 / 12 / 24 小时或永久）、静音时发系统通知。

菜单栏图标会反映耳机当前是否连着；图标变红表示静音已被临时禁用。

## 构建

```
open automute.xcodeproj
```

在 Xcode 里选一次你自己的 Team，然后直接 Run。不需要 CocoaPods，也没有额外的 target。

要求 macOS 13+（“登录时启动”用的是 `SMAppService`）。

## 许可

MIT，见 [LICENSE](LICENSE)。

本项目基于 [Yoni Levy 的 AutoMute](https://github.com/yonilevy/automute)，Copyright © 2018 Yoni Levy。
`StartAtLoginController` 来自 [alexzielenski/StartAtLoginController](https://github.com/alexzielenski/StartAtLoginController)，作者 Alex Zielenski 与 Travis Tilley。
