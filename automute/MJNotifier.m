#import "MJNotifier.h"
#import "MJStrings.h"
#import "MJUserDefaults.h"

@interface MJNotifier() <NSUserNotificationCenterDelegate>
/// Empty.
@end

@implementation MJNotifier

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;

    return self;
}

- (void)showHeadphonesDisconnectedMuteNotification
{
    [self showNotificationWithTitle:MJStr(@"Headphones Disconnected") body:MJStr(@"Sound Muted.")];
}

- (void)showSleepMuteNotification
{
    [self showNotificationWithTitle:MJStr(@"Woke up from sleep") body:MJStr(@"Sound Muted.")];
}

- (void)showLockMuteNotification
{
    [self showNotificationWithTitle:MJStr(@"Unlocked") body:MJStr(@"Sound Muted.")];
}

- (void)showNotificationWithTitle:(NSString *)title
                             body:(NSString *)body
{
    if (!MJUserDefaults.shared.areMuteNotificationsEnabled) return;

    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = body;

    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
