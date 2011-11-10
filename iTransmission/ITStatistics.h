//
//  ITStatistics.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITStatistics : NSObject

@property (assign, nonatomic) CGFloat uploadRate;
@property (assign, nonatomic) CGFloat downloadRate;
@property (assign, nonatomic, getter = isCompleted) BOOL completed;
@property (assign, nonatomic) CGFloat sessionRatio;
@property (assign, nonatomic) CGFloat cumulativeRatio;
@property (assign, nonatomic) NSUInteger sessionUpload;
@property (assign, nonatomic) NSUInteger sessionDownload;
@property (assign, nonatomic) NSUInteger cumulativeUpload;
@property (assign, nonatomic) NSUInteger cumulativeDownload;
@end
