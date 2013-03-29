//
//  SCAppDelegate.h
//  Quartz Experiments
//
//  Created by George Brown on 06.03.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <IOSurface/IOSurface.h>
#import "SCMainQCView.h"

@interface SCAppDelegate : NSObject <NSApplicationDelegate> {
    CGDisplayStreamRef displayStream;
    dispatch_queue_t    displayQueue;
    IOSurfaceRef        updatedFrame;
    CIImage             *screenImage;
    CIContext              *aContext;
    SCMainQCView         *mainQCView;
}
@property (weak) IBOutlet NSMenuItem *FullScreenMenuItem;
@property (weak) IBOutlet NSObjectController *theObjectController;

@property (assign) IBOutlet NSWindow *window;
- (IBAction)openFile:(id)sender;

@end
