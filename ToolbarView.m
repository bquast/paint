#import "ToolbarView.h"

@interface ToolbarView ()
@property (strong) NSArray<NSButton *> *toolButtons;
@end

@implementation ToolbarView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupToolButtons];
        self.selectedTool = PaintToolPencil; // Default tool
    }
    return self;
}

- (void)setupToolButtons {
    NSMutableArray *buttons = [NSMutableArray array];
    
    // Pencil Tool Button
    NSButton *pencilButton = [self createToolButtonWithTitle:@"✏️" 
                                                    toolType:PaintToolPencil 
                                                        tag:0];
    [buttons addObject:pencilButton];
    
    // Rectangle Select Tool Button
    NSButton *rectSelectButton = [self createToolButtonWithTitle:@"⬚" 
                                                      toolType:PaintToolRectSelect 
                                                          tag:1];
    [buttons addObject:rectSelectButton];
    
    // Text Tool Button
    NSButton *textButton = [self createToolButtonWithTitle:@"A" 
                                                toolType:PaintToolText 
                                                    tag:2];
    [buttons addObject:textButton];
    
    self.toolButtons = buttons;
    
    // Set initial state
    [self selectToolButton:pencilButton];
}

- (NSButton *)createToolButtonWithTitle:(NSString *)title toolType:(PaintTool)toolType tag:(NSInteger)tag {
    NSRect buttonFrame = NSMakeRect(4, self.bounds.size.height - (30 * (tag + 1)) - 4, 32, 32);
    NSButton *button = [[NSButton alloc] initWithFrame:buttonFrame];
    
    button.title = title;
    button.tag = toolType;
    button.bezelStyle = NSBezelStyleRegularSquare;
    button.buttonType = NSButtonTypeToggle;
    [button setAutoresizingMask:NSViewMinYMargin];
    [button setTarget:self];
    [button setAction:@selector(toolButtonClicked:)];
    
    [self addSubview:button];
    return button;
}

- (void)toolButtonClicked:(NSButton *)sender {
    [self selectToolButton:sender];
    
    PaintTool selectedTool = (PaintTool)sender.tag;
    self.selectedTool = selectedTool;
    
    if ([self.delegate respondsToSelector:@selector(toolbarView:didSelectTool:)]) {
        [self.delegate toolbarView:self didSelectTool:selectedTool];
    }
}

- (void)selectToolButton:(NSButton *)selectedButton {
    for (NSButton *button in self.toolButtons) {
        button.state = (button == selectedButton) ? NSControlStateValueOn : NSControlStateValueOff;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Fill the toolbar area with a light gray color
    [[NSColor colorWithWhite:0.9 alpha:1.0] setFill];
    NSRectFill(dirtyRect);
    
    // Draw a border line on the right
    [[NSColor colorWithWhite:0.7 alpha:1.0] set];
    NSRect borderRect = NSMakeRect(NSMaxX(self.bounds) - 1, 0, 1, NSHeight(self.bounds));
    NSRectFill(borderRect);
}

// Optional: Override isFlipped if needed, usually not necessary for a toolbar.
// - (BOOL)isFlipped {
//     return YES;
// }

@end 