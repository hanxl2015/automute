#import "MJMenuBarController.h"
#import "MJStrings.h"
#import "MJUserDefaults.h"
#import "YLStatusItemPopupDisplayer.h"
#import "WelcomePopupView.h"
#import "NSImage+YLUtil.h"
#import "LaunchAtLoginPopupView.h"

static const NSInteger MENU_ITEM_DISABLE_MUTING = 101;
static const NSInteger MENU_ITEM_ENABLE_MUTING = 102;
static const NSInteger MENU_ITEM_LAUNCH_AT_LOGIN = 103;
static const NSInteger MENU_ITEM_MUTE_ON_SLEEP = 104;
static const NSInteger MENU_ITEM_MUTE_ON_HEADPHONES = 105;
static const NSInteger MENU_ITEM_MUTE_NOTIFICATIONS = 106;
static const NSInteger MENU_ITEM_MUTE_ON_LOCK = 107;
static const NSInteger MENU_ITEM_HIDE_MENU_BAR_ICON = 108;
static const NSInteger MENU_ITEM_WELCOME = 109;
static const NSInteger MENU_ITEM_MUTE_TRIGGERS = 110;
static const NSInteger MENU_ITEM_LANGUAGE = 111;
static const NSInteger MENU_ITEM_QUIT = 112;

static const NSInteger MENU_ITEM_DISABLE_1H = 201;
static const NSInteger MENU_ITEM_DISABLE_6H = 202;
static const NSInteger MENU_ITEM_DISABLE_12H = 203;
static const NSInteger MENU_ITEM_DISABLE_24H = 204;
static const NSInteger MENU_ITEM_DISABLE_FOREVER = 205;

static const NSInteger MENU_ITEM_LANGUAGE_SYSTEM = 301;
static const NSInteger MENU_ITEM_LANGUAGE_CHINESE = 302;
static const NSInteger MENU_ITEM_LANGUAGE_ENGLISH = 303;

@interface MJMenuBarController () <NSMenuDelegate>
@property(nonatomic, strong) NSStatusItem *statusItem;
@property(nonatomic, strong) YLStatusItemPopupDisplayer *popoverDisplayer;
@property(nonatomic, weak) id <MJMenuBarControllerDelegate> delegate;
@end

@implementation MJMenuBarController

- (instancetype)initWithDelegate:(id<MJMenuBarControllerDelegate>)delegate
             headphonesConnected:(BOOL)headphonesConnected
{
    self = [super init];
    if (!self) return nil;

    self.delegate = delegate;

    [self createAndAddStatusBarItem:headphonesConnected];
    self.popoverDisplayer = [[YLStatusItemPopupDisplayer alloc] initWithStatusItem:self.statusItem];

    return self;
}

- (void)createAndAddStatusBarItem:(BOOL)headphonesConnected
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.menu = [self createMenuWithItems];
    [self updateMenuIcon:headphonesConnected];
}

