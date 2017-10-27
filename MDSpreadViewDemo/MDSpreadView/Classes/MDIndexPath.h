//
//  MDIndexPath.h
//  company-ess-ios
//
//  Created by worksap on 10/12/16.
//  Copyright © 2016 worksap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDIndexPath : NSObject {
    NSInteger section;
    NSInteger row;
}

+ (MDIndexPath *)indexPathForColumn:(NSInteger)column inSection:(NSInteger)section;
+ (MDIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@property (nonatomic,readonly) NSInteger section;
@property (nonatomic,readonly) NSInteger row;
@property (nonatomic,readonly) NSInteger column;

- (BOOL)isEqualToIndexPath:(MDIndexPath *)object;

@end

