//
//  ITFileListNode.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITTorrent;

@interface ITFileListNode : NSObject <NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSMutableIndexSet *indexes;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) ITTorrent *torrent;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) BOOL isFolder;
@property (nonatomic, strong) NSMutableArray* children;

- (id) initWithFolderName: (NSString *) name path: (NSString *) path torrent: (ITTorrent *) torrent;
- (id) initWithFileName: (NSString *) name path: (NSString *) path size: (uint64_t) size index: (NSUInteger) index torrent: (ITTorrent *) torrent;

- (void) insertChild: (ITFileListNode *) child;
- (void) insertIndex: (NSUInteger) index withSize: (uint64_t) size;

- (NSString *) description;

- (NSMutableArray *) children;

@end