//
//  MDHugeADataSource.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 4/25/14.
//  Copyright (c) 2014 Mochi Development, Inc. All rights reserved.
//

#import "MDHugeADataSource.h"

@implementation MDHugeADataSource

#pragma mark - Spread View Datasource

- (NSInteger) numberOfColumnsInSection
{
    return 50;
}

- (NSInteger) numberOfRowsInSection
{
//    if (section == 0 || section == 2) return 0;
    return 100;
}



#pragma mark Heights
// Comment these out to use normal values (see MDSpreadView.h)



- (CGFloat)heightForRowHeaderInSection {
    return 25;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(NSInteger)indexPath {
    return 25;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(NSInteger)indexPath {
    return 50;
}
- (CGFloat)widthForColumnHeaderInSection {
    return 50;
}


#pragma Cells

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath {
    MDSpreadViewCell * result = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"pheecian"];
    
    [result setContent:[NSString stringWithFormat:@"%ld-%ld", rowPath, columnPath]];
    [result setNewUnderline:YES];
    
    [result setFontColor:[UIColor blackColor]];
    [result setBackgroundColor:[UIColor whiteColor]];
    [result setNewFont:[UIFont fontWithName:@"Courier" size:[UIFont labelFontSize]]];
    [result setLeftBoardType:Line];
    [result setLeftBoardColor:[UIColor blueColor]];
    [result setRightBoardColor:[UIColor blueColor]];
    [result setTopBoardColor:[UIColor redColor]];
     [result setBottomBoardColor:[UIColor redColor]];
    [result setRightBoardType:Line];
    [result setTopBoardType:Line];
    [result setBottomBoardType:Line];
    return result;
    
}

- (long)spreadViewMergeId:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath {
    if (rowPath == 0 && columnPath == 0) return 1;
    if (rowPath == 1 && columnPath == 0) return 1;
    if (rowPath == 1 && columnPath == 1) return 1;
    if (rowPath == 0 && columnPath == 1) return 1;
    if (rowPath == 10 && columnPath == 10) return 11;
    if (rowPath == 11 && columnPath == 10) return 11;
    if (rowPath == 11 && columnPath == 11) return 11;
    if (rowPath == 10 && columnPath == 11) return 11;
    
    return 0;
    
}

/*Lefter header*/
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSInteger)rowPath {
    MDSpreadViewCell * result = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"pheecian"];
    [result setContent:[NSString stringWithFormat:@"%ld", rowPath]];
    [result setBackgroundColor:[UIColor whiteColor]];
    [result setLeftBoardType:Line];
    [result setRightBoardType:Line];
    [result setTopBoardType:Line];
    [result setBottomBoardType:Line];
    [result setVAlign:VerticalAlignmentMiddle];
    [result setAlign:NSTextAlignmentCenter];
    return result;
}

/*top header*/
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSInteger)columnPath {
    MDSpreadViewCell * result = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"pheecian"];
    [result setContent:[NSString stringWithFormat:@"%ld", columnPath]];
    [result setBackgroundColor:[UIColor whiteColor]];
    [result setLeftBoardType:Line];
    [result setRightBoardType:Line];
    [result setTopBoardType:Line];
    [result setBottomBoardType:Line];
    [result setVAlign:VerticalAlignmentMiddle];
    [result setAlign:NSTextAlignmentCenter];
    return result;
}

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection {
    MDSpreadViewCell * result = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"pheecian"];
    [result setContent:@""];
    [result setBackgroundColor:[UIColor whiteColor]];
    [result setLeftBoardType:Line];
    [result setRightBoardType:Line];
    [result setTopBoardType:Line];
    [result setBottomBoardType:Line];
    return result;
}











- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willHighlightCellWithSelection:(MDSpreadViewSelection *)selection
{
    return [MDSpreadViewSelection selectionWithRow:selection.rowPath column:selection.columnPath mode:MDSpreadViewSelectionModeRowAndColumn];
}

- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willSelectCellWithSelection:(MDSpreadViewSelection *)selection
{
    return [MDSpreadViewSelection selectionWithRow:selection.rowPath column:selection.columnPath mode:MDSpreadViewSelectionModeRowAndColumn];
}

@end
