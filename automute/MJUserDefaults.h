#import <Foundation/Foundation.h>

/// Which language the UI is shown in. `MJLanguageSystem` — the default — means
///  "whatever the system says", which is also what macOS shows for the per-app
///  language setting in System Settings -> General -> Language & Region.
typedef NS_ENUM(NSInteger, MJLanguage) {
    MJLanguageSystem = 0,
    MJLanguageChinese,
    MJLanguageEnglish,
};

@interface MJUserDefaults : NSObject

+ (instancetype)shared;

-(void)setSawWelcomeScreen;
-(BOOL)didSeeWelcomeScreen;

- (void)setSawLaunchAtLoginPopup;
- (BOOL)didSeeLaunchAtLoginPopup;

- (BOOL)isMutingDisabled;
- (void)setMutingDisabled:(BOOL)b;

- (void)setScheduledTimeToEnableMuting:(NSTimeInterval)date;
- (NSTimeInterval)getScheduledTimeToEnableMuting;

- (BOOL)isSetToMuteOnSleep;
- (void)setMuteOnSleep:(BOOL)muteOnSleep;

- (BOOL)isSetToMuteOnLock;
- (void)setMuteOnLock:(BOOL)muteOnLock;

- (BOOL)isSetToMuteOnHeadphones;
- (void)setMuteOnHeadphones:(BOOL)muteOnHeadphones;

- (BOOL)areMuteNotificationsEnabled;
- (void)setMuteNotificationsEnabled:(BOOL)muteNotificationsEnabled;

- (BOOL)isMenuBarIconHidden;
- (void)setMenuBarIconHidden:(BOOL)menuBarIconHidden;

- (MJLanguage)language;
- (void)setLanguage:(MJLanguage)language;
@end
