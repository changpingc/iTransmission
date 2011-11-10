//
//  ITTorrentGroup.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITTorrentGroup : NSObject

@property (nonatomic, assign, getter = groupIndex) NSInteger group;
@property (strong, nonatomic) NSMutableArray *torrents;

- (id) initWithGroup: (NSInteger) group;
- (CGFloat) ratio;
- (CGFloat) uploadRate;
- (CGFloat) downloadRate;

@end
