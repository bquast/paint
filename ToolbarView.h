#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PaintTool) {
    PaintToolPencil,
    PaintToolRectSelect,
    // Add more tools here later
};

@protocol ToolbarViewDelegate <NSObject>
- (void)toolbarView:(id)toolbarView didSelectTool:(PaintTool)tool;
@end

@interface ToolbarView : NSView

@property (weak) id<ToolbarViewDelegate> delegate;
@property (assign) PaintTool selectedTool;

@end 