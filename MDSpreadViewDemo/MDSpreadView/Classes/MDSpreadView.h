//
//  MDSpreadView.h
//  MDSpreadViewDemo
//
//

#import <UIKit/UIKit.h>
#import "MDSpreadViewCell.h"

#import "MDSpreadViewCellMap.h"
#import "CellCache.h"

typedef NS_ENUM(NSUInteger, MDSpreadViewScrollPosition) {
    MDSpreadViewScrollPositionNone,
    MDSpreadViewScrollPositionAutomatic,
    MDSpreadViewScrollPositionTopLeft,
    MDSpreadViewScrollPositionTopMiddle,
    MDSpreadViewScrollPositionTopRight,
    MDSpreadViewScrollPositionCenterLeft,
    MDSpreadViewScrollPositionCenterMiddle,
    MDSpreadViewScrollPositionCenterRight,
    MDSpreadViewScrollPositionBottomLeft,
    MDSpreadViewScrollPositionBottomMiddle,
    MDSpreadViewScrollPositionBottomRight
};

typedef NS_ENUM(NSUInteger, MDSpreadViewSelectionMode) {
    MDSpreadViewSelectionModeNone,
    MDSpreadViewSelectionModeAutomatic,
    MDSpreadViewSelectionModeCell,
    MDSpreadViewSelectionModeRow,
    MDSpreadViewSelectionModeColumn,
    MDSpreadViewSelectionModeRowAndColumn
};


@protocol MDSpreadViewDataSource;


@class MDSpreadViewSelection;


@class CanvasView;

#pragma mark - MDSpreadViewDelegate

@protocol MDSpreadViewDelegate<NSObject, UIScrollViewDelegate>

@optional

// Display customization

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSInteger)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSInteger)rowPath;

- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection;
- (void)spreadView:(MDSpreadView *)aSpreadView willDisplayCell:(MDSpreadViewCell *)cell forHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection;
- (void)spreadView:(MDSpreadView *)aSpreadView willLayout:(Boolean)willLayout;






// Selection

// Called just after the user touches down on a cell. Return a new selection, or nil, to change the proposed highlight.
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willHighlightCellWithSelection:(MDSpreadViewSelection *)selection;

// Called after the user lifts their finger.
- (void)spreadView:(MDSpreadView *)aSpreadView didHighlightCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView didUnhighlightCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath;

// Called before the user changes the selection. Return a new selection, or nil, to change the proposed selection.
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willSelectCellWithSelection:(MDSpreadViewSelection *)selection;
- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willDeselectCellWithSelection:(MDSpreadViewSelection *)selection;

// Called after the user changes the selection.
- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;
- (void)spreadView:(MDSpreadView *)aSpreadView didDeselectCellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;

- (void)spreadView:(MDSpreadView *)aSpreadView didZoom:(Boolean)DidZoom;
- (void)spreadView:(MDSpreadView *)aSpreadView didDuringZoom:(Boolean)DidDuringZoom;


@end

#pragma mark - MDSpreadViewDataSource

@protocol MDSpreadViewDataSource<NSObject>

@required

- (NSInteger)numberOfColumnsInSection;
- (NSInteger)numberOfRowsInSection;


- (long)spreadViewMergeId:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;



// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;

@optional
// shorthands for fast cell generation
// not called if cells are manually geneated
// generally, return an NSString, but just about anything that returns description can be used,
// or can also be something that a custom cell defines
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSInteger)columnPath;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSInteger )rowPath;

- (id)spreadView:(MDSpreadView *)aSpreadView objectValueForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection;
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection;




// manual cell generation. returning nil creates one for you
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSInteger)columnPath;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSInteger)rowPath;

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)columnSection forRowFooterSection:(NSInteger)rowSection;




- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(NSInteger)indexPath;
- (CGFloat)heightForRowHeaderInSection; // pass 0 to hide header
//- (CGFloat)heightForRowFooterInSection; // pass 0 to hide footer

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(NSInteger)indexPath;
- (CGFloat)widthForColumnHeaderInSection; // pass 0 to hide header
//- (CGFloat)widthForColumnFooterInSection; // pass 0 to hide header
@end



@interface MDSelectPosition : NSObject {
    NSInteger column;
    NSInteger row;
}


