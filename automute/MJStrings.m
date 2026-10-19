#import "MJStrings.h"
#import "MJUserDefaults.h"

/// YES when the UI should be shown in Chinese.
///
/// `MJLanguageSystem` — the default — resolves from the system's language list,
///  so a per-app language chosen in System Settings -> General -> Language &
///  Region is honoured too. Nothing here ever writes `AppleLanguages`; doing so
///  would make "follow the system" unable to see the system at all.
static BOOL MJIsChinese(void)
{
    switch ([MJUserDefaults.shared language]) {
        case MJLanguageChinese:
            return YES;
        case MJLanguageEnglish:
            return NO;
        case MJLanguageSystem:
            break;
    }

    NSString *preferred = NSLocale.preferredLanguages.firstObject ?: @"en";
    return [preferred hasPrefix:@"zh"];
}

NSString *MJStr(NSString *english)
{
    if (!english || !MJIsChinese()) {
        return english;
    }

    static NSDictionary<NSString *, NSString *> *chinese;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chinese = @{
                // Menu.
                @"Welcome": @"欢迎",
                @"Mute Triggers": @"静音触发条件",
                @"Mac Goes to Sleep / Powers Off": @"Mac 睡眠 / 关机",
                @"Mac Gets Locked / Enters Screen Saver": @"Mac 锁屏 / 进入屏保",
                @"Headphones Disconnected": @"耳机断开连接",
                @"Show Notifications": @"显示静音通知",
                @"Enable": @"启用",
                @"Disable": @"禁用",
                @"For 1 Hour": @"1 小时",
                @"For 6 Hours": @"6 小时",
                @"For 12 Hours": @"12 小时",
                @"For 24 Hours": @"24 小时",
                @"Hide Menu Bar Icon": @"隐藏菜单栏图标",
                @"Launch at Login": @"登录时启动",
                @"Language": @"语言",
                @"Follow System": @"跟随系统",
                @"Quit": @"退出",

                // Notifications.
                @"Woke up from sleep": @"已从睡眠唤醒",
                @"Unlocked": @"已解锁",
                @"Sound Muted.": @"声音已静音",

                // Welcome popup.
                @"AutoMute+ to the rescue!": @"AutoMute+ 来救场！",
                @"For your convenience, the menu bar icon will indicate whether headphones are plugged in or not.":
                        @"菜单栏图标会实时显示耳机是否已连接，方便你随时查看。",
                @"From now on, whenever your Mac goes to sleep, gets locked, or your headphones get disconnected– I'll be here to mute the sound.":
                        @"从现在起，Mac 睡眠、锁屏或耳机断开连接时，声音都会自动静音。",
                @"Got it 👍": @"知道了 👍",

                // Launch-at-login popup.
                @"One Last Thing": @"最后一件事",
                @"Do you want AutoMute+ to launch at login?": @"要让 AutoMute+ 在登录时自动启动吗？",
                @"For AutoMute+ to truly keep you safe, it's recommended that it will launch at login, so you don't have to relaunch it yourself after your Mac is restarted.":
                        @"建议让 AutoMute+ 在登录时自动启动，这样 Mac 重启后无需手动打开，它才能一直保护你。",
                @"Yes 👍": @"好的 👍",
                @"No 👎": @"不用了 👎",
        };
    });

    return chinese[english] ?: english;
}

void MJLocalizeViewTree(NSView *view)
{
    if ([view isKindOfClass:[NSTextField class]]) {
        NSTextField *textField = (NSTextField *)view;
        textField.stringValue = MJStr(textField.stringValue);
    } else if ([view isKindOfClass:[NSButton class]]) {
        NSButton *button = (NSButton *)view;
        button.title = MJStr(button.title);
    }

    for (NSView *subview in view.subviews) {
        MJLocalizeViewTree(subview);
    }
}
