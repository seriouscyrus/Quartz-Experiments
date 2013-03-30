//
//  SCMainQCView.h
//  Quartz Experiments
//
//  Created by George Brown on 17.03.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <IOSurface/IOSurface.h>
#import <Cocoa/Cocoa.h>
#import <dispatch/dispatch.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGL/OpenGL.h>

@interface SCMainQCView : QCView {
    IOSurfaceRef        updatedFrame;
    CIImage            *currentImage;
    CIContext           *myCIContext;
    CVPixelBufferRef   myPixelBuffer;
}

-(BOOL) renderAtTime:(NSTimeInterval)time arguments:(NSDictionary *)arguments;

//-(void) handleNewFrame: (IOSurfaceRef) newFrame;
-(void) handleNewFrame: (CVPixelBufferRef) newFrame;
@end
