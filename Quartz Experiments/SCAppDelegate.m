//
//  SCAppDelegate.m
//  Quartz Experiments
//
//  Created by George Brown on 06.03.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import "SCAppDelegate.h"
#import <IOSurface/IOSurface.h>
#import <dispatch/dispatch.h>


@implementation SCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //displayQueue = dispatch_queue_create("info.qcexperiments.displayQueue", DISPATCH_QUEUE_SERIAL);
    
    mainQCView = [_theObjectController content];
};

- (void) openPanelDidEnd: (NSOpenPanel *)panel
              returnCode: (int)returnCode
             contextInfo: (void *)contextInfo
{
    if (returnCode == NSOKButton) {
        [self doLoadXML: [[panel URLs] objectAtIndex:0]];
    }
}

- (IBAction)openFile:(id)sender {
    NSArray *fileTypes = [NSArray arrayWithObject:@"plist"];
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:fileTypes];
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self doLoadXML : [openPanel URL]];
        }
    }];
};

- (void) doLoadXML: (NSURL *)xmlFileURL {
    NSDictionary *structures = [NSDictionary dictionaryWithContentsOfURL:xmlFileURL];
    NSString *urlPath = [xmlFileURL absoluteString];
    //[_theObjectController setValue:structures forKeyPath:@"selection.patch.Structure.value"];
    //[_theObjectController setValue:urlPath forKeyPath:@"selection.patch.String.value"];
}

@end
