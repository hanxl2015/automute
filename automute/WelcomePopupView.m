#import "WelcomePopupView.h"
#import "MJStrings.h"
#import "NSImage+YLUtil.h"


@implementation WelcomePopupView

- (void)awakeFromNib
{
    [super awakeFromNib];

    MJLocalizeViewTree(self);

    // To support Dark Mode.
    [self.connectedImage.image setTemplate:YES];
    [self.disconnectedImage.image setTemplate:YES];
}

@end
