#import "ColorBarView.h"

@implementation ColorBarView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _colors = @[
            [NSColor blackColor],
            [NSColor darkGrayColor],
            [NSColor redColor],
            [NSColor orangeColor],
            [NSColor yellowColor],
            [NSColor greenColor],
            [NSColor blueColor],
            [NSColor purpleColor],
            [NSColor brownColor],
            [NSColor whiteColor],
            [NSColor lightGrayColor],
            [NSColor magentaColor],
            [NSColor cyanColor],
        ];
        _selectedColor = [NSColor blackColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGFloat colorWidth = NSWidth(self.bounds) / self.colors.count;
    CGFloat colorHeight = NSHeight(self.bounds);
    
    [self.colors enumerateObjectsUsingBlock:^(NSColor *color, NSUInteger idx, BOOL *stop) {
        NSRect colorRect = NSMakeRect(idx * colorWidth, 0, colorWidth, colorHeight);
        
        // Draw color
        [color set];
        NSRectFill(colorRect);
        
        // Draw border
        [[NSColor lightGrayColor] set];
        NSFrameRect(colorRect);
        
        // Draw selection indicator
        if ([color isEqual:self.selectedColor]) {
            [[NSColor whiteColor] set];
            NSFrameRect(NSInsetRect(colorRect, 1, 1));
            [[NSColor blackColor] set];
            NSFrameRect(NSInsetRect(colorRect, 2, 2));
        }
    }];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat colorWidth = NSWidth(self.bounds) / self.colors.count;
    NSInteger colorIndex = floor(point.x / colorWidth);
    
    if (colorIndex >= 0 && colorIndex < self.colors.count) {
        self.selectedColor = self.colors[colorIndex];
        [self.delegate colorSelected:self.selectedColor];
        [self setNeedsDisplay:YES];
    }
}

@end 