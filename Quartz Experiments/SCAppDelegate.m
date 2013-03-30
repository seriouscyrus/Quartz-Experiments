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
    CGDirectDisplayID displayId = CGMainDisplayID();

    BOOL          streamStarted = [self startDisplayStream:displayId];
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
    [_theObjectController setValue:structures forKeyPath:@"selection.patch.Structure.value"];
    [_theObjectController setValue:urlPath forKeyPath:@"selection.patch.String.value"];
}

-(BOOL) startDisplayStream: (CGDirectDisplayID)displayId {
    CGDisplayModeRef       mode = CGDisplayCopyDisplayMode(displayId);
    size_t               pWidth = CGDisplayModeGetPixelWidth(mode);
    size_t              pHeight = CGDisplayModeGetPixelHeight(mode);
    
    CGDisplayModeRelease(mode);
    //displayQueue = dispatch_queue_create("scqcexp.mainqcview.displayQueue", DISPATCH_QUEUE_SERIAL);
    displayQueue = dispatch_get_main_queue();
    //displayQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    if (!displayQueue) {
        NSLog(@"No display queue");
    }
    displayStream = CGDisplayStreamCreateWithDispatchQueue(displayId,
                                                           pWidth,
                                                           pHeight,
                                                           'BGRA',
                                                           nil,
                                                           displayQueue,
                                                           ^(CGDisplayStreamFrameStatus status, uint64_t displayTime, IOSurfaceRef frameSurface, CGDisplayStreamUpdateRef updateRef)
                                                           {
                                                               if(status == kCGDisplayStreamFrameStatusFrameComplete && frameSurface)
                                                               {
                                                                   // As per CGDisplayStreams header
                                                                   // As we're copying directly in the handler, we don't need this
                                                                   //IOSurfaceIncrementUseCount(frameSurface);
                                                                   // -emitNewFrame: retains the frame
                                                                   //CIImage *newFrame = [CIImage imageWithIOSurface:frameSurface];
                                                                   //screenImage = newFrame;
                                                                   //NSInteger isurfaceID = IOSurfaceGetID(frameSurface);
                                                                   //NSNumber *surfaceID = [NSNumber numberWithInteger:isurfaceID];
                                                                   NSLog(@"Emitting frame");
                                                                   //[_theObjectController setValue:surfaceID forKeyPath:@"selection.patch.SurfaceID.value"];
                                                                   //CVPixelBufferCreateWithIOSurface(NULL, frameSurface, NULL, &(myPixelBuffer));
                                                                   //[_theObjectController setValue:CFBridgingRelease(myPixelBuffer) forKeyPath:@"selection.patch.SurfaceID.value"];
                                                                   [self handleNewFrame:frameSurface];
                                                               }
                                                           });
    
    CGDisplayStreamStart(displayStream);
    if (displayStream) {
        NSLog(@"Display stream started");
        return TRUE;
    }
    return FALSE;
}

-(void) handleNewFrame: (IOSurfaceRef)surface {
    // Now what?
    //CFRetain(surface);
    //CIImage *newFrame = [CIImage imageWithIOSurface:surface];
    CVPixelBufferCreateWithIOSurface(NULL, surface, NULL, &(myPixelBuffer));
    //[mainQCView handleNewFrame:surface];
    [mainQCView handleNewFrame:myPixelBuffer];
    //IOSurfaceDecrementUseCount(surface);
}


@end
