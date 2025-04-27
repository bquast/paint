#import "CanvasView.h"

@implementation CanvasView

// Custom drawing method.
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Fill background with white (or a pattern later)
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);

    if (self.image) {
        // Calculate drawing rectangle to maintain aspect ratio (optional, simple draw for now)
        // For simplicity, draw the image anchored at the top-left.
        // You might want more sophisticated scaling/centering later.
        NSRect imageRect = NSMakeRect(0, 0, self.image.size.width, self.image.size.height);

        // Draw the image in the view's coordinate system.
        // `fromRect:imageRect` specifies the portion of the image to draw.
        // `operation:NSCompositingOperationSourceOver` is standard drawing.
        // `fraction:1.0` means fully opaque.
        [self.image drawInRect:self.bounds fromRect:imageRect operation:NSCompositingOperationSourceOver fraction:1.0];
    }

    // Drawing code for tools (selection, lines, etc.) will go here later
}

// Override isFlipped to make the coordinate system start at the top-left,
// which is often more intuitive for image manipulation.
- (BOOL)isFlipped {
    return YES;
}

// Setter for the image property.
// When the image changes, we need to redraw the view.
- (void)setImage:(NSImage *)newImage {
    if (_image != newImage) {
        _image = newImage;
        // Mark the entire view as needing to be redrawn.
        [self setNeedsDisplay:YES];
    }
}

@end 