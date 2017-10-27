//
//  MDSpreadViewCellMap.h
//  company-ess-ios
//
//  Created by worksap on 10/12/16.
//  Copyright © 2016 worksap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSpreadViewCell.h"
//#import "MDIndexPath.h"
@interface MDSpreadViewCellMap : NSObject {
@private
    NSMutableArray *columns;
}

@property (nonatomic, readonly) NSUInteger rowCount;
@property (nonatomic, readonly) NSUInteger columnCount;
@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) NSInteger columnIndex;
@property (nonatomic, readonly, getter = hasContent) BOOL content;

- (BOOL)getIndicesForCell:(MDSpreadViewCell *)cell row:(NSUInteger *)row column:(NSUInteger *)column;

- (NSArray *)rowAtIndex:(NSUInteger)index;
- (NSArray *)columnAtIndex:(NSUInteger)index;
@property (nonatomic, readonly) NSArray *allColumns;
@property (nonatomic, readonly) NSArray *allRows;
@property (nonatomic, readonly) NSArray *allCells; // No NSNulls in here

- (void)insertRowsBefore:(NSArray *)rows indexBegin:(NSInteger)indexBegin; // array of arrays
- (void)insertRowsBefore:(NSArray *)rows;
- (void)insertRowsAfter:(NSArray *)rows;
- (void)insertRowsAfter:(NSArray *)rows indexBegin:(NSInteger)indexBegin;
- (void)insertColumnsBefore:(NSArray *)columns;
- (void)insertColumnsAfter:(NSArray *)columns;

- (NSArray *)removeCellsBeforeRow:(NSUInteger)newFirstRow column:(NSUInteger)newFirstColumn;
- (NSArray *)removeCellsUntilRow:(int)untilRow column:(NSUInteger)newFirstColumn;
- (NSArray *)removeCellsAfterRow:(NSUInteger)newLastRow column:(NSUInteger)newLastColumn;
- (NSArray *)removeAllCells;

@end

