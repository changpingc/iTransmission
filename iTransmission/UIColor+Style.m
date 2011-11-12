//
//  UIColor+Style.m
//  iTransmission
//
//  Created by Mike Chen on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Style.h"

@implementation UIColor (Style)

+ (UIColor*)barBlueColor
{
    return [UIColor colorWithRed:0.18f green:0.30f blue:0.62f alpha:1.0f];
}

+ (UIColor*)controlBlueColor
{
    return [UIColor colorWithRed:0.09f green:0.32f blue:0.66f alpha:1.0f];
}

+ (UIColor*)controlGreenColor
{
    return [UIColor colorWithRed: 0.44 green: 0.89 blue: 0.40 alpha:1.0f];
}

+ (UIColor*)controlRedColor
{
    return [UIColor colorWithRed:0.902 green: 0.439 blue: 0.451 alpha:1.0f];
}

+ (UIColor*)controlYellowColor
{
    return [UIColor colorWithRed: 0.933 green: 0.890 blue: 0.243 alpha:1.0f];
}

+ (UIColor*)controlGreyColor
{
    return [UIColor colorWithWhite:0.2f alpha:1.0f];
}

@end
