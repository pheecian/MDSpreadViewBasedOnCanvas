//
//  MDSpreadViewCellMap.m
//  company-ess-ios
//
//  Created by worksap on 10/12/16.
//  Copyright © 2016 worksap. All rights reserved.
//

#import "MDSpreadViewCellMap.h"

@implementation MDSpreadViewCellMap

- (instancetype)init
{
    if (self = [super init]) {
        columns = [[NSMutableArray alloc] init];
        _rowIndex = -1;
    }
    return self;
}

- (BOOL)getIndicesForCell:(MDSpreadViewCell *)aCell row:(NSUInteger *)rowIndex column:(NSUInteger *)columnIndex
{
    *columnIndex = 0;
    for (NSMutableArray *column in columns) {
        *rowIndex = [column indexOfObjectIdenticalTo:aCell];
        if (*rowIndex != NSNotFound) {
            return YES;
        }
        (*columnIndex)++; // http://stackoverflow.com/a/3655755/1565236
    }
    *rowIndex = NSNotFound;
    *columnIndex = NSNotFound;
    return NO;
}

- (NSArray *)rowAtIndex:(NSUInteger)rowIndex//currently not used
{
    NSMutableArray *newRow = [[NSMutableArray alloc] initWithCapacity:self.rowCount];
    
    NSAssert((rowIndex < _rowCount), @"row index %lu beyond bounds of cell map [0, %lu]", (unsigned long)rowIndex, (unsigned long)_rowCount);
    
    for (NSMutableArray *column in columns) {
        [newRow addObject:[column objectAtIndex:rowIndex]];
    }
    
    return newRow;
}

- (NSArray *)columnAtIndex:(NSUInteger)columnIndex//currently not used
{
    NSAssert((columnIndex < _columnCount), @"column index %lu beyond bounds of cell map [0, %lu]", (unsigned long)columnIndex, (unsigned long)_columnCount);
    
    return [[columns objectAtIndex:columnIndex] copy];
}

- (NSArray *)allColumns
{
    return [columns copy];
}

- (NSArray *)allRows
{
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < _rowCount; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        for (NSUInteger j = 0; j < _columnCount; j++) {
            [row addObject:[[columns objectAtIndex:j] objectAtIndex:i]];
        }
        [rows addObject:row];
    }
    
    return rows;
}

- (NSArray *)allCells
{
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    
    for (NSArray *column in columns) {
        for (id cell in column) {
            if (cell != [NSNull null]) {
                [cells addObject:cell];
            }
        }
    }
    
    return cells;
}

- (BOOL)hasContent
{
    return (_rowCount > 0);
}

- (void)insertRowsBefore:(NSArray *)cellRows indexBegin:(NSInteger)indexBegin
{
    if(indexBegin == -1){
        return;
    }
    if (_columnCount == 0) {
        _columnCount = [[cellRows firstObject] count];
        
        for (NSUInteger i = 0; i < _columnCount; i++) {
            [columns addObject:[[NSMutableArray alloc] init]];
        }
    }
    
    NSUInteger numberOfNewRows = cellRows.count;
    NSUInteger columnIndex = 0;
    for (NSMutableArray *column in columns) {
        NSUInteger rowIndex = 0;
        for (NSArray *newRow in cellRows) {
            NSAssert(newRow.count == _columnCount, @"added row with %lu columns not %lu as in cell map", (unsigned long)newRow.count, (unsigned long)_columnCount);
            [column insertObject:[newRow objectAtIndex:columnIndex] atIndex:rowIndex];
            rowIndex++;
        }
        columnIndex++;
    }
    _rowCount += numberOfNewRows;
    _rowIndex  = indexBegin;
}

