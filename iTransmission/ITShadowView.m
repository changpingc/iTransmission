//
//  ITShadowView.m
//  iTransmission
//
//  Created by Mike Chen on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITShadowView.h"

@implementation ITShadowView
@synthesize shadowDirection = _shadowDirection;
@synthesize shadowImage = _shadowImage;

+ (id)shadowImageWithDirection:(ITShadowDirection)direction andHeight:(CGFloat)height
{
    static const CGFloat topToBottomColorList[] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f};
    static const CGFloat bottomToTopColorList[] = {0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f};
    static const CGFloat locationList[] = {0.0f, 1.0f};
    static const size_t locationCount = 2;

    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    CGFloat const *colorList;
    
    if (direction == ITShadowBottomToTop) 
        colorList = bottomToTopColorList;
    if (direction == ITShadowTopToBottom)
        colorList = topToBottomColorList;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorSpace, colorList, locationList, locationCount);

    int pixelsWide = 1;
    int pixelsHigh = height;
    CGContextRef context = NULL;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    bitmapBytesPerRow = (pixelsWide * 4); //4
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    
    context = CGBitmapContextCreate ( NULL, // instead of bitmapData
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);

    CGColorSpaceRelease(colorSpace);

    if (context== NULL)
    {
        return NULL;
    }
    
    CGPoint startPoint, endPoint;
    startPoint.x = 0;
    startPoint.y = 0;
    endPoint.x = 1;
    endPoint.y = height;
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
	// make image out of bitmap context
	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGContextRelease(context);
    CGGradientRelease(gradient);
    
    return image;
}

- (void)update
{
    self.shadowImage = [[self class] shadowImageWithDirection:self.shadowDirection andHeight:self.frame.size.height];
    [self setImage:self.shadowImage];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setShadowDirection:(ITShadowDirection)shadowDirection
{
    BOOL needsUpdate = NO;
    if (self.shadowDirection != shadowDirection) 
        needsUpdate = YES;
    _shadowDirection = shadowDirection;
    if (needsUpdate)
        [self update];
}

- (void)setFrame:(CGRect)frame
{
    BOOL needsUpdate = NO;
    if (self.frame.size.height != frame.size.height) {
        needsUpdate = YES; 
    }
    [super setFrame:frame];
    if (needsUpdate) 
        [self update];
}

- (void)setShadowOpacity:(CGFloat)opacity
{
    [self setAlpha:opacity];
}

@end
