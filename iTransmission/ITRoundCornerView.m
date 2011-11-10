//
//  ITRoundCornerView.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITRoundCornerView.h"
#import <QuartzCore/QuartzCore.h>

static inline UIImage* MTDContextCreateRoundedMask( CGRect rect, CGFloat radius_tl, CGFloat radius_tr, CGFloat radius_bl, CGFloat radius_br ) {  
    
    CGContextRef context;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a bitmap graphics context the size of the image
    context = CGBitmapContextCreate( NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast );
    
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);    
    
    if ( context == NULL ) {
        return NULL;
    }
    
    // cerate mask
    
    CGFloat minx = CGRectGetMinX( rect ), midx = CGRectGetMidX( rect ), maxx = CGRectGetMaxX( rect );
    CGFloat miny = CGRectGetMinY( rect ), midy = CGRectGetMidY( rect ), maxy = CGRectGetMaxY( rect );
    
    CGContextBeginPath( context );
    CGContextSetGrayFillColor( context, 1.0, 0.0 );
    CGContextAddRect( context, rect );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    CGContextSetGrayFillColor( context, 1.0, 1.0 );
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, minx, midy );
    CGContextAddArcToPoint( context, minx, miny, midx, miny, radius_bl );
    CGContextAddArcToPoint( context, maxx, miny, maxx, midy, radius_br );
    CGContextAddArcToPoint( context, maxx, maxy, midx, maxy, radius_tr );
    CGContextAddArcToPoint( context, minx, maxy, minx, midy, radius_tl );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef bitmapContext = CGBitmapContextCreateImage( context );
    CGContextRelease( context );
    
    // convert the finished resized image to a UIImage 
    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext];
    // image is retained by the property setting above, so we can 
    // release the original
    CGImageRelease(bitmapContext);
    
    // return the image
    return theImage;
}  


@implementation ITRoundCornerView

+ (Class)layerClass
{
    return [CALayer class];
}

- (void)awakeFromNib
{
    UIImage *mask = MTDContextCreateRoundedMask(self.bounds, 0.0f, 0.0f, 5.0f, 5.0f);
    CALayer *layerMask = [CALayer layer];
    layerMask.frame = self.bounds;       
    layerMask.contents = (id)mask.CGImage;       
    self.layer.mask = layerMask;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.layer.mask.frame = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
