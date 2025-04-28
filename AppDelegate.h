// AppDelegate.h
#import <Cocoa/Cocoa.h>
#import "ToolbarView.h"

// Declare the AppDelegate interface.
// It conforms to NSApplicationDelegate, NSWindowDelegate,
// and NSWindowRestoration to handle app lifecycle, window events,
// and window state restoration.
@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSWindowRestoration, ToolbarViewDelegate>

// Property to hold the main image view where editing will happen.
@property (strong) NSImageView *imageView;
// Property to hold the currently loaded image URL for saving purposes.
@property (strong) NSURL *currentFileURL;


@end

