#import <Cocoa/Cocoa.h>

/// Returns the Chinese wording of `english`, or `english` itself when the
///  resolved language is not Chinese.
///
/// `english` doubles as the source string and the lookup key — the trick gettext
///  uses. It keeps every call site readable, makes the table in MJStrings.m the
///  single glossary, and means picking English gives exactly the upstream
///  wording. Unknown strings fall through untouched, so a missed entry degrades
///  to English instead of to an empty menu item.
NSString *MJStr(NSString *english);

/// Localizes an already-loaded view tree in place: every text field's value and
///  every button's title goes through MJStr().
///
/// The two onboarding popups need this. Interface Builder bakes their text into
///  the nib, and a nib knows nothing about an in-app language switch, so their
///  strings are translated after loading instead of in the nib.
void MJLocalizeViewTree(NSView *view);
