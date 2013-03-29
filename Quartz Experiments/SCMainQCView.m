//
//  SCMainQCView.m
//  Quartz Experiments
//
//  Created by George Brown on 17.03.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import "SCMainQCView.h"

@implementation SCMainQCView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"Starting qcview I think");

        // Initialization code here.
   }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void) handleNewFrame: (IOSurfaceRef)surface {
    // Now what?
    // CFRetain(surface);
    if (updatedFrame) {
        CFRelease(updatedFrame);

    }
    //NSLog(@"Setting new frame");
    updatedFrame = surface;
    CFRetain(updatedFrame);
//    if (!myPixelBuffer) {
//        CVPixelBufferCreateWithIOSurface(NULL, updatedFrame, NULL, &(myPixelBuffer));
//        CVBufferRetain(myPixelBuffer);
//    }
//    else {
//        CVBufferRelease(myPixelBuffer);
//        CVPixelBufferCreateWithIOSurface(NULL, updatedFrame, NULL, &(myPixelBuffer));
//    }
//    [self setValue:CFBridgingRelease(myPixelBuffer) forInputKey:@"Image"];

}

-(BOOL) renderAtTime:(NSTimeInterval)time arguments:(NSDictionary *)arguments {
        // Grab our surface and incrment it for the duration of the render
    BOOL success = false;
    //if (!myCIContext) {
    //    [self setupMyContext];
    //}

    if (updatedFrame) {
        CVPixelBufferCreateWithIOSurface(NULL, updatedFrame, NULL, &(myPixelBuffer));
        CVPixelBufferRetain(myPixelBuffer);

        [self setValue:CFBridgingRelease(myPixelBuffer) forInputKey:@"Image"];

    }
    //NSLog(@"Called render at time");

    success = [super renderAtTime:time arguments:arguments];
    
    if (updatedFrame) {
        CVPixelBufferRelease(myPixelBuffer);
    }
    return success;
}

- (void) setupMyContext {
    NSOpenGLContext *oglContext = [self openGLContext];
    CGLContextObj oglContextObj = [oglContext CGLContextObj];
    CGLPixelFormatObj oglPixelFormat = CGLGetPixelFormat(oglContextObj);
    myCIContext = [CIContext contextWithCGLContext:oglContextObj pixelFormat:oglPixelFormat colorSpace:NULL options:NULL];
}


@end