- (NSMenu *)createMenuWithItems
{
    NSMenu *menu = [[NSMenu alloc] init];
    menu.delegate = self;
    [menu addItem:[self buildVersionMenuItem]];
    [menu addItem:[self buildMenuItemWithTag:MENU_ITEM_WELCOME action:@selector(showWelcomePopup)]];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *triggersItem = [self buildMenuItemWithTag:MENU_ITEM_MUTE_TRIGGERS action:nil];
    NSMenu *muteOnSubmenu = [[NSMenu alloc] init];
    [muteOnSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_MUTE_ON_SLEEP action:@selector(muteOnSleepToggled)]];
    [muteOnSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_MUTE_ON_LOCK action:@selector(muteOnLockToggled)]];
    [muteOnSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_MUTE_ON_HEADPHONES action:@selector(muteOnHeadphonesToggled)]];
    triggersItem.submenu = muteOnSubmenu;
    [menu addItem:triggersItem];
    [menu addItem:[self buildMenuItemWithTag:MENU_ITEM_MUTE_NOTIFICATIONS action:@selector(muteNotificationsToggled)]];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[self buildMenuItemWithTag:MENU_ITEM_ENABLE_MUTING action:@selector(enableMute)]];
    NSMenuItem *disableItem = [self buildMenuItemWithTag:MENU_ITEM_DISABLE_MUTING action:@selector(disableMutingTimeClicked:)];
    NSMenu *disableSubmenu = [[NSMenu alloc] init];
    [disableSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_DISABLE_FOREVER action:@selector(disableMutingTimeClicked:)]];
    [disableSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_DISABLE_1H action:@selector(disableMutingTimeClicked:)]];
    [disableSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_DISABLE_6H action:@selector(disableMutingTimeClicked:)]];
    [disableSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_DISABLE_12H action:@selector(disableMutingTimeClicked:)]];
    [disableSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_DISABLE_24H action:@selector(disableMutingTimeClicked:)]];
    disableItem.submenu = disableSubmenu;
    [menu addItem:disableItem];

    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[self buildMenuItemWithTag:MENU_ITEM_HIDE_MENU_BAR_ICON action:@selector(hideMenuBarIconToggled)]];
    [menu addItem:[self buildMenuItemWithTag:MENU_ITEM_LAUNCH_AT_LOGIN action:@selector(launchAtLoginToggled)]];
    NSMenuItem *languageItem = [self buildMenuItemWithTag:MENU_ITEM_LANGUAGE action:nil];
    NSMenu *languageSubmenu = [[NSMenu alloc] init];
    [languageSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_LANGUAGE_SYSTEM action:@selector(languageSelected:)]];
    [languageSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_LANGUAGE_CHINESE action:@selector(languageSelected:)]];
    [languageSubmenu addItem:[self buildMenuItemWithTag:MENU_ITEM_LANGUAGE_ENGLISH action:@selector(languageSelected:)]];
    languageItem.submenu = languageSubmenu;
    [menu addItem:languageItem];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[self buildMenuItemWithTag:MENU_ITEM_QUIT action:@selector(quit)]];
    return menu;
}

- (NSMenuItem *)buildMenuItemWithTag:(NSInteger)tag action:(SEL)action
{
    return [self buildMenuItemWithTitle:[self localizedTitleForTag:tag] action:action tag:tag];
}

/// The one place that turns a tag into a title. Both the initial build and the
///  re-render on open go through it, so the two can never drift apart.
- (NSString *)localizedTitleForTag:(NSInteger)tag
{
    switch (tag) {
        case MENU_ITEM_WELCOME: return MJStr(@"Welcome");
        case MENU_ITEM_MUTE_TRIGGERS: return MJStr(@"Mute Triggers");
        case MENU_ITEM_MUTE_ON_SLEEP: return MJStr(@"Mac Goes to Sleep / Powers Off");
        case MENU_ITEM_MUTE_ON_LOCK: return MJStr(@"Mac Gets Locked / Enters Screen Saver");
        case MENU_ITEM_MUTE_ON_HEADPHONES: return MJStr(@"Headphones Disconnected");
        case MENU_ITEM_MUTE_NOTIFICATIONS: return MJStr(@"Show Notifications");
        case MENU_ITEM_ENABLE_MUTING: return MJStr(@"Enable");
        case MENU_ITEM_DISABLE_MUTING: return MJStr(@"Disable");
        case MENU_ITEM_DISABLE_FOREVER: return MJStr(@"Disable");
        case MENU_ITEM_DISABLE_1H: return MJStr(@"For 1 Hour");
        case MENU_ITEM_DISABLE_6H: return MJStr(@"For 6 Hours");
        case MENU_ITEM_DISABLE_12H: return MJStr(@"For 12 Hours");
        case MENU_ITEM_DISABLE_24H: return MJStr(@"For 24 Hours");
        case MENU_ITEM_HIDE_MENU_BAR_ICON: return MJStr(@"Hide Menu Bar Icon");
        case MENU_ITEM_LAUNCH_AT_LOGIN: return MJStr(@"Launch at Login");
        case MENU_ITEM_LANGUAGE: return MJStr(@"Language");
        case MENU_ITEM_LANGUAGE_SYSTEM: return MJStr(@"Follow System");
        // Like macOS, each language names itself, so the option you want is
        //  readable even when the current language is the one you can't read.
        case MENU_ITEM_LANGUAGE_CHINESE: return @"中文";
        case MENU_ITEM_LANGUAGE_ENGLISH: return @"English";
        case MENU_ITEM_QUIT: return MJStr(@"Quit");
        default: return @"";
    }
}

- (NSMenuItem *)buildMenuItemWithTitle:(NSString *)title action:(SEL)action tag:(const NSInteger)tag
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    item.tag = tag;
    item.target = self;
    return item;
}

- (NSMenuItem *)buildVersionMenuItem
{
    NSDictionary *info = NSBundle.mainBundle.infoDictionary;
    NSString *versionTitle = [NSString stringWithFormat:@"%@ v%@ [%@]", info[@"CFBundleName"], info[@"CFBundleShortVersionString"], info[@"CFBundleVersion"] ];
    NSMenuItem *versionItem = [self buildMenuItemWithTitle:versionTitle action:nil tag:0];
    versionItem.enabled = NO;
    return versionItem;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self.popoverDisplayer hidePopoverWithAnimate:NO];
    [self refreshTitlesInMenu:menu];
}

/// Titles are re-rendered on every open, so picking a language shows up the next
///  time the menu drops down — no rebuild, no relaunch.
- (void)refreshTitlesInMenu:(NSMenu *)menu
{
    for (NSMenuItem *item in menu.itemArray) {
        if (item.tag != 0) {
            item.title = [self localizedTitleForTag:item.tag];
        }
        [self refreshTitlesInMenu:item.submenu];
    }
}

- (void)disableMutingTimeClicked:(NSView *)sender
{
    int hoursUntilEnabled;
    switch (sender.tag) {
        case MENU_ITEM_DISABLE_1H:
            hoursUntilEnabled = 1;
            break;
        case MENU_ITEM_DISABLE_6H:
            hoursUntilEnabled = 6;
            break;
        case MENU_ITEM_DISABLE_12H:
            hoursUntilEnabled = 12;
            break;
        case MENU_ITEM_DISABLE_24H:
            hoursUntilEnabled = 24;
            break;
        case MENU_ITEM_DISABLE_FOREVER:
            hoursUntilEnabled = -1;
            break;
        default:
            return;
    }
    [self.popoverDisplayer hidePopoverWithAnimate:YES];

    [self.delegate menuBarController_disableMutingFor:hoursUntilEnabled];
}

- (void)enableMute
{
    [self.delegate menuBarController_enableMuting];
}

- (void)muteOnSleepToggled
{
    [self.delegate menuBarController_setMuteOnSleep:![self.delegate menuBarController_isSetToMuteOnSleep]];
}

- (void)muteOnLockToggled
{
    [self.delegate menuBarController_setMuteOnLock:![self.delegate menuBarController_isSetToMuteOnLock]];
}

- (void)muteOnHeadphonesToggled
{
    [self.delegate menuBarController_setMuteOnHeadphones:![self.delegate menuBarController_isSetToMuteOnHeadphones]];
}

- (void)launchAtLoginToggled
{
    [self.delegate menuBarController_setLaunchAtLogin:![self.delegate menuBarController_isSetToLaunchAtLogin]];
}

- (void)muteNotificationsToggled
{
    [self.delegate menuBarController_toggleMuteNotifications];
}

- (void)hideMenuBarIconToggled
{
    [self.delegate menuBarController_toggleHideMenuBarIcon];
}

- (MJLanguage)languageForTag:(NSInteger)tag
{
    switch (tag) {
        case MENU_ITEM_LANGUAGE_CHINESE: return MJLanguageChinese;
        case MENU_ITEM_LANGUAGE_ENGLISH: return MJLanguageEnglish;
        default: return MJLanguageSystem;
    }
}

- (void)languageSelected:(NSMenuItem *)sender
{
    [MJUserDefaults.shared setLanguage:[self languageForTag:sender.tag]];
}

- (void)showWelcomePopup
{
    NSArray *topLevelObjects;
    [[NSBundle mainBundle] loadNibNamed:@"WelcomePopup" owner:self topLevelObjects:&topLevelObjects];
    WelcomePopupView *popup = topLevelObjects[[topLevelObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[WelcomePopupView class]];
    }]];
    popup.gotItButton.target = self;
    popup.gotItButton.action = @selector(welcomeGotItClicked);

    [self.popoverDisplayer displayPopoverWithView:popup shouldCloseOnOutsideTouches:YES];
}

- (void)welcomeGotItClicked
{
    [MJUserDefaults.shared setSawWelcomeScreen];
    [self showLaunchAtLoginPopup];
}

