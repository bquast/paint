#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CanvasView : NSView

// The image being displayed and edited.
@property (nonatomic, strong, nullable) NSImage *image;

@end

NS_ASSUME_NONNULL_END 