#import "ToolbarView.h"

@implementation ToolbarView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Fill the toolbar area with a light gray color as a placeholder
    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);

    // Draw a border line on the right
    [[NSColor darkGrayColor] set];
    NSRect borderRect = NSMakeRect(NSMaxX(self.bounds) - 1, 0, 1, NSHeight(self.bounds));
    NSRectFill(borderRect);
}

// Optional: Override isFlipped if needed, usually not necessary for a toolbar.
// - (BOOL)isFlipped {
//     return YES;
// }

@end 