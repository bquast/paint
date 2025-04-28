#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CanvasView : NSView

// The image being displayed and edited.
@property (nonatomic, strong, nullable) NSImage *image;
@property (strong) NSMutableArray *currentStroke; // Array of points for current pencil stroke
@property (assign) BOOL isDrawing;                // Track if we're in the middle of drawing
@property (strong) NSColor *drawingColor;         // Current drawing color (default black)
@property (assign) CGFloat lineWidth;             // Width of the pencil line

- (void)commitCurrentStroke;  // Method to apply the current stroke to the image

@end

NS_ASSUME_NONNULL_END 