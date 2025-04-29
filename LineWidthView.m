#import "LineWidthView.h"

@implementation LineWidthView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _availableWidths = @[@1.0, @2.0, @3.0, @4.0, @5.0];
        _selectedWidth = 1.0;
        
        // Set background color
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor colorWithWhite:0.9 alpha:1.0].CGColor;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGFloat itemHeight = NSHeight(self.bounds) / self.availableWidths.count;
    
    [self.availableWidths enumerateObjectsUsingBlock:^(NSNumber *width, NSUInteger idx, BOOL *stop) {
        NSRect itemRect = NSMakeRect(0, idx * itemHeight, NSWidth(self.bounds), itemHeight);
        
        // Draw background if selected
        if (width.doubleValue == self.selectedWidth) {
            [[NSColor colorWithWhite:0.8 alpha:1.0] set];
            NSRectFill(itemRect);
        }
        
        // Draw line preview
        NSRect lineRect = NSMakeRect(10, 
                                   itemRect.origin.y + (itemHeight/2), 
                                   NSWidth(self.bounds) - 20, 
                                   width.doubleValue);
        [[NSColor blackColor] set];
        NSRectFill(lineRect);
    }];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat itemHeight = NSHeight(self.bounds) / self.availableWidths.count;
    NSInteger index = floor(point.y / itemHeight);
    
    if (index >= 0 && index < self.availableWidths.count) {
        self.selectedWidth = self.availableWidths[index].doubleValue;
        [self.delegate lineWidthSelected:self.selectedWidth];
        [self setNeedsDisplay:YES];
    }
}

@end 