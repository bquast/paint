#import <Cocoa/Cocoa.h>
#import "ToolbarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CanvasView : NSView

// The image being displayed and edited.
@property (nonatomic, strong, nullable) NSImage *image;
@property (strong) NSMutableArray *currentStroke; // Array of points for current pencil stroke
@property (assign) BOOL isDrawing;                // Track if we're in the middle of drawing
@property (strong) NSColor *drawingColor;         // Current drawing color (default black)
@property (assign) CGFloat lineWidth;             // Width of the pencil line
@property (assign) PaintTool currentTool;  // Add this property
@property (assign) NSRect selectionRect;     // Store the current selection rectangle
@property (strong) NSImage *selectionImage;  // Store the selected portion of the image
@property (assign) BOOL hasSelection;        // Track if we have an active selection
@property (assign) BOOL isDraggingSelection;  // Track if we're moving the selection
@property (assign) NSPoint dragOffset;        // Store where in the selection we clicked
@property (strong) NSString *currentText;        // Text being edited
@property (assign) NSPoint textPosition;         // Where text will be drawn
@property (assign) BOOL isEditingText;           // Track if we're editing text
@property (strong) NSFont *textFont;             // Font for text tool

- (void)commitCurrentStroke;  // Method to apply the current stroke to the image

@end

NS_ASSUME_NONNULL_END 