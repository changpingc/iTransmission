//
//  ITStatistics.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITStatistics.h"

@implementation ITStatistics
@synthesize uploadRate = _uploadRate;
@synthesize downloadRate = _downloadRate;
@synthesize completed = _completed;
@synthesize sessionUpload = _sessionUpload;
@synthesize sessionDownload = _sessionDownload;
@synthesize sessionRatio = _sessionRatio;
@synthesize cumulativeRatio = _cumulativeRatio;
@synthesize cumulativeUpload = _cumulativeUpload;
@synthesize cumulativeDownload = _cumulativeDownload;

@end
