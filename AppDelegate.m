// AppDelegate.m
#import "AppDelegate.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h> // Import modern UTIs

// Define keys for UserDefaults (if any needed later)
// static NSString * const kSomeImageSettingKey = @"someImageSetting";

// Private interface category
@interface AppDelegate ()
// Private property to hold the main application window.
@property (strong) NSWindow *window;
@end

@implementation AppDelegate

// Called when the application finishes launching.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // --- Window Setup ---
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 600, 400)
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window center];
    [self.window setTitle:@"Paint"]; // Changed title
    [self.window setDelegate:self];
    [self.window setRestorable:YES];
    self.window.identifier = @"paintMainWindow"; // Changed identifier
    [self.window setRestorationClass:[self class]];

    // --- ImageView Setup ---
    // Frame takes up the entire content view initially
    self.imageView = [[NSImageView alloc] initWithFrame:self.window.contentView.bounds];
    [self.imageView setImageScaling:NSImageScaleProportionallyUpOrDown]; // Scale image nicely
    [self.imageView setEditable:NO]; // For now, just display
    [self.imageView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)]; // Resize with window
    // Add image view to the window's content view
    [self.window.contentView addSubview:self.imageView];

    // --- Menu Setup ---
    [self createMainMenu]; // Create the application menu

    // --- Final Window Setup ---
    [self.window makeKeyAndOrderFront:nil];
    [self.window makeMainWindow];

    // Load initial state or handle restoration if needed
    // Example: Restore image view state if saved
    // NSData *imageData = [[NSUserDefaults standardUserDefaults] dataForKey:@"restoredImageData"];
    // if (imageData) {
    //     NSImage *image = [[NSImage alloc] initWithData:imageData];
    //     self.imageView.image = image;
    // }
}

// Creates the main application menu.
- (void)createMainMenu {
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];
    NSApp.mainMenu = mainMenu;

    // --- Application Menu ---
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:@"Application" action:nil keyEquivalent:@""];
    [mainMenu addItem:appMenuItem];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Application"];
    appMenuItem.submenu = appMenu;
    [appMenu addItemWithTitle:[NSString stringWithFormat:@"About %@", @"Paint"] action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Preferences…" action:nil keyEquivalent:@","]; // Placeholder
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Hide Paint" action:@selector(hide:) keyEquivalent:@"h"];
    NSMenuItem *hideOthers = [[NSMenuItem alloc] initWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
    hideOthers.keyEquivalentModifierMask = NSEventModifierFlagOption | NSEventModifierFlagCommand;
    [appMenu addItem:hideOthers];
    [appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit Paint" action:@selector(terminate:) keyEquivalent:@"q"];

    // --- File Menu ---
    NSMenuItem *fileMenuItem = [[NSMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@""];
    [mainMenu addItem:fileMenuItem];
    NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    fileMenuItem.submenu = fileMenu;
    [fileMenu addItemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n"]; // Placeholder for new blank image
    [fileMenu addItemWithTitle:@"Open..." action:@selector(openDocument:) keyEquivalent:@"o"];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
    [fileMenu addItemWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s"]; // Placeholder
    [fileMenu addItemWithTitle:@"Save As…" action:@selector(saveDocumentAs:) keyEquivalent:@"S"]; // Placeholder
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"Page Setup…" action:@selector(runPageLayout:) keyEquivalent:@"P"]; // Might be useful later
    [fileMenu addItemWithTitle:@"Print…" action:@selector(print:) keyEquivalent:@"p"];      // Might be useful later

    // --- Edit Menu (Basic) ---
    NSMenuItem *editMenuItem = [[NSMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:@""];
    [mainMenu addItem:editMenuItem];
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    editMenuItem.submenu = editMenu;
    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];               // Placeholder
    [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];              // Placeholder
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];            // Placeholder
    [editMenu addItemWithTitle:@"Delete" action:@selector(delete:) keyEquivalent:@""];          // Placeholder
    [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"]; // Placeholder


    // --- Window Menu ---
    NSMenuItem *windowMenuItem = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
    [mainMenu addItem:windowMenuItem];
    NSMenu *windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
    windowMenuItem.submenu = windowMenu;
    [windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
    [windowMenu addItemWithTitle:@"Zoom" action:@selector(performZoom:) keyEquivalent:@""];
    [windowMenu addItem:[NSMenuItem separatorItem]];
    [windowMenu addItemWithTitle:@"Bring All to Front" action:@selector(arrangeInFront:) keyEquivalent:@""];

    // --- Help Menu ---
    NSMenuItem *helpMenuItem = [[NSMenuItem alloc] initWithTitle:@"Help" action:nil keyEquivalent:@""];
    [mainMenu addItem:helpMenuItem];
    NSMenu *helpMenu = [[NSMenu alloc] initWithTitle:@"Help"];
    helpMenuItem.submenu = helpMenu;
    [helpMenu addItemWithTitle:@"Paint Help" action:@selector(showHelp:) keyEquivalent:@"?"]; // Placeholder

    // Assign menus to the application
    [NSApp setHelpMenu:helpMenu]; // Important for "?" key equivalent
    [NSApp setWindowsMenu:windowMenu]; // Important for standard window management
}

// Action method for the "Open..." menu item.
- (IBAction)openDocument:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    // Allow image types - add more as needed
    // Using modern UTType constants after importing UniformTypeIdentifiers
    panel.allowedContentTypes = @[UTTypePNG, UTTypeJPEG, UTTypeBMP, UTTypeGIF, UTTypeTIFF];
    panel.allowsMultipleSelection = NO;
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;

    if ([panel runModal] == NSModalResponseOK) {
        NSURL *fileURL = panel.URL;
        [self loadImageFromURL:fileURL];
    }
}

// Action method for "Save" (placeholder)
- (IBAction)saveDocument:(id)sender {
     if (self.currentFileURL) {
         // TODO: Implement saving image data to self.currentFileURL
         NSLog(@"Placeholder: Save to %@", self.currentFileURL);
          NSAlert *alert = [[NSAlert alloc] init];
          [alert setMessageText:@"Save Functionality Not Implemented"];
          [alert setInformativeText:@"Saving the image is not yet supported."];
          [alert addButtonWithTitle:@"OK"];
          [alert beginSheetModalForWindow:self.window completionHandler:nil];
     } else {
         // If no current file URL, behave like Save As...
         [self saveDocumentAs:sender];
     }
}


// Action method for "Save As..." (placeholder)
- (IBAction)saveDocumentAs:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    // Using modern UTType constants after importing UniformTypeIdentifiers
    panel.allowedContentTypes = @[UTTypePNG]; // Default to PNG for saving
    panel.canCreateDirectories = YES;
    panel.title = @"Save Image As";
    panel.message = @"Choose a location and format to save the image.";
    panel.nameFieldStringValue = @"Untitled.png"; // Default name

    if ([panel runModal] == NSModalResponseOK) {
        NSURL *fileURL = panel.URL;
        // TODO: Implement saving self.imageView.image to fileURL
        // Need to get image data (e.g., NSBitmapImageRep) and write to disk.
        NSLog(@"Placeholder: Save As to %@", fileURL);
         NSAlert *alert = [[NSAlert alloc] init];
          [alert setMessageText:@"Save As Functionality Not Implemented"];
          [alert setInformativeText:@"Saving the image is not yet supported."];
          [alert addButtonWithTitle:@"OK"];
          [alert beginSheetModalForWindow:self.window completionHandler:nil];

        // Update current file URL after successful save
        // self.currentFileURL = fileURL;
        // self.window.representedURL = fileURL; // Update window proxy icon/title
        // [self.window setTitleWithRepresentedFilename:fileURL.lastPathComponent];
    }
}

// Action method for "New" (placeholder)
- (IBAction)newDocument:(id)sender {
    // TODO: Implement creating a new blank canvas (e.g., a white NSImage)
    NSLog(@"Placeholder: New Document");
     self.imageView.image = nil; // Clear current image for now
     self.currentFileURL = nil;
     [self.window setTitle:@"Paint - Untitled"];
     self.window.representedURL = nil;
     NSAlert *alert = [[NSAlert alloc] init];
     [alert setMessageText:@"New Functionality Not Implemented"];
     [alert setInformativeText:@"Creating a new blank image is not yet supported."];
     [alert addButtonWithTitle:@"OK"];
     [alert beginSheetModalForWindow:self.window completionHandler:nil];
}


// Helper method to load an image from a URL
- (void)loadImageFromURL:(NSURL *)fileURL {
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:fileURL];
    if (image) {
        self.imageView.image = image;
        self.currentFileURL = fileURL;
        self.window.representedURL = fileURL; // Show proxy icon in title bar
        [self.window setTitleWithRepresentedFilename:fileURL.lastPathComponent];
    } else {
        // Handle error loading image
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Error Opening Image"];
        [alert setInformativeText:[NSString stringWithFormat:@"Could not open the image file at: %@", fileURL.path]];
        [alert setAlertStyle:NSAlertStyleWarning];
         if (self.window) {
            [alert beginSheetModalForWindow:self.window completionHandler:nil];
         } else {
             [alert runModal];
         }
    }
}


// --- NSApplicationDelegate Methods ---

// Handle opening files via Finder, Dock, etc.
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    NSURL *fileURL = [NSURL fileURLWithPath:filename];
    // Ensure the window is created if the app wasn't running
    if (!self.window) {
        // If applicationDidFinishLaunching hasn't run yet, let it handle the setup.
        // We might need a way to pass the fileURL to applicationDidFinishLaunching
        // or handle it slightly differently if launched via file opening.
        // For simplicity now, assume the window exists or will be created shortly.
         NSLog(@"Warning: application:openFile: called before window was ready.");
         // A more robust solution would queue the fileURL to be opened after launch finishes.
         return NO; // Indicate failure for now if window isn't ready
    }

    [self loadImageFromURL:fileURL];
    return YES; // Indicate success
}


// Delegate method called before the application terminates.
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    // Example: Save unsaved changes or state
    // [[NSUserDefaults standardUserDefaults] synchronize];
}

// Delegate method to determine if the app should terminate when the last window is closed.
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

// Required for window restoration
+ (void)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler {
     AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
     if (appDelegate.window && [identifier isEqualToString:@"paintMainWindow"]) { // Use updated identifier
         completionHandler(appDelegate.window, nil);
         // TODO: Restore image state if needed
         // NSURL *fileURL = [state decodeObjectForKey:@"imageFileURL"];
         // if (fileURL) {
         //    [appDelegate loadImageFromURL:fileURL];
         // }
     } else {
         NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Window restoration failed."}];
         completionHandler(nil, error);
     }
}

// Encode state for window restoration
- (void)window:(NSWindow *)window willEncodeRestorableState:(NSCoder *)state {
     // Example: Save the URL of the currently open image
     if (self.currentFileURL) {
         [state encodeObject:self.currentFileURL forKey:@"imageFileURL"];
     }
     // Example: Save image data directly (might be large)
     // NSImage *currentImage = self.imageView.image;
     // if (currentImage) {
     //     NSData *imageData = [currentImage TIFFRepresentation]; // Or PNG representation
     //     if (imageData) {
     //         [state encodeObject:imageData forKey:@"imageData"];
     //     }
     // }
}

// Decode state for window restoration (alternative to doing it in restoreWindowWithIdentifier)
- (void)window:(NSWindow *)window didDecodeRestorableState:(NSCoder *)state {
     // This might be called *after* applicationDidFinishLaunching
     // Check if image already loaded to avoid double-loading
     if (!self.imageView.image) {
          NSURL *fileURL = [state decodeObjectOfClass:[NSURL class] forKey:@"imageFileURL"];
          if (fileURL) {
              [self loadImageFromURL:fileURL];
          }
          // else if ([state containsValueForKey:@"imageData"]) {
          //     NSData *imageData = [state decodeObjectOfClass:[NSData class] forKey:@"imageData"];
          //     if (imageData) {
          //         NSImage *image = [[NSImage alloc] initWithData:imageData];
          //         self.imageView.image = image;
          //         // Might need to reconstruct currentFileURL if possible or leave it nil
          //     }
          // }
     }
}


// Opt-in to secure state restoration (recommended)
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

// Register default user defaults (if needed)
+ (void)initialize {
    if (self == [AppDelegate class]) {
        // Set default values if any image-related settings are added
        // NSDictionary *defaults = @{kSomeImageSettingKey: @YES};
        // [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
}


@end