+ (MDSelectPosition *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column;

@property (nonatomic,readonly) NSInteger row;
@property (nonatomic,readonly) NSInteger column;



@end

enum {MDSpreadViewSelectWholeSpreadView = -1};

@interface MDSpreadViewSelection : NSObject {
    NSInteger rowPath;
    NSInteger columnPath;
    MDSpreadViewSelectionMode selectionMode;
}

@property (nonatomic) NSInteger rowPath;
@property (nonatomic) NSInteger columnPath;
@property (nonatomic, readonly) MDSpreadViewSelectionMode selectionMode;

+ (id)selectionWithRow:(NSInteger)row column:(NSInteger)column mode:(MDSpreadViewSelectionMode)mode;

@end


#pragma mark - MDSpreadView

@interface MDSpreadView : UIScrollView {
    
    
    
@private
    id <MDSpreadViewDataSource> __weak _dataSource;
    
    CellCache *_dequeuedCells;
    NSMutableSet *_topMergeIdSet;
    NSMutableSet *_topMergeIdSetAux;
    
    // New algorithm
    
    
    CGRect mapBounds;
    
    NSInteger minColumnIndexPath;
    NSInteger maxColumnIndexPath;
    NSInteger minRowIndexPath;
    NSInteger maxRowIndexPath;
    
    NSMutableArray *columnSections;
    NSMutableArray *rowSections;
    
    
    
    //CGSize dequeuedCellSizeHint;
    //MDIndexPath *dequeuedCellRowIndexHint;
    //MDIndexPath *dequeuedCellColumnIndexHint;
    
    
    
    UIView *anchorCell;
    UIView *anchorRowHeaderCell;
    UIView *anchorColumnHeaderCell;
    UIView *anchorCornerHeaderCell;
    
    
    
    
    
    
    
    
    
    
    
    
    
    BOOL didSetHeaderHeight;
    
    BOOL didSetHeaderWidth;
    
    
    NSMutableArray *_selectedCells;
    MDSpreadViewSelection *_currentSelection;
    
    
    MDSpreadViewSelectionMode selectionMode;
    
    
    //NSTimer *reloadTimer;
    //BOOL preventReload;
    
    BOOL allowsSelection;
    BOOL allowsMultipleSelection;
    
   
    
 
    
}





@property (nonatomic, weak)  id <MDSpreadViewDataSource> dataSource;
@property (nonatomic, weak)  id <MDSpreadViewDelegate> delegate;

// Cell Dimensions. The header and footers will report their values, but they will only be used if you
// implement a data source method for those cells. Otherwise, set them here and they will be used.
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat sectionRowHeaderHeight;

@property (nonatomic) CGFloat columnWidth;
@property (nonatomic) CGFloat sectionColumnHeaderWidth;


// default cell setters. must be subclasses of MDSpreadViewCell;
@property (nonatomic, weak) Class defaultHeaderCornerCellClass; // header column, header row
@property (nonatomic, weak) Class defaultHeaderColumnCellClass; // header column, content row


@property (nonatomic, weak) Class defaultHeaderRowCellClass; // header row
@property (nonatomic, weak) Class defaultCellClass; // content row

- (void) didReceiveMemoryWarning;
// Data
- (void)setCellQueue:(CellCache *)queue;
- (void)reloadData;
- (void)_clearAllCells;
- (CGFloat)_widthForColumnHeaderInSection;
- (CGFloat)_widthForColumnAtIndexPath:(NSInteger)columnPath;

- (CGFloat)_heightForRowHeaderInSection;
- (CGFloat)_heightForRowAtIndexPath:(NSInteger)rowPath;


- (NSInteger)_numberOfColumnsInSection;
- (NSInteger)_numberOfRowsInSection;
// reloads everything from scratch. redisplays visible rows. because we only keep info about visible rows, this is cheap. will adjust offset if table shrinks



- (CGRect)rectForRowSection:(NSInteger)rowSection columnSection:(NSInteger)columnSection;

- (CGRect)cellRectForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;


- (MDSpreadViewCell *)cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;            // returns nil if cell is not visible or index path is out of range


// Selection

@property (nonatomic) MDSpreadViewSelectionMode highlightMode;
// the default highlight mode. defaults to MDSpreadViewSelectionModeCell. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as MDSpreadViewSelectionModeNone.
@property (nonatomic) MDSpreadViewSelectionMode selectionMode;
// the default selection mode. defaults to MDSpreadViewSelectionModeAutomatic. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as highlightMode.
@property (nonatomic) BOOL allowsSelection;
// default is YES. Controls whether rows can be selected when not in editing mode
//@property (nonatomic) BOOL preservesSortSelections;
// default is YES. If a selection is related to a sort, and allowsMultipleSelection is NO, any other non-selection will not deselect that selection, while any other sort selection on the same axis will.
@property (nonatomic) BOOL allowsMultipleSelection;
// default is NO. Controls whether multiple rows can be selected simultaneously

@property (nonatomic) MDSpreadViewSelectionMode rowHeaderHighlightMode; // defaults to MDSpreadViewSelectionModeRow
@property (nonatomic) MDSpreadViewSelectionMode columnHeaderHighlightMode; // defaults to MDSpreadViewSelectionModeColumn
@property (nonatomic) MDSpreadViewSelectionMode cornerHeaderHighlightMode; // defaults to MDSpreadViewSelectionModeCell
// the default highlight mode for header cells. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as  highlightMode.

@property (nonatomic) MDSpreadViewSelectionMode rowHeaderSelectionMode; // defaults to MDSpreadViewSelectionModeRow
@property (nonatomic) MDSpreadViewSelectionMode columnHeaderSelectionMode; // defaults to MDSpreadViewSelectionModeColumn
@property (nonatomic) MDSpreadViewSelectionMode cornerHeaderSelectionMode; // defaults to MDSpreadViewSelectionModeCell
// the default selection mode for header cells. Setting to MDSpreadViewSelectionModeAutomatic results in the same behaviour as selectionMode.

// Allow headers to be highlighted, and eventually selected. Defaults to NO. These apply for footers as well
@property (nonatomic) BOOL allowsRowHeaderSelection;
@property (nonatomic) BOOL allowsColumnHeaderSelection;
@property (nonatomic) BOOL allowsCornerHeaderSelection;





- (void)selectCellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath withSelectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition;
// scroll position only works with MDSpreadViewScrollPositionNone for now
- (void)deselectCellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath animated:(BOOL)animated;
- (void)removeAllSelections:(BOOL)animated notify:(BOOL)notify;
// Appearance





- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier row:(int)row column:(int)column;
// Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.




- (NSArray *)getContentMap;
- (NSArray *)getColumnHeaders;
- (NSArray *)getRowHeaders;









- (void)clearCanvas;
@property (nonatomic, strong) CanvasView * canvas;

@end


