#import "LaunchAtLoginPopupView.h"
#import "MJStrings.h"

@implementation LaunchAtLoginPopupView

- (void)awakeFromNib
{
    [super awakeFromNib];

    MJLocalizeViewTree(self);
}

@end
