#import "ColorBarView.h"

@implementation ColorBarView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create pairs of colors (dark and bright versions)
        _colors = @[
            // First row (darker shades)
            @[
                [NSColor blackColor],
                [NSColor colorWithRed:0.5 green:0 blue:0 alpha:1.0],        // Dark Red
                [NSColor colorWithRed:0.5 green:0.25 blue:0 alpha:1.0],    // Dark Orange
                [NSColor colorWithRed:0.5 green:0.5 blue:0 alpha:1.0],     // Dark Yellow
                [NSColor colorWithRed:0 green:0.5 blue:0 alpha:1.0],       // Dark Green
                [NSColor colorWithRed:0 green:0 blue:0.5 alpha:1.0],       // Dark Blue
                [NSColor colorWithRed:0.5 green:0 blue:0.5 alpha:1.0],     // Dark Purple
                [NSColor colorWithRed:0.3 green:0.2 blue:0.1 alpha:1.0],   // Dark Brown
                [NSColor darkGrayColor]
            ],
            
            // Second row (brighter shades)
            @[
                [NSColor whiteColor],
                [NSColor redColor],
                [NSColor orangeColor],
                [NSColor yellowColor],
                [NSColor greenColor],
                [NSColor blueColor],
                [NSColor purpleColor],
                [NSColor brownColor],
                [NSColor lightGrayColor]
            ]
        ];
        _selectedColor = [NSColor blackColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSArray *firstRow = self.colors[0];
    CGFloat colorWidth = NSWidth(self.bounds) / firstRow.count;
    CGFloat colorHeight = NSHeight(self.bounds) / 2;
    
    // Draw both rows
    for (NSInteger row = 0; row < 2; row++) {
        NSArray<NSColor *> *rowColors = self.colors[row];
        [rowColors enumerateObjectsUsingBlock:^(NSColor *color, NSUInteger idx, BOOL *stop) {
            NSRect colorRect = NSMakeRect(idx * colorWidth, 
                                        row * colorHeight, 
                                        colorWidth, 
                                        colorHeight);
            
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
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    NSArray *firstRow = self.colors[0];
    CGFloat colorWidth = NSWidth(self.bounds) / firstRow.count;
    CGFloat colorHeight = NSHeight(self.bounds) / 2;
    
    NSInteger row = floor(point.y / colorHeight);
    NSInteger col = floor(point.x / colorWidth);
    
    if (row >= 0 && row < 2 && col >= 0 && col < firstRow.count) {
        self.selectedColor = self.colors[row][col];
        [self.delegate colorSelected:self.selectedColor];
        [self setNeedsDisplay:YES];
    }
}

@end 