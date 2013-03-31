//
//  SCOpenGlView.m
//  Quartz Experiments
//
//  Created by George Brown on 29.03.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import "SCOpenGlView.h"

@implementation SCOpenGlView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"I'm called");
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"Ami I called?");
    // Drawing code here.
}

- (CVReturn) getFrameForTime:(const CVTimeStamp *)outputTime {
    BOOL success;
    NSTimeInterval videoTime;
    videoTime = (NSTimeInterval)outputTime->videoTime;
    if (qcRenderer) {
        //CIImage *frameImage = [[CIImage alloc] initWithIOSurface:ioCurrentFrame];
        //[qcRenderer setValue:frameImage forInputKey:@"Image"];
        if (ioCurrentFrame) {
            //CFRetain(ioCurrentFrame);
            //IOSurfaceIncrementUseCount(ioCurrentFrame);
            CVPixelBufferCreateWithIOSurface(NULL, ioCurrentFrame, NULL, &(pbCurrentFrame));
            CVPixelBufferRetain(pbCurrentFrame);
            [qcRenderer setValue:CFBridgingRelease(pbCurrentFrame) forInputKey:@"Image"];
            //CVPixelBufferRelease(pbCurrentFrame);

        }
        success = [qcRenderer renderAtTime:videoTime arguments:NULL];
        if (success) {
            [[self openGLContext] flushBuffer];
        }
        if (pbCurrentFrame) {
            //IOSurfaceDecrementUseCount(ioCurrentFrame);
            CVPixelBufferRelease(pbCurrentFrame);
            //CFRelease(ioCurrentFrame);
        }
        //NSLog(@"Render success = %d", success);
        //NSLog(@"Time = %d", outputTime);
        //NSLog(@"pixel buffer = %d", pbCurrentFrame);
    }
    return kCVReturnSuccess;
}


- (void)awakeFromNib {
    CVReturn error;
    NSLog(@"Awaking from NIB");

    NSOpenGLContext *myContext = [self openGLContext];
    NSOpenGLPixelFormat *myPixelFormat = [self pixelFormat];
    
    // Setup the displaylink
    currentDisplay = [myContext currentVirtualScreen];
    error = CVDisplayLinkCreateWithActiveCGDisplays(&(displayLink));
    if (error ) {
        NSLog(@"Display Link failed with error %d", error);
        displayLink = nil;
    }
    error = CVDisplayLinkSetCurrentCGDisplay(displayLink, currentDisplay);
    if (error) {
        NSLog(@"Display link get screen failed with error %d", error);
    }
    error = CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));
    if (error) {
        NSLog(@"Displaylink set output callback failed with error : %d", error);
    }
    CVDisplayLinkStart(displayLink);
    
    // Load the composition
    compPath = [[NSBundle mainBundle] pathForResource:@"Quartz Experiments" ofType:@".qtz"];
    qcRenderer = [[QCRenderer alloc] initWithOpenGLContext:myContext pixelFormat:myPixelFormat file:compPath];
    
    // Start the display stream
    CGDirectDisplayID displayId = CGMainDisplayID();
    [self startDisplayStream:displayId];

}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    @autoreleasepool {
        CVReturn result = [(__bridge SCOpenGlView*)displayLinkContext getFrameForTime:outputTime];
        return result;
    }

}

- (void) update {
    [super update];
    CGDirectDisplayID newDisplay = [[self openGLContext] currentVirtualScreen];
    if (newDisplay != currentDisplay) {
        NSOpenGLContext *myContext = [self openGLContext];
        NSOpenGLPixelFormat *myPixelFormat = [self pixelFormat];
        CVReturn error;
        currentDisplay = newDisplay;
        error = CVDisplayLinkSetCurrentCGDisplay(displayLink, currentDisplay);
        if (error) {
            NSLog(@"Display link switch dfailed with error: %d", error);
        }
        qcRenderer = nil;
        qcRenderer = [[QCRenderer alloc] initWithOpenGLContext:myContext pixelFormat:myPixelFormat file:compPath];        
    }
}

- (void) dealloc {
    CVDisplayLinkStop(displayLink);
}

- (void) handleNewFrame:(IOSurfaceRef)updatedSurface {
    // Now what?
    if (ioCurrentFrame) {
        CFRelease(ioCurrentFrame);
    }
    if (pbCurrentFrame) {
        //CVPixelBufferRelease(pbCurrentFrame);
    }
    //NSLog(@"Setting new frame");
    //CVPixelBufferCreateWithIOSurface(NULL, updatedSurface, NULL, &(pbCurrentFrame));
    //CVPixelBufferRetain(pbCurrentFrame);
    ioCurrentFrame = updatedSurface;
    CFRetain(ioCurrentFrame);
    //CVPixelBufferCreateWithIOSurface(NULL, updatedSurface, NULL, &(pbCurrentFrame));
    //CVPixelBufferRetain(pbCurrentFrame);
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
                                                                   //NSLog(@"Emitting frame");
                                                                   //[_theObjectController setValue:surfaceID forKeyPath:@"selection.patch.SurfaceID.value"];
                                                                   //CVPixelBufferCreateWithIOSurface(NULL, frameSurface, NULL, &(pbCurrentFrame));
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


@end
