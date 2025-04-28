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
        _isDraggingSelection = NO;
        _dragOffset = NSZeroPoint;
        _textFont = [NSFont systemFontOfSize:12.0];
        _currentText = @"";
        _isEditingText = NO;
        [self setAcceptsTouchEvents:YES];
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
                BOOL hasStarted = NO;
                
                for (NSValue *pointValue in self.currentStroke) {
                    NSPoint point = [pointValue pointValue];
                    
                    // Only draw points that are within the canvas
                    if ([self isPointInCanvas:point]) {
                        if (!hasStarted) {
                            [strokePath moveToPoint:point];
                            hasStarted = YES;
                        } else {
                            [strokePath lineToPoint:point];
                        }
                    }
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

    // Draw the selection content and rectangle
    if (self.hasSelection && !self.isDrawing) {
        if (self.selectionImage) {
            [self.selectionImage drawInRect:self.selectionRect
                                 fromRect:NSZeroRect
                                operation:NSCompositingOperationSourceOver
                                 fraction:1.0];
        }
        
        // Draw the selection rectangle
        NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:self.selectionRect];
        CGFloat pattern[2] = {4.0, 4.0};
        [rectPath setLineDash:pattern count:2 phase:0.0];
        [[NSColor blackColor] set];
        [rectPath stroke];
    }

    // Draw current text if editing
    if (self.isEditingText && self.currentText) {
        NSDictionary *attrs = @{
            NSFontAttributeName: self.textFont,
            NSForegroundColorAttributeName: self.drawingColor
        };
        [self.currentText drawAtPoint:self.textPosition withAttributes:attrs];
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

- (BOOL)isPointInCanvas:(NSPoint)point {
    return NSPointInRect(point, self.bounds);
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    // If we're editing text and click elsewhere, commit it first
    if (self.isEditingText) {
        [self commitText];
    }
    
    // Check if we clicked inside an existing selection
    if (self.hasSelection && NSPointInRect(point, self.selectionRect)) {
        self.isDraggingSelection = YES;
        // Calculate offset from selection origin to click point
        self.dragOffset = NSMakePoint(
            point.x - self.selectionRect.origin.x,
            point.y - self.selectionRect.origin.y
        );
        return;
    }
    
    // If we didn't click in selection, commit it before clearing
    if (self.hasSelection) {
        [self commitSelection];  // This will save the selection at its current position
    }
    
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
            
        case PaintToolText: {
            if ([self isPointInCanvas:point]) {
                self.textPosition = point;
                self.isEditingText = YES;
                self.currentText = @"";
                [self setNeedsDisplay:YES];
                [[self window] makeFirstResponder:self];
            }
            break;
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    if (self.isDraggingSelection) {
        // Create new rect with updated origin
        self.selectionRect = NSMakeRect(
            point.x - self.dragOffset.x,
            point.y - self.dragOffset.y,
            NSWidth(self.selectionRect),
            NSHeight(self.selectionRect)
        );
        [self setNeedsDisplay:YES];
        return;
    }
    
    if (!self.isDrawing) return;
    
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
    if (self.isDraggingSelection) {
        self.isDraggingSelection = NO;
        [self setNeedsDisplay:YES];
        return;
    }
    
    if (!self.isDrawing) return;
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    switch (self.currentTool) {
        case PaintToolPencil:
            [self.currentStroke addObject:[NSValue valueWithPoint:point]];
            [self commitCurrentStroke];
            break;
            
        case PaintToolRectSelect: {
            if (self.currentStroke.count == 2) {
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
                    // Create transparent selection image
                    NSImage *newSelectionImage = [[NSImage alloc] initWithSize:self.selectionRect.size];
                    [newSelectionImage lockFocus];
                    
                    // Fill with white background first
                    [[NSColor whiteColor] set];
                    NSRectFill(NSMakeRect(0, 0, self.selectionRect.size.width, self.selectionRect.size.height));
                    
                    // Draw just the portion of the main image we want
                    [self.image drawInRect:NSMakeRect(0, 0, self.selectionRect.size.width, self.selectionRect.size.height)
                                fromRect:self.selectionRect
                                operation:NSCompositingOperationSourceOver
                                fraction:1.0];
                    
                    [newSelectionImage unlockFocus];
                    
                    // Clear the selected area in the main image
                    NSImage *newMainImage = [[NSImage alloc] initWithSize:self.bounds.size];
                    [newMainImage lockFocus];
                    
                    // Draw the existing image
                    [self.image drawInRect:self.bounds
                                fromRect:NSZeroRect
                                operation:NSCompositingOperationSourceOver
                                fraction:1.0];
                    
                    // Fill the selected area with white
                    [[NSColor whiteColor] set];
                    NSRectFill(self.selectionRect);
                    
                    [newMainImage unlockFocus];
                    
                    // Update both the selection and main image
                    self.selectionImage = newSelectionImage;
                    self.image = newMainImage;
                    self.hasSelection = YES;
                }
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

// Add copy/paste support
- (void)copy:(id)sender {
    if (!self.hasSelection || self.selectionImage == NULL) return;
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[self.selectionImage]];
}

- (void)cut:(id)sender {
    if (!self.hasSelection || self.selectionImage == NULL) return;
    
    // Copy first
    [self copy:sender];
    
    // Then delete
    [self delete:sender];
}

- (void)paste:(id)sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classArray = @[[NSImage class]];
    NSDictionary *options = @{};
    
    BOOL canRead = [pasteboard canReadObjectForClasses:classArray options:options];
    if (canRead) {
        NSArray *objects = [pasteboard readObjectsForClasses:classArray options:options];
        NSImage *pastedImage = objects.firstObject;
        if (pastedImage) {
            // Create new selection with pasted image
            self.selectionImage = pastedImage;
            self.selectionRect = NSMakeRect(20, 20, pastedImage.size.width, pastedImage.size.height);
            self.hasSelection = YES;
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)delete:(id)sender {
    if (!self.hasSelection) return;
    
    // Clear the selection
    self.hasSelection = NO;
    self.selectionImage = NULL;
    
    // Redraw the view without the selection
    [self setNeedsDisplay:YES];
}

// Add this method to commit the selection to the main image
- (void)commitSelection {
    if (!self.hasSelection || self.selectionImage == NULL) return;
    
    NSImage *newImage = [[NSImage alloc] initWithSize:self.bounds.size];
    [newImage lockFocus];
    
    // Draw existing image
    if (self.image) {
        [self.image drawInRect:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height)
                    fromRect:NSZeroRect
                    operation:NSCompositingOperationSourceOver
                    fraction:1.0];
    }
    
    // Draw selection at its current position
    [self.selectionImage drawInRect:self.selectionRect
                         fromRect:NSZeroRect
                        operation:NSCompositingOperationSourceOver
                         fraction:1.0];
    
    [newImage unlockFocus];
    
    self.image = newImage;
    self.hasSelection = NO;
    self.selectionImage = NULL;
    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    if (self.currentTool == PaintToolText && self.isEditingText) {
        if (event.keyCode == 36) { // Return key
            [self commitText];
        } else {
            self.currentText = [self.currentText stringByAppendingString:event.characters];
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)commitText {
    if (self.currentText.length == 0) {
        self.isEditingText = NO;
        return;
    }
    
    NSImage *newImage = [[NSImage alloc] initWithSize:self.bounds.size];
    [newImage lockFocus];
    
    // Draw existing image
    if (self.image) {
        [self.image drawInRect:self.bounds];
    }
    
    // Draw the text
    NSDictionary *attrs = @{
        NSFontAttributeName: self.textFont,
        NSForegroundColorAttributeName: self.drawingColor
    };
    [self.currentText drawAtPoint:self.textPosition withAttributes:attrs];
    
    [newImage unlockFocus];
    
    // Update the main image
    self.image = newImage;
    self.isEditingText = NO;
    self.currentText = @"";
    [self setNeedsDisplay:YES];
}

@end 