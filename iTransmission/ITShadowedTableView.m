//
//  ShadowedTableView.m
//  ShadowedTableView
//
//  Created by Matt Gallagher on 2009/08/21.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import "ITShadowedTableView.h"
#import "ITShadowView.h"

#define SHADOW_HEIGHT 10.0
#define SHADOW_INVERSE_HEIGHT 8.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)

@implementation ITShadowedTableView
@synthesize topShadow = _topShadow;
@synthesize bottomShadow = _bottomShadow;
@synthesize originShadow = _originShadow;

//
// shadowAsInverse:
//
// Create a shadow layer
//
// Parameters:
//    inverse - if YES then shadow fades upwards, otherwise shadow fades downwards
//
// returns the constructed shadow layer
//
- (CAGradientLayer *)shadowAsInverse:(BOOL)inverse
{
	CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
	CGRect newShadowFrame =
		CGRectMake(0, 0, self.frame.size.width,
			inverse ? SHADOW_INVERSE_HEIGHT : SHADOW_HEIGHT);
	newShadow.frame = newShadowFrame;
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;   
    CGColorRef lightColor = [UIColor clearColor].CGColor;   
	newShadow.colors =
		[NSArray arrayWithObjects:
			(__bridge_transfer id)(inverse ? lightColor : darkColor),
			(__bridge_transfer id)(inverse ? darkColor : lightColor),
		nil];
	return newShadow;
}

//
// layoutSubviews
//
// Override to layout the shadows when cells are laid out.
//
- (void)layoutSubviews
{
	[super layoutSubviews];
	
    if (self.backgroundColor == nil) return;
    
	//
	// Construct the origin shadow if needed
	//
	if (!self.originShadow)
	{
		self.originShadow = [[ITShadowView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 8.0f)];
        [self.originShadow setShadowDirection:ITShadowTopToBottom];
        [self.originShadow setShadowOpacity:0.5f];
        [self insertSubview:self.originShadow atIndex:0];
	}
//	else if (![[self.layer.sublayers objectAtIndex:0] isEqual:originShadow])
//	{
//		[self.layer insertSublayer:originShadow atIndex:0];
//	}
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	//
	// Stretch and place the origin shadow
	//
	CGRect originShadowFrame = self.originShadow.frame;
	originShadowFrame.size.width = self.frame.size.width;
	originShadowFrame.origin.y = self.contentOffset.y;
	self.originShadow.frame = originShadowFrame;
	
	[CATransaction commit];
    
    NSArray *indexPathsForVisibleRows = [self indexPathsForVisibleRows];
	if ([indexPathsForVisibleRows count] == 0)
	{
		[self.topShadow removeFromSuperlayer];
		[self.bottomShadow removeFromSuperlayer];
		return;
	}
	
	NSIndexPath *firstRow = [indexPathsForVisibleRows objectAtIndex:0];
	if ([firstRow section] == 0 && [firstRow row] == 0)
	{
		UIView *cell = [self cellForRowAtIndexPath:firstRow];
		if (!self.topShadow)
		{
			self.topShadow = [self shadowAsInverse:YES];
			[cell.layer insertSublayer:self.topShadow atIndex:0];
		}
		else if ([cell.layer.sublayers indexOfObjectIdenticalTo:self.topShadow] != 0)
		{
			[cell.layer insertSublayer:self.topShadow atIndex:0];
		}
        
		CGRect shadowFrame = self.topShadow.frame;
		shadowFrame.size.width = cell.frame.size.width;
		shadowFrame.origin.y = -SHADOW_INVERSE_HEIGHT;
		self.topShadow.frame = shadowFrame;
	}
	else
	{
		[self.topShadow removeFromSuperlayer];
	}
    
	NSIndexPath *lastRow = [indexPathsForVisibleRows lastObject];
	if ([lastRow section] == [self numberOfSections] - 1 &&
		[lastRow row] == [self numberOfRowsInSection:[lastRow section]] - 1)
	{
		UIView *cell =
        [self cellForRowAtIndexPath:lastRow];
		if (!self.bottomShadow)
		{
			self.bottomShadow = [self shadowAsInverse:NO];
			[cell.layer insertSublayer:self.bottomShadow atIndex:0];
		}
		else if ([cell.layer.sublayers indexOfObjectIdenticalTo:self.bottomShadow] != 0)
		{
			[cell.layer insertSublayer:self.bottomShadow atIndex:0];
		}
        
		CGRect shadowFrame = self.bottomShadow.frame;
		shadowFrame.size.width = cell.frame.size.width;
		shadowFrame.origin.y = cell.frame.size.height;
		self.bottomShadow.frame = shadowFrame;
	}
	else
	{
		[self.bottomShadow removeFromSuperlayer];
	}
}

- (void)dealloc
{
}


@end