- (void)insertRowsBefore:(NSArray *)cellRows
{
    if (_columnCount == 0) {
        _columnCount = [[cellRows firstObject] count];
        
        for (NSUInteger i = 0; i < _columnCount; i++) {
            [columns addObject:[[NSMutableArray alloc] init]];
        }
    }
    
    NSUInteger numberOfNewRows = cellRows.count;
    NSUInteger columnIndex = 0;
    for (NSMutableArray *column in columns) {
        NSUInteger rowIndex = 0;
        for (NSArray *newRow in cellRows) {
            NSAssert(newRow.count == _columnCount, @"added row with %lu columns not %lu as in cell map", (unsigned long)newRow.count, (unsigned long)_columnCount);
            [column insertObject:[newRow objectAtIndex:columnIndex] atIndex:rowIndex];
            rowIndex++;
        }
        columnIndex++;
    }
    _rowCount += numberOfNewRows;
    
}


- (void)insertRowsAfter:(NSArray *)cellRows
{
    if (_columnCount == 0) {
        _columnCount = [[cellRows firstObject] count];
        
        for (NSUInteger i = 0; i < _columnCount; i++) {
            [columns addObject:[[NSMutableArray alloc] init]];
        }
    }
    
    NSUInteger numberOfNewRows = cellRows.count;
    NSUInteger columnIndex = 0;
    for (NSMutableArray *column in columns) {
        for (NSArray *newRow in cellRows) {
            NSAssert(newRow.count == _columnCount, @"added row with %lu columns not %lu as in cell map", (unsigned long)newRow.count, (unsigned long)_columnCount);
            [column addObject:[newRow objectAtIndex:columnIndex]];
        }
        columnIndex++;
    }
    _rowCount += numberOfNewRows;
}

- (void)insertRowsAfter:(NSArray *)cellRows indexBegin:(NSInteger)indexBegin
{
    if(_rowCount == 0) {
        _rowIndex = indexBegin;
    }
    if (_columnCount == 0) {
        _columnCount = [[cellRows firstObject] count];
        
        for (NSUInteger i = 0; i < _columnCount; i++) {
            [columns addObject:[[NSMutableArray alloc] init]];
        }
    }
    
    NSUInteger numberOfNewRows = cellRows.count;
    NSUInteger columnIndex = 0;
    for (NSMutableArray *column in columns) {
        for (NSArray *newRow in cellRows) {
            NSAssert(newRow.count == _columnCount, @"added row with %lu columns not %lu as in cell map", (unsigned long)newRow.count, (unsigned long)_columnCount);
            [column addObject:[newRow objectAtIndex:columnIndex]];
        }
        columnIndex++;
    }
    _rowCount += numberOfNewRows;
}

- (void)insertColumnsBefore:(NSArray *)cellColumns
{
    if (_rowCount == 0) {
        _rowCount = [[cellColumns firstObject] count];
        MDSpreadViewCell * cell = [[cellColumns firstObject] firstObject];
        _rowIndex = (int)cell._rowPath;
        
    }
    NSUInteger numberOfNewColumns = cellColumns.count;
    NSUInteger columnIndex = 0;
    for (NSArray *newColumn in cellColumns) {
        NSAssert(newColumn.count == _rowCount, @"added column with %lu rows not %lu as in cell map", (unsigned long)newColumn.count, (unsigned long)_rowCount);
        [columns insertObject:[newColumn mutableCopy] atIndex:columnIndex];
        columnIndex++;
    }
    _columnCount += numberOfNewColumns;
}

- (void)insertColumnsAfter:(NSArray *)cellColumns
{
    if(cellColumns.count == 0){
        return;
    }
    if (_rowCount == 0) {
        _rowCount = [[cellColumns firstObject] count];
        for(NSArray * newColumn in cellColumns){
            int delta = 0;
            for (MDSpreadViewCell *cell in newColumn){
                if((NSNull *)cell == [NSNull null]){
                    delta++;
                }
                else {
                    _rowIndex = (int)cell._rowPath - delta;
                    break;
                }
            }
        }
    }
    NSUInteger numberOfNewColumns = cellColumns.count;
    for (NSArray *newColumn in cellColumns) {
        NSAssert(newColumn.count == _rowCount, @"added column with %lu rows not %lu as in cell map", (unsigned long)newColumn.count, (unsigned long)_rowCount);
        [columns addObject:[newColumn mutableCopy]];
    }
    _columnCount += numberOfNewColumns;
}

