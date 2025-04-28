#import "CanvasView.h"

@implementation CanvasView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _currentStroke = [NSMutableArray array];
        _drawingColor = [NSColor blackColor];
        _lineWidth = 1.0;
        _isDrawing = NO;
    }
    return self;
}

// Custom drawing method.
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Fill background with white
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
    
    if (self.image) {
        // Draw the main image
        [self.image drawInRect:self.bounds 
                    fromRect:NSZeroRect 
                    operation:NSCompositingOperationSourceOver 
                    fraction:1.0 
                    respectFlipped:YES 
                    hints:nil];
    }
    
    // Draw the current stroke if we're in the middle of drawing
    if (self.isDrawing && self.currentStroke.count > 0) {
        NSBezierPath *strokePath = [NSBezierPath bezierPath];
        NSPoint firstPoint = [[self.currentStroke firstObject] pointValue];
        [strokePath moveToPoint:firstPoint];
        
        for (NSValue *pointValue in self.currentStroke) {
            NSPoint point = [pointValue pointValue];
            [strokePath lineToPoint:point];
        }
        
        [strokePath setLineWidth:self.lineWidth];
        [self.drawingColor set];
        [strokePath stroke];
    }

    // Drawing code for tools (selection, lines, etc.) will go here later
}

// Override isFlipped to make the coordinate system start at the top-left,
// which is often more intuitive for image manipulation.
- (BOOL)isFlipped {
    return NO;
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

- (void)mouseDown:(NSEvent *)event {
    self.isDrawing = YES;
    [self.currentStroke removeAllObjects];
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    [self.currentStroke addObject:[NSValue valueWithPoint:point]];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.isDrawing) return;
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    [self.currentStroke addObject:[NSValue valueWithPoint:point]];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
    if (!self.isDrawing) return;
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    [self.currentStroke addObject:[NSValue valueWithPoint:point]];
    [self commitCurrentStroke];
    
    self.isDrawing = NO;
    [self setNeedsDisplay:YES];
}

- (void)commitCurrentStroke {
    if (self.currentStroke.count == 0) return;
    
    // Create an image context the same size as our view
    NSSize size = self.bounds.size;
    NSImage *newImage = [[NSImage alloc] initWithSize:size];
    [newImage lockFocus];
    
    // Draw existing image
    if (self.image) {
        [self.image drawInRect:NSMakeRect(0, 0, size.width, size.height) 
                    fromRect:NSZeroRect 
                    operation:NSCompositingOperationSourceOver 
                    fraction:1.0 
                    respectFlipped:YES 
                    hints:nil];
    }
    
    // Draw the stroke
    NSBezierPath *strokePath = [NSBezierPath bezierPath];
    NSPoint firstPoint = [[self.currentStroke firstObject] pointValue];
    [strokePath moveToPoint:firstPoint];
    
    for (NSValue *pointValue in self.currentStroke) {
        NSPoint point = [pointValue pointValue];
        [strokePath lineToPoint:point];
    }
    
    [strokePath setLineWidth:self.lineWidth];
    [self.drawingColor set];
    [strokePath stroke];
    
    [newImage unlockFocus];
    
    self.image = newImage;
    
    // Clear the current stroke
    [self.currentStroke removeAllObjects];
}

@end 