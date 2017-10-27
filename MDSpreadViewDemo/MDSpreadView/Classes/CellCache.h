//
//  CellCache.h
//  company-ess-ios
//
//  Created by worksap on 10/27/16.
//  Copyright © 2016 worksap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSpreadViewCell.h"
@interface CellCache : NSObject {
    NSMutableDictionary *dict;
}


-(void)putCell:(MDSpreadViewCell *)cell row:(int)row column:(int)column;
-(MDSpreadViewCell *)getCell:(int)row column:(int)column;
-(void)clearAll;
@end