- (NSArray *)removeCellsBeforeRow:(NSUInteger)newFirstRow column:(NSUInteger)newFirstColumn
{
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    while (newFirstColumn && _columnCount) {
        [cellsToRemove addObjectsFromArray:[columns firstObject]];
        [columns removeObjectAtIndex:0];
        
        _columnCount--;
        if (_columnCount == 0) {
            _rowCount = 0;
            break;
        }
        newFirstColumn--;
    }
    
    while (newFirstRow && _rowCount) {
        for (NSMutableArray *column in columns) {
            if([column firstObject]){
                [cellsToRemove addObject:[column firstObject]];
                [column removeObjectAtIndex:0];
            }
        }
        
        _rowCount--;
        if (_rowCount == 0) {
            [columns removeAllObjects];
            _columnCount = 0;
            break;
        }
        newFirstRow--;
    }
    if(_rowCount == 0){
        _rowIndex = -1;
    }
    else{
        _rowIndex += newFirstRow;
    }
    return cellsToRemove;
}

- (NSArray *)removeCellsUntilRow:(int)untilRow column:(NSUInteger)newFirstColumn{
    //NSLog(@"removecelluntilRow %d", untilRow);
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    while (newFirstColumn && _columnCount) {
        [cellsToRemove addObjectsFromArray:[columns firstObject]];
        [columns removeObjectAtIndex:0];
        
        _columnCount--;
        if (_columnCount == 0) {
            _rowCount = 0;
            break;
        }
        newFirstColumn--;
    }
    NSInteger newFirstRow  = untilRow - _rowIndex;
    while (newFirstRow && _rowCount) {
        for (NSMutableArray *column in columns) {
            if([column firstObject]){
                [cellsToRemove addObject:[column firstObject]];
                [column removeObjectAtIndex:0];
            }
        }
        
        _rowCount--;
        if (_rowCount == 0) {
            [columns removeAllObjects];
            _columnCount = 0;
            break;
        }
        newFirstRow--;
    }
    
    _rowIndex  = untilRow;
    
    return cellsToRemove;
    
    
}

- (NSArray *)removeCellsAfterRow:(NSUInteger)newLastRow column:(NSUInteger)newLastColumn
{
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    NSInteger rowsToRemove = _rowCount - newLastRow - 1;
    if (rowsToRemove < 0) rowsToRemove = 0;
    
    NSInteger columnsToRemove = _columnCount - newLastColumn - 1;
    if (columnsToRemove < 0) columnsToRemove = 0;
    
    while (columnsToRemove && _columnCount) {
        [cellsToRemove addObjectsFromArray:[columns lastObject]];
        [columns removeLastObject];
        
        _columnCount--;
        if (_columnCount == 0) {
            _rowCount = 0;
            break;
        }
        columnsToRemove--;
    }
    
    while (rowsToRemove && _rowCount) {
        for (NSMutableArray *column in columns) {
            if([column lastObject]){
                [cellsToRemove addObject:[column lastObject]];
                [column removeLastObject];
            }
        }
        
        _rowCount--;
        if (_rowCount == 0) {
            [columns removeAllObjects];
            _columnCount = 0;
            break;
        }
        rowsToRemove--;
    }
    if(_rowCount == 0){
        _rowIndex = -1;
    }
    return cellsToRemove;
}

- (NSArray *)removeAllCells
{
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    for (NSMutableArray *column in columns) {
        [cellsToRemove addObjectsFromArray:column];
    }
    
    [columns removeAllObjects];
    
    _rowCount = 0;
    _columnCount = 0;
    _rowIndex = -1;
    return cellsToRemove;
}

@end


