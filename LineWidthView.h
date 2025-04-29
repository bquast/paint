#import <Cocoa/Cocoa.h>

@protocol LineWidthViewDelegate <NSObject>
- (void)lineWidthSelected:(CGFloat)width;
@end

@interface LineWidthView : NSView

@property (weak) id<LineWidthViewDelegate> delegate;
@property (assign) CGFloat selectedWidth;
@property (strong) NSArray<NSNumber *> *availableWidths;

@end 