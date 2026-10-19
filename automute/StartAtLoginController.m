// Copyright (c) 2011 Alex Zielenski
// Copyright (c) 2012 Travis Tilley
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense,  and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "StartAtLoginController.h"
#import <ServiceManagement/ServiceManagement.h>

/// SMAppService only: the app registers itself.
///
/// The old mechanism was a LoginItems helper bundle toggled through
///  SMLoginItemSetEnabled, plus an app group so the helper could tell the app it
///  had been launched at login. All of it is gone, because
///  SMLoginItemSetEnabled has been deprecated since macOS 13 — which this app
///  now requires — and because a helper is no longer how login items work.
@implementation StartAtLoginController

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;

    if ([theKey isEqualToString:@"startAtLogin"]) {
        automatic = NO;
    } else {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }

    return automatic;
}

/// A registration the user has not approved yet in System Settings still counts
///  as on: otherwise the menu checkbox would flip itself back off the instant it
///  was ticked, and the user would never see why.
static BOOL MJLoginItemIsRegistered(void)
{
    SMAppServiceStatus status = SMAppService.mainAppService.status;
    return status == SMAppServiceStatusEnabled || status == SMAppServiceStatusRequiresApproval;
}

- (BOOL)startAtLogin {
    return MJLoginItemIsRegistered();
}

- (void)setStartAtLogin:(BOOL)flag {
    [self willChangeValueForKey:@"startAtLogin"];

    NSError *error = nil;
    SMAppService *service = SMAppService.mainAppService;
    BOOL success = flag ? [service registerAndReturnError:&error]
                        : [service unregisterAndReturnError:&error];
    if (!success) {
        NSLog(@"SMAppService %@ failed: %@", flag ? @"register" : @"unregister", error);
    } else if (flag && service.status == SMAppServiceStatusRequiresApproval) {
        /// The user has to allow it in System Settings -> General -> Login Items.
        [SMAppService openSystemSettingsLoginItems];
    }

    [self didChangeValueForKey:@"startAtLogin"];
}

@end
