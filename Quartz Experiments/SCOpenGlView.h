//
//  SCOpenGlView.h
//  Quartz Experiments
//
//  Created by George Brown on 29.03.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <IOSurface/IOSurface.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGL/OpenGL.h>


@interface SCOpenGlView : NSOpenGLView {
    CVDisplayLinkRef    displayLink;
    CVPixelBufferRef    pbCurrentFrame;
    IOSurfaceRef        ioCurrentFrame;
    QCRenderer          *qcRenderer;
    CGDirectDisplayID   currentDisplay;
    NSString            *compPath;
    CGDisplayStreamRef  displayStream;
    dispatch_queue_t    displayQueue;

}

- (void) handleNewFrame:(IOSurfaceRef) updatedSurface;

@end