- (void)showLaunchAtLoginPopup
{
    NSArray *topLevelObjects;
    [[NSBundle mainBundle] loadNibNamed:@"LaunchAtLoginPopup" owner:self topLevelObjects:&topLevelObjects];
    LaunchAtLoginPopupView *popup = topLevelObjects[[topLevelObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[LaunchAtLoginPopupView class]];
    }]];
    popup.yesButton.target = popup.noButton.target = self;
    popup.yesButton.action = @selector(launchAtLoginYesClicked);
    popup.noButton.action = @selector(launchAtLoginNoClicked);

    [self.popoverDisplayer displayPopoverWithView:popup shouldCloseOnOutsideTouches:YES];
}

- (void)launchAtLoginYesClicked
{
    [MJUserDefaults.shared setSawLaunchAtLoginPopup];
    [self.popoverDisplayer hidePopoverWithAnimate:YES];
    [self.delegate menuBarController_setLaunchAtLogin:YES];
}

- (void)launchAtLoginNoClicked
{
    [MJUserDefaults.shared setSawLaunchAtLoginPopup];
    [self.popoverDisplayer hidePopoverWithAnimate:YES];
    [self.delegate menuBarController_setLaunchAtLogin:NO];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (MJUserDefaults.shared.isMutingDisabled) {
        if (menuItem.tag == MENU_ITEM_DISABLE_MUTING) {
            return NO;
        }
    } else {
        if (menuItem.tag == MENU_ITEM_ENABLE_MUTING) {
            return NO;
        }
    }
    if (menuItem.tag == MENU_ITEM_LAUNCH_AT_LOGIN) {
        menuItem.state = [self.delegate menuBarController_isSetToLaunchAtLogin] ? NSOnState : NSOffState;
    }
    if (menuItem.tag == MENU_ITEM_MUTE_NOTIFICATIONS) {
        menuItem.state = MJUserDefaults.shared.areMuteNotificationsEnabled ? NSOnState : NSOffState;
    }
    if (menuItem.tag == MENU_ITEM_HIDE_MENU_BAR_ICON) {
        menuItem.state = MJUserDefaults.shared.isMenuBarIconHidden ? NSOnState : NSOffState;
    }
    if (menuItem.tag == MENU_ITEM_MUTE_ON_SLEEP) {
        menuItem.state = [self.delegate menuBarController_isSetToMuteOnSleep] ? NSOnState : NSOffState;
    }
    if (menuItem.tag == MENU_ITEM_MUTE_ON_LOCK) {
        menuItem.state = [self.delegate menuBarController_isSetToMuteOnLock] ? NSOnState : NSOffState;
    }
    if (menuItem.tag == MENU_ITEM_MUTE_ON_HEADPHONES) {
        menuItem.state = [self.delegate menuBarController_isSetToMuteOnHeadphones] ? NSOnState : NSOffState;
    }
    if (menuItem.tag == MENU_ITEM_LANGUAGE_SYSTEM ||
        menuItem.tag == MENU_ITEM_LANGUAGE_CHINESE ||
        menuItem.tag == MENU_ITEM_LANGUAGE_ENGLISH) {
        menuItem.state = (MJUserDefaults.shared.language == [self languageForTag:menuItem.tag]) ? NSOnState : NSOffState;
    }

    return YES;
}

- (void)updateMenuIcon:(BOOL)headphonesConnected
{
    self.statusItem.button.image = [self generateMenuIconImage:headphonesConnected];
}

- (NSImage *)generateMenuIconImage:(BOOL)headphonesConnected
{
    if (MJUserDefaults.shared.isMutingDisabled) {
        return [[NSImage imageNamed:headphonesConnected ? @"hp_connected" : @"hp_disconnected_noalpha"]
                imageTintedWithColor:[NSColor colorWithRed:1 green:0.3 blue:0.2 alpha:1.0]];
    } else {
        return [NSImage imageNamed:headphonesConnected ? @"hp_connected" : @"hp_disconnected"];
    }
}

-(void)quit
{
    [self.delegate menuBarController_quit];
}

- (void)forceRemoveFromMenuBar
{
    // Note: this causes the menu bar item to lose its current position.
    //  Next time it shows it'll reset to the leftmost position.
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

@end
