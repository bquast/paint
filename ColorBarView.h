#import <Cocoa/Cocoa.h>

@protocol ColorBarDelegate <NSObject>
- (void)colorSelected:(NSColor *)color;
@end

@interface ColorBarView : NSView

@property (weak) id<ColorBarDelegate> delegate;
@property (strong) NSArray<NSArray<NSColor *> *> *colors;
@property (strong) NSColor *selectedColor;

@end 