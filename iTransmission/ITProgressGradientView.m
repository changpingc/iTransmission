//
//  ITProgressGradientView.m
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITProgressGradientView.h"

@implementation ITProgressGradientView
@synthesize gradient = _gradient;
@synthesize gradientImage = _gradientImage;
@synthesize gradientImageView = _gradientImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.gradientImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.gradientImageView];
    }
    return self;
}

- (CGGradientRef)createGradientWithBaseColor:(UIColor*)color
{
    CGGradientRef myGradient;
    CGColorSpaceRef myColorSpace;
    size_t locationCount = 4;
    CGFloat locationList[] = {0.0, 0.5, 0.5, 1.0};
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGFloat colorList[] = {
        red, green, blue, alpha,
        red * 0.95, green * 0.95, blue * 0.95, alpha,
        red * 0.85, green * 0.85, blue * 0.85, alpha,
        red, green, blue, alpha,
    };
    myColorSpace = CGColorSpaceCreateDeviceRGB();
    // CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList,              locationList, locationCount);
    CGColorSpaceRelease(myColorSpace);
    return myGradient;
}

- (void)setGradient:(CGGradientRef)gradient
{
    _gradient = gradient;
    [self updateGradientImage];
}

- (void)setGradientImage:(UIImage *)gradientImage
{
    _gradientImage = gradientImage;
    [self.gradientImageView setImage:gradientImage];
}

- (CGContextRef)createBitmapContextForSize:(CGSize)size
{
    int pixelsWide = size.width;
    int pixelsHigh = size.height;
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4); //4
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    context = CGBitmapContextCreate ( NULL, // instead of bitmapData
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease( colorSpace );
    
    if (context== NULL)
    {
        return NULL;
    }
    
    return context;
}

- (void)updateGradientImage
{
    self.gradientImage = nil;
    
    CGContextRef context = [self createBitmapContextForSize:CGSizeMake(1.0f, self.bounds.size.height)];
    CGPoint startPoint, endPoint;
    startPoint.x = 0;
    startPoint.y = 0;
    endPoint.x = 1;
    endPoint.y = self.bounds.size.height;
    
    CGContextDrawLinearGradient(context, self.gradient, startPoint, endPoint, 0);
    
	// make image out of bitmap context
	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	UIImage *retImage = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
    
	CGContextRelease(context);
    
    self.gradientImage = retImage;
}

- (void)setBaseColor:(UIColor *)color
{
    if (self.gradient) { 
        CGGradientRelease(self.gradient);
        self.gradient = nil;
    }
    self.gradient = [self createGradientWithBaseColor:color];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.gradientImageView.frame = self.bounds;
    [self updateGradientImage];
}

- (void)dealloc
{
    if (self.gradient) { 
        CGGradientRelease(self.gradient);
        self.gradient = nil;
    }
}

@end
