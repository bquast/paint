#import "CanvasView.h"

@implementation CanvasView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _currentStroke = [NSMutableArray array];
        _drawingColor = [NSColor blackColor];
        _lineWidth = 1.0;
        _isDrawing = NO;
        _selectionRect = NSZeroRect;
        _selectionImage = nil;
        _hasSelection = NO;
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
        switch (self.currentTool) {
            case PaintToolPencil: {
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
                break;
            }
                
            case PaintToolRectSelect: {
                if (self.currentStroke.count == 2) {
                    NSPoint start = [[self.currentStroke objectAtIndex:0] pointValue];
                    NSPoint end = [[self.currentStroke objectAtIndex:1] pointValue];
                    
                    // Create rect from two points
                    NSRect selectionRect = NSMakeRect(
                        MIN(start.x, end.x),
                        MIN(start.y, end.y),
                        fabs(end.x - start.x),
                        fabs(end.y - start.y)
                    );
                    
                    // Draw dashed rectangle
                    NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:selectionRect];
                    CGFloat pattern[2] = {4.0, 4.0};
                    [rectPath setLineDash:pattern count:2 phase:0.0];
                    [[NSColor blackColor] set];
                    [rectPath stroke];
                }
                break;
            }
        }
    }

    // Draw the active selection if we have one
    if (self.hasSelection && !self.isDrawing) {
        // Draw the selection rectangle
        NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:self.selectionRect];
        CGFloat pattern[2] = {4.0, 4.0};
        [rectPath setLineDash:pattern count:2 phase:0.0];
        [[NSColor blackColor] set];
        [rectPath stroke];
    }
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
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    switch (self.currentTool) {
        case PaintToolPencil:
            self.isDrawing = YES;
            [self.currentStroke removeAllObjects];
            [self.currentStroke addObject:[NSValue valueWithPoint:point]];
            break;
            
        case PaintToolRectSelect:
            self.isDrawing = YES;
            [self.currentStroke removeAllObjects];
            [self.currentStroke addObject:[NSValue valueWithPoint:point]];
            [self.currentStroke addObject:[NSValue valueWithPoint:point]]; // Add twice for rect
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.isDrawing) return;
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    switch (self.currentTool) {
        case PaintToolPencil:
            [self.currentStroke addObject:[NSValue valueWithPoint:point]];
            break;
            
        case PaintToolRectSelect:
            // Update the second point (maintaining the first point)
            [self.currentStroke replaceObjectAtIndex:1 withObject:[NSValue valueWithPoint:point]];
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
    if (!self.isDrawing) return;
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    switch (self.currentTool) {
        case PaintToolPencil:
            [self.currentStroke addObject:[NSValue valueWithPoint:point]];
            [self commitCurrentStroke];
            break;
            
        case PaintToolRectSelect: {
            // Calculate final selection rectangle
            NSPoint start = [[self.currentStroke objectAtIndex:0] pointValue];
            NSPoint end = [[self.currentStroke objectAtIndex:1] pointValue];
            
            self.selectionRect = NSMakeRect(
                MIN(start.x, end.x),
                MIN(start.y, end.y),
                fabs(end.x - start.x),
                fabs(end.y - start.y)
            );
            
            // Create image from selection area
            if (self.image && !NSIsEmptyRect(self.selectionRect)) {
                NSImage *newSelectionImage = [[NSImage alloc] initWithSize:self.selectionRect.size];
                [newSelectionImage lockFocus];
                
                // Calculate source rect in image coordinates
                NSRect sourceRect = self.selectionRect;
                [self.image drawInRect:NSMakeRect(0, 0, self.selectionRect.size.width, self.selectionRect.size.height)
                            fromRect:sourceRect
                            operation:NSCompositingOperationSourceOver
                            fraction:1.0];
                
                [newSelectionImage unlockFocus];
                self.selectionImage = newSelectionImage;
                self.hasSelection = YES;
            }
            break;
        }
    }
    
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