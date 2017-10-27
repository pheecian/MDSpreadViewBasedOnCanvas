//
//  MDSpreadView.m
//  MDSpreadViewDemo
//
//

#import "MDSpreadView.h"
#import "MDSpreadViewCell.h"

#import "MDSpreadViewHeaderCell.h"
#import "CanvasView.h"

#import <objc/runtime.h>

#define DIST_BETWEEN_COMMENT_AND_CELL 4
#define DIST_BETWEEN_DATAVALIDATION_AND_CELL 4

//# define MDSpreadViewFrameTime
#pragma mark - Helper functions
// From https://gist.github.com/dimitribouniol/5085495



#pragma mark - MDSpreadViewCellMap




@interface MDSpreadViewCell ()

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, readwrite, assign) MDSpreadView *spreadView;



@property (nonatomic) CGRect _pureFrame;

- (void)_updateSeparators;

@end

#pragma mark - MDSpreadViewSection

@interface MDSpreadViewSection : NSObject

@property (nonatomic) NSInteger numberOfCells;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat size;

@end

@implementation MDSpreadViewSection

@end

#pragma mark - MDSpreadViewSizeCache

@interface MDSpreadViewSizeCache : NSObject

@property (nonatomic) NSInteger indexPath;
@property (nonatomic) CGFloat size;


- (instancetype)initWithIndexPath:(NSInteger)indexPath size:(CGFloat)size;

@end

@implementation MDSpreadViewSizeCache

- (instancetype)initWithIndexPath:(NSInteger)indexPath size:(CGFloat)size
{
    if (self = [super init]) {
        self.indexPath = indexPath;
        self.size = size;
    }
    return self;
}

@end

#pragma mark - MDSpreadViewSelection

@interface MDSpreadViewSelection ()


@property (nonatomic, readwrite) MDSpreadViewSelectionMode selectionMode;

@end

@implementation MDSpreadViewSelection

@synthesize rowPath, columnPath, selectionMode;

+ (id)selectionWithRow:(NSInteger)row column:(NSInteger)column mode:(MDSpreadViewSelectionMode)mode
{
    MDSpreadViewSelection *pair = [[self alloc] init];
    
    pair.rowPath = row;
    pair.columnPath = column;
    pair.selectionMode = mode;
    
    return pair;
}

- (BOOL)isEqual:(MDSpreadViewSelection *)object
{
    if ([object isKindOfClass:[MDSpreadViewSelection class]]) {
        if (self == object) return YES;
        return (self.rowPath == object.rowPath &&
                self.columnPath == object.columnPath);
    }
    return NO;
}




@end

#pragma mark - MDIndexPath




@implementation MDSelectPosition

@synthesize column, row;



+ (MDSelectPosition *)indexPathForRow:(NSInteger)b inColumn:(NSInteger)a
{
    MDSelectPosition *path = [[self alloc] init];
    
    path->column = a;
    path->row = b;
    
    return path;
}


@end





#pragma mark - MDSpreadView

@interface MDSpreadView ()

- (void)_performInit;




- (void)_willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;

- (MDSpreadViewCell *)_cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;
- (long)_getMergeId:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection;
- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSInteger)columnPath;
- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSInteger)rowPath;



- (void)_setNeedsReloadData;



@property (nonatomic, strong) MDSpreadViewSelection *_currentSelection;





@end

@implementation MDSpreadView

- (void) didReceiveMemoryWarning
{
    //NSLog(@"%zd", mapForContent.rowCount);
    
}

+ (NSDictionary *)MDAboutControllerTextCreditDictionary
{
    if (self == [MDSpreadView class]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Tables powered by MDSpreadView, available free on GitHub!", @"Text", @"https://github.com/mochidev/MDSpreadViewDemo", @"Link", nil];
    }
    return nil;
}

#pragma mark - Setup

@synthesize dataSource=_dataSource;
@synthesize selectionMode;
@synthesize _currentSelection, allowsMultipleSelection, allowsSelection;






-(void)setCellQueue:(CellCache *)queue
{
    _dequeuedCells = queue;
    
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _performInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _performInit];
    }
    return self;
}

- (void)_performInit
{
    
    self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.directionalLockEnabled = YES;
    
    
    _topMergeIdSet = [[NSMutableSet alloc] init];
    _topMergeIdSetAux = [[NSMutableSet alloc] init];
    
    
    
    _rowHeight = 44;
    _sectionRowHeaderHeight = 22;
    
    _columnWidth = 220;
    _sectionColumnHeaderWidth = 110;
    
    
    
    
    _selectedCells = [[NSMutableArray alloc] init];
    
    
    _highlightMode = MDSpreadViewSelectionModeCell;
    selectionMode = MDSpreadViewSelectionModeAutomatic;
    allowsSelection = YES;
    allowsMultipleSelection = NO;
    
    _rowHeaderHighlightMode = MDSpreadViewSelectionModeRow;
    _columnHeaderHighlightMode = MDSpreadViewSelectionModeColumn;
    _cornerHeaderHighlightMode = MDSpreadViewSelectionModeCell;
    
    _rowHeaderSelectionMode = MDSpreadViewSelectionModeRow;
    _columnHeaderSelectionMode = MDSpreadViewSelectionModeColumn;
    _cornerHeaderSelectionMode = MDSpreadViewSelectionModeCell;
    
    _allowsRowHeaderSelection = NO;
    _allowsColumnHeaderSelection = NO;
    _allowsCornerHeaderSelection = NO;
    
    
    
    _defaultCellClass = [MDSpreadViewCell class];
    _defaultHeaderColumnCellClass = [MDSpreadViewHeaderCell class];
    _defaultHeaderCornerCellClass = [MDSpreadViewHeaderCell class];
    _defaultHeaderRowCellClass = [MDSpreadViewHeaderCell class];
    
    
    
    anchorCell = [[UIView alloc] init];
    
    [self addSubview:anchorCell];
    
    anchorColumnHeaderCell = [[UIView alloc] init];
    
    [self addSubview:anchorColumnHeaderCell];
    
    anchorRowHeaderCell = [[UIView alloc] init];
    
    [self addSubview:anchorRowHeaderCell];
    
    anchorCornerHeaderCell = [[UIView alloc] init];
    
    [self addSubview:anchorCornerHeaderCell];
    
    
    
    _canvas = [[CanvasView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self addSubview:_canvas];
    _canvas.spreadView = self;
    
    
    
    
    
    
}

- (id<MDSpreadViewDelegate>)delegate
{
    return (id<MDSpreadViewDelegate>)super.delegate;
}

- (void)setDelegate:(id<MDSpreadViewDelegate>)delegate
{
    //[self _setNeedsReloadData];
    super.delegate = delegate;
}

- (void)setDataSource:(id<MDSpreadViewDataSource>)dataSource
{
    
    _dataSource = dataSource;
    [self _setNeedsReloadData];
}

- (void)dealloc
{
    //[reloadTimer invalidate];
    //reloadTimer = nil;
    //preventReload = YES; // UIScrollView stupidly calls self.delegate = nil; instead of _delegate = nil, so we are forced to do this…
}

#pragma mark - Data

- (void)setRowHeight:(CGFloat)newHeight
{
    _rowHeight = newHeight;
    
    
    
}

- (void)setSectionRowHeaderHeight:(CGFloat)newHeight
{
    _sectionRowHeaderHeight = newHeight;
    
    didSetHeaderHeight = YES;
    
}



- (void)setColumnWidth:(CGFloat)newWidth
{
    _columnWidth = newWidth;
    
}

- (void)setSectionColumnHeaderWidth:(CGFloat)newWidth
{
    _sectionColumnHeaderWidth = newWidth;
    
    didSetHeaderWidth = YES;
    
}













- (void)_setNeedsReloadData
{
    //if (preventReload) return;
    //if (!reloadTimer) {
    //reloadTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(_reloadDataRightAway:) userInfo:nil repeats:NO];
    //}
    [self reloadData];
}

- (void)_reloadDataRightAway:(id)sender
{
    [self reloadData];
}

- (void)reloadData
{
    //NSLog(@"reloadData");
    //[reloadTimer invalidate];
    //reloadTimer = nil;
    
    @autoreleasepool {
        
        
        CGFloat totalWidth = 0;
        CGFloat totalHeight = 0;
        
        [self _clearAllCells];
        /*previous info*/
        minColumnIndexPath = NSIntegerMin;
        maxColumnIndexPath = NSIntegerMin;
        minRowIndexPath = NSIntegerMin;
        maxRowIndexPath = NSIntegerMin;
        
        NSMutableArray *newColumnSections = [[NSMutableArray alloc] init];
        
        
        MDSpreadViewSection *sectionDescriptor = [[MDSpreadViewSection alloc] init];
        [newColumnSections addObject:sectionDescriptor];
        
        NSUInteger numberOfColumns = [self _numberOfColumnsInSection];
        sectionDescriptor.numberOfCells = numberOfColumns;
        sectionDescriptor.offset = totalWidth;
        
        
        
        for (NSInteger j = -1; j < (NSInteger)numberOfColumns; j++) {
            totalWidth += [self _widthForColumnAtIndexPath:j];
        }
        
        
        
        sectionDescriptor.size = totalWidth;
        
        columnSections = newColumnSections;
        
        NSMutableArray *newRowSections = [[NSMutableArray alloc] init];
        
        
        MDSpreadViewSection *sectionDescriptor2 = [[MDSpreadViewSection alloc] init];
        [newRowSections addObject:sectionDescriptor2];
        
        NSUInteger numberOfRows = [self _numberOfRowsInSection];
        sectionDescriptor2.numberOfCells = numberOfRows;
        sectionDescriptor2.offset = totalHeight;
        
        
        
        for (NSInteger j = -1; j < (NSInteger)numberOfRows; j++) {
            
            totalHeight += [self _heightForRowAtIndexPath:j];
        }
        
        
        
        sectionDescriptor2.size = totalHeight;
        
        
        rowSections = newRowSections;
        
        self.contentSize = CGSizeMake(totalWidth, totalHeight);
        _canvas.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}




#pragma mark - Layout

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    
    CGPoint offset = self.contentOffset;
    UIEdgeInsets inset = self.contentInset;
    
    
    if (offset.x <= 0 || offset.y <= 0) {
        if (offset.x <= 0) offset.x = -inset.left;
        if (offset.y <= 0) offset.y = -inset.top;
        
        self.contentOffset = offset;
    }
}

//#define MDSpreadViewFrameTime

- (void)layoutSubviews
{
    
    //NSLog(@"layout subviews");
    [super layoutSubviews];
    
    //if (reloadTimer) {
    //  [self reloadData];
    //return;
    //}
    if ([self.delegate respondsToSelector:@selector(spreadView:willLayout:)])
        [self.delegate spreadView:self willLayout:YES];
    
    /* OK, the general algorithm will be something like this:
     
     1. Calculate the current bounding rect of the content. That is to say, the:
     visibleBounds
     minRowIndexPath (inclusive)
     maxRowIndexPath (inclusive)
     minColumnIndexPath
     maxColumnIndexPath
     Practically, these bounds will be ever so slightly larger than the actual bounds, to accomodate for contentInset.
     While we are at it, we will cache widths and heights into two arrays, so they don't need to be re-calculated later.
     We will use the existing visibleBounds, along with references to cell sizes to calculate this.
     However, if the (min|max)*IndexPath is different than the existing (min|max)*IndexPath, the calculations
     for that dimension will be calculated based on the existing sections.
     Finally, don't forget to include the sizes of any headers and footers! Headers have an index or -1 while
     footers have an index of sectionCount+1.
     
     For a spread view with 2 column/row sections, with 3 and 4 items respectively, we will get this:
     C C C  C C C C
     C C C  C C C C
     C C C  C C C C
     
     C C C  C C C C
     C C C  C C C C
     C C C  C C C C
     C C C  C C C C
     
     2. Remove any *content* cells that are outside of these bounds.
     Although we probably don't have any yet, *content* cells will be arranged in a 2D array with markers to
     the current min/max index paths in each direction.
     If any dimension is empty, that dimension will be marked as voided.
     Space will *not* be skipped for any headers and footers in this structure.
     
     3. Add back new content cells until the structure is complete
     
     4. Based on this, we will now calculate the column header/footer min/max index paths.
     The only difference here is that we will round the first index path to the first/last columns of a section
     for the header and footer respectively.
     As before, we remove any header and footer that fall outside this range, and then add new ones
     This 2D structure will be similar, but will only have column headers and footers, alternating each column
     (It'll probably only be 2 or 3 columns wide, while having the same height as the main structure)
     If we add any headers before an existing one, or footers after the end of the last one, be sure to reset
     the frames of the affected cells (aka, they used to be pinned)
     
     Assuming everything fit on screen, we will get a structure similar to this:
     H F  H F
     H F  H F
     H F  H F
     H F  H F
     H F  H F
     H F  H F
     H F  H F
     
     5. From here, we locate the first header and last footer, and pin them to the current horizontal bounds
     
     6. Now, we do the same for the row headers and footers.
     
     Assuming everything fit on screen, we will get a structure similar to this:
     H H H H H H H
     F F F F F F F
     
     H H H H H H H
     F F F F F F F
     
     7. Finally, we will do a similar treatment for the header and footer corner cells.
     
     The headers and footers will assume this structure:
     H B  H B
     A F  A F
     
     H B  H B
     A F  A F
     
     Note: Maybe row/column headers and footers should be in different structures?
     
     
     */
    //NSLog(@"remembered stuff: [%d-%d]", minRowIndexPath.row, maxRowIndexPath.row);
    // STEP 1
    
#ifdef MDSpreadViewFrameTime
    CFAbsoluteTime frameTime = CFAbsoluteTimeGetCurrent();
#endif
    
    CGRect bounds = self.bounds;
    UIEdgeInsets insets = self.contentInset;
    CGRect insetBounds = UIEdgeInsetsInsetRect(bounds, insets);
    
    CGRect _visibleBounds = CGRectZero;
    
    
    
    NSInteger minRowIndex = -1;
    NSInteger maxRowIndex = -1;
    NSInteger minColumnIndex = -1;
    NSInteger maxColumnIndex = -1;
    
    MDSpreadViewSection *section = [rowSections firstObject];
    CGFloat height = section.size;
    
    _visibleBounds.size.height += height;
    
    
    NSInteger numberOfRows = section.numberOfCells;
    
    // find min row index
    float deltaForSpeed = bounds.origin.y;
    for (NSInteger row = -1; row < numberOfRows; row++) { // take into account header and footer
        
        CGFloat height = [self _heightForRowAtIndexPath:row];
        
        if (height && height > deltaForSpeed - _visibleBounds.origin.y) {
            minRowIndex = row;
            break;
        }
        _visibleBounds.origin.y += height;
        _visibleBounds.size.height -= height;
        
    }
    
    
    
    // find max row index
    deltaForSpeed = - bounds.origin.y - bounds.size.height;
    
    for (NSInteger row = numberOfRows-1; row >= -1; row--) { // take into account header and footer
        CGFloat height = [self _heightForRowAtIndexPath:row];
        
        if (height && deltaForSpeed  +  _visibleBounds.origin.y + _visibleBounds.size.height  < height ) {
            maxRowIndex = row;
            break;
        }
        _visibleBounds.size.height -= height;
        //NSLog(@"%f", _visibleBounds.size.height);
        
    }
    
    //    NSLog(@"Row: [%d-%d, %d-%d]", minRowSection, minRowIndex, maxRowSection, maxRowIndex);
    
    
    
    // find min/max column sections
    MDSpreadViewSection *section2 = [columnSections firstObject];
    CGFloat width = section2.size;
    
    _visibleBounds.size.width += width;
    
    
    NSInteger numberOfColumns = section2.numberOfCells;
    
    // find min column index
    for (NSInteger column = -1; column < numberOfColumns; column++) { // take into account header and footer
        CGFloat width = [self _widthForColumnAtIndexPath:column];
        
        if (width && _visibleBounds.origin.x + width > bounds.origin.x) {
            minColumnIndex = column;
            break;
        }
        _visibleBounds.origin.x += width;
        _visibleBounds.size.width -= width;
        
    }
    
    
    
    // find max column index
    for (NSInteger column = numberOfColumns-1; column >= -1; column--) { // take into account header and footer
        CGFloat width = [self _widthForColumnAtIndexPath:column];
        
        if (width && _visibleBounds.origin.x + _visibleBounds.size.width - width < bounds.origin.x + bounds.size.width) {
            maxColumnIndex = column;
            break;
        }
        _visibleBounds.size.width -= width;
        
    }
    
    // NSLog(@"Column1: [%ld %ld, %ld %ld]", minColumnIndex, minRowIndex, maxColumnIndex, maxRowIndex);
    
    /**********************************merge cell***************************/
    
    
    NSInteger minRowIndexMerge = minRowIndex;
    
    /**********************************merge cell***************************/
    
    
    NSInteger maxRowIndexMerge = maxRowIndex;
    
    /**********************************merge cell***************************/
    [_topMergeIdSet removeAllObjects];
    
    NSInteger minColumnIndexMerge = minColumnIndex;
    if(minColumnIndexMerge >0){
        for(NSInteger i = minRowIndex; i<= maxRowIndex; i++){
            long mergeId = [self _getMergeId:i forColumnAtIndexPath:minColumnIndexMerge];
            if(mergeId!=0){
                [_topMergeIdSet addObject:[NSNumber numberWithLong:mergeId]];
            }
        }
        while(minColumnIndexMerge){
            [_topMergeIdSetAux removeAllObjects];
            for(NSNumber * entry in _topMergeIdSet){
                bool exist = false;
                for(NSInteger i = minRowIndex; i<= maxRowIndex; i++){
                    if([self _getMergeId:i forColumnAtIndexPath:minColumnIndexMerge-1]==[entry longValue]){
                        exist = true;
                        break;
                    }
                }
                if(!exist){
                    [_topMergeIdSetAux addObject:entry];
                }
            }
            [_topMergeIdSet minusSet:_topMergeIdSetAux];
            if(![_topMergeIdSet count]){
                break;
            }
            minColumnIndexMerge--;
            CGFloat width = [self _widthForColumnAtIndexPath:minColumnIndexMerge];
            _visibleBounds.origin.x -= width;
            _visibleBounds.size.width += width;
            
        }
    }
    /**********************************mergecell***************************/
    [_topMergeIdSet removeAllObjects];
    
    NSInteger maxColumnIndexMerge = maxColumnIndex;
    
    
    
    
    
    //NSLog(@"Column: [%ld %ld, %ld %ld]", minColumnIndexMerge, minRowIndexMerge, maxColumnIndexMerge, maxRowIndexMerge);
    minColumnIndex = minColumnIndexMerge;
    minRowIndex = minRowIndexMerge;
    maxColumnIndex = maxColumnIndexMerge;
    maxRowIndex = maxRowIndexMerge;
    
    
    // STEP 2
    
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 2 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    
    // here, remove front columns and rows
    if (minColumnIndexPath >= -1) { // if this is nil, the others will be nil too
        
        // remove columns before
        
        NSInteger workingColumnIndex = minColumnIndexPath;
        
        
        
        NSInteger preColumnDifference = 0;
        NSInteger preContentColumnDifference = 0;
        
        
        while ( workingColumnIndex < minColumnIndex) { // go through sections
            if (workingColumnIndex > -1) {
                preContentColumnDifference++;
            }
            
            preColumnDifference++;
            
            workingColumnIndex++;
            
            
        }
        
        // remove rows before
        
        NSInteger workingRowIndex = minRowIndexPath;
        
        
        
        NSInteger preRowDifference = 0;
        NSInteger preContentRowDifference = 0;
        
        
        while (workingRowIndex < minRowIndex) { // go through sections
            if (workingRowIndex > -1) {
                preContentRowDifference++;
            }
            
            preRowDifference++;
            
            workingRowIndex++;
            
            
        }
        int untilRow;
        if(workingRowIndex > minRowIndex){
            untilRow = (int)workingRowIndex;
        }
        else {
            untilRow = (int)minRowIndex;
        }
        if(untilRow == -1){
            untilRow = 0;
        }
        
        NSArray *oldCells = [_canvas.mapForContent removeCellsUntilRow:untilRow column:preContentColumnDifference];
        for (MDSpreadViewCell *cell in oldCells) {
            if ((NSNull *)cell != [NSNull null]) {
                cell.hidden = YES;
                //[_dequeuedCells insertObject:cell atIndex:0];
                [_dequeuedCells putCell:cell row:(int)cell._rowPath column:(int)cell._columnPath];
                //   NSLog(@"+,%lu", (unsigned long)[_dequeuedCells count]);
            }
            
        }
        
        oldCells = [_canvas.mapForColumnHeaders removeCellsBeforeRow:preContentRowDifference column:0];
        for (MDSpreadViewCell *cell in oldCells) {
            if ((NSNull *)cell != [NSNull null]) {
                cell.hidden = YES;
                //[_dequeuedCells insertObject:cell atIndex:0];
                [_dequeuedCells putCell:cell row:(int)cell._rowPath column:(int)cell._columnPath];
            }
        }
        
        oldCells = [_canvas.mapForRowHeaders removeCellsBeforeRow:0 column:preContentColumnDifference];
        for (MDSpreadViewCell *cell in oldCells) {
            if ((NSNull *)cell != [NSNull null]) {
                cell.hidden = YES;
                //[_dequeuedCells insertObject:cell atIndex:0];
                [_dequeuedCells putCell:cell row:(int)cell._rowPath column:(int)cell._columnPath];
            }
        }
        
        if (preColumnDifference) {
            mapBounds.size.width = mapBounds.origin.x + mapBounds.size.width - _visibleBounds.origin.x;
            mapBounds.origin.x = _visibleBounds.origin.x;
            minColumnIndexPath = minColumnIndex;
        }
        
        if (preRowDifference) {
            mapBounds.size.height = mapBounds.origin.y + mapBounds.size.height - _visibleBounds.origin.y;
            mapBounds.origin.y = _visibleBounds.origin.y;
            minRowIndexPath = minRowIndex;
        }
        
    }
    
    // remove back columns and rows
    if (maxColumnIndexPath >= -1) { // if this is nil, the others will be nil too
        
        // remove columns after
        
        NSInteger workingColumnIndex = maxColumnIndexPath;
        
        
        
        NSInteger postColumnDifference = 0;
        NSInteger postContentColumnDifference = 0;
        
        
        while (workingColumnIndex > maxColumnIndex) {
            if (workingColumnIndex > -1) {
                postContentColumnDifference++;
            }
            
            postColumnDifference++;
            
            workingColumnIndex--;
            
            
        }
        
        // remove columns after
        
        NSInteger workingRowIndex = maxRowIndexPath;
        
        
        
        NSInteger postRowDifference = 0;
        NSInteger postContentRowDifference = 0;
        
        
        while ( workingRowIndex > maxRowIndex) {
            if (workingRowIndex > -1) {
                postContentRowDifference++;
            }
            postRowDifference++;
            
            workingRowIndex--;
            
            
        }
        
        //        NSLog(@"Removing %d]", postColumnDifference);
        
        if (postColumnDifference > 0 || postRowDifference > 0) {
            NSArray *oldCells = [_canvas.mapForContent removeCellsAfterRow:_canvas.mapForContent.rowCount - 1 - postContentRowDifference
                                                                    column:_canvas.mapForContent.columnCount - 1 - postContentColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    //[_dequeuedCells insertObject:cell atIndex:0];
                    [_dequeuedCells putCell:cell row:(int)cell._rowPath column:(int)cell._columnPath];
                    //  NSLog(@"+,%lu", (unsigned long)[_dequeuedCells count]);
                }
            }
            
            oldCells = [_canvas.mapForColumnHeaders removeCellsAfterRow:_canvas.mapForColumnHeaders.rowCount - 1 - postContentRowDifference
                                                                 column:_canvas.mapForColumnHeaders.columnCount - 1 ];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    //[_dequeuedCells insertObject:cell atIndex:0];
                    [_dequeuedCells putCell:cell row:(int)cell._rowPath column:(int)cell._columnPath];
                }
            }
            
            oldCells = [_canvas.mapForRowHeaders removeCellsAfterRow:_canvas.mapForRowHeaders.rowCount - 1
                                                              column:_canvas.mapForRowHeaders.columnCount - 1 - postContentColumnDifference];
            for (MDSpreadViewCell *cell in oldCells) {
                if ((NSNull *)cell != [NSNull null]) {
                    cell.hidden = YES;
                    //[_dequeuedCells insertObject:cell atIndex:0];
                    [_dequeuedCells putCell:cell row:(int)cell._rowPath column:(int)cell._columnPath];
                }
            }
            
            if (postColumnDifference) {
                mapBounds.size.width = _visibleBounds.origin.x + _visibleBounds.size.width - mapBounds.origin.x;
                maxColumnIndexPath = maxColumnIndex;
            }
            
            if (postRowDifference) {
                mapBounds.size.height = _visibleBounds.origin.y + _visibleBounds.size.height - mapBounds.origin.y;
                maxRowIndexPath = maxRowIndex;
            }
        }
    }
    
    // STEP 3
    //CFAbsoluteTime frameTime = CFAbsoluteTimeGetCurrent();
    //NSLog(@"step 3 Frame time:  row before %d row after %d",  minRowIndexPath.row, minRowIndex);
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 3 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    // here, add rows, then columns
    
    // if there is already some content, add rows
    if ([_canvas.mapForContent hasContent]) {
        
        
        NSInteger currentMinColumnIndex = minColumnIndexPath;
        
        NSInteger currentMaxColumnIndex = maxColumnIndexPath;
        
        // add rows before
        if ( minRowIndexPath > minRowIndex) {
            
            NSInteger workingRowIndex = minRowIndex;
            
            
            NSInteger finalRowIndex = minRowIndexPath;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            
            NSInteger indexBegin = -1;
            while ( workingRowIndex < finalRowIndex) { // go through sections
                //NSLog(@"while Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnIndex index:currentMaxColumnIndex  headersOnly:NO];
                }
                
                
                CGFloat height = [self _heightForRowAtIndexPath:workingRowIndex];
                offset.x = mapBounds.origin.x;
                NSArray *row = [self _layoutRowAtIndexPath:workingRowIndex
                                                  isHeader:NO headerContents:NO
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows addObject:row];
                    if(indexBegin < 0){
                        indexBegin = workingRowIndex;
                    }
                }
                
                offset.y += height;
                
                workingRowIndex++;
            }
            
            [_canvas.mapForContent insertRowsBefore:rows indexBegin:indexBegin];
            columnSizesCache = nil;
        }
        
        // add rows after
        if ( maxRowIndexPath < maxRowIndex) {
            
            
            NSInteger workingRowIndex = maxRowIndex;
            
            //  NSInteger finalRowSection = maxRowIndexPath.section;
            NSInteger finalRowIndex = maxRowIndexPath;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y + _visibleBounds.size.height);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            
            NSInteger indexBegin;
            while (workingRowIndex > finalRowIndex) { // go through sections
                
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:currentMinColumnIndex index:currentMaxColumnIndex headersOnly:NO];
                }
                
                
                CGFloat height = [self _heightForRowAtIndexPath:workingRowIndex];
                offset.y -= height;
                offset.x = mapBounds.origin.x;
                NSArray *row = [self _layoutRowAtIndexPath:workingRowIndex
                                                  isHeader:NO headerContents:NO
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows insertObject:row atIndex:0];
                    indexBegin = workingRowIndex;
                }
                
                workingRowIndex--;
                
            }
            
            [_canvas.mapForContent insertRowsAfter:rows];
            columnSizesCache = nil;
        }
        
        // add columns before
        if ( minColumnIndexPath > minColumnIndex) {
            
            
            NSInteger workingColumnIndex = minColumnIndex;
            
            
            NSInteger finalColumnIndex = minColumnIndexPath;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            
            
            while ( workingColumnIndex < finalColumnIndex) { // go through sections
                
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex  index:maxRowIndex headersOnly:NO];
                }
                
                
                CGFloat width = [self _widthForColumnAtIndexPath:workingColumnIndex];
                offset.y = _visibleBounds.origin.y;
                NSArray *column = [self _layoutColumnAtIndexPath:workingColumnIndex
                                                        isHeader:NO headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns addObject:column];
                }
                
                offset.x += width;
                
                workingColumnIndex++;
                
            }
            
            [_canvas.mapForContent insertColumnsBefore:columns];
            rowSizesCache = nil;
        }
        
        // add columns after
        if ( maxColumnIndexPath < maxColumnIndex) {
            
            
            NSInteger workingColumnIndex = maxColumnIndex;
            
            //  NSInteger finalColumnSection = maxColumnIndexPath.section;
            NSInteger finalColumnIndex = maxColumnIndexPath;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x + _visibleBounds.size.width, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            
            
            while ( workingColumnIndex > finalColumnIndex) { // go through sections
                
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex index:maxRowIndex headersOnly:NO];
                }
                
                
                CGFloat width = [self _widthForColumnAtIndexPath:workingColumnIndex];
                offset.x -= width;
                offset.y = _visibleBounds.origin.y;
                NSArray *column = [self _layoutColumnAtIndexPath:workingColumnIndex
                                                        isHeader:NO headerContents:NO
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns insertObject:column atIndex:0];
                }
                
                workingColumnIndex--;
                
            }
            
            [_canvas.mapForContent insertColumnsAfter:columns];
            rowSizesCache = nil;
        }
        
    } else { // if there is nothing, start fresh, and do the whole thing in one go
        
        [_canvas.mapForContent removeAllCells];
        
        
        NSInteger workingColumnIndex = minColumnIndex;
        
        CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        
        
        while ( workingColumnIndex <= maxColumnIndex) { // go through sections
            
            if (!rowSizesCache) {
                rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex index:maxRowIndex headersOnly:NO];
            }
            
            
            CGFloat width = [self _widthForColumnAtIndexPath:workingColumnIndex];
            offset.y = _visibleBounds.origin.y;
            NSArray *column = [self _layoutColumnAtIndexPath:workingColumnIndex
                                                    isHeader:NO headerContents:NO
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (column) {
                [columns addObject:column];
            }
            
            offset.x += width;
            
            workingColumnIndex++;
            
        }
        
        [_canvas.mapForContent insertColumnsAfter:columns];
        rowSizesCache = nil;
    }
    
    //STEP 3.5
    /****************render additional cell for out of screen merge cell*******************/
    
    [_topMergeIdSet removeAllObjects];
    
    NSInteger minRowIndexForMerge = minRowIndex;
    
    if(minRowIndexForMerge > 0){
        for(NSInteger i = minColumnIndex; i<= maxColumnIndex; i++){
            long mergeId = [self _getMergeId:minRowIndexForMerge forColumnAtIndexPath:i];
            if(mergeId!=0){
                [_topMergeIdSet addObject:[NSNumber numberWithLong:mergeId]];
            }
        }
        while(minRowIndexForMerge){
            [_topMergeIdSetAux removeAllObjects];
            for(NSNumber * entry in _topMergeIdSet){
                bool exist = false;
                for(NSInteger i = minColumnIndex; i<= maxColumnIndex; i++){
                    if([self _getMergeId:minRowIndexForMerge-1 forColumnAtIndexPath:i]==[entry longValue]){
                        exist = true;
                        break;
                    }
                }
                if(!exist){
                    [_topMergeIdSetAux addObject:entry];
                }
            }
            [_topMergeIdSet minusSet:_topMergeIdSetAux];
            if(![_topMergeIdSet count]){
                break;
            }
            minRowIndexForMerge--;
            
        }
    }
    if(minRowIndexForMerge < minRowIndex){
        
        
        
        // add rows before for merge
        
        
        
        NSInteger workingRowIndex = minRowIndexForMerge;
        if(workingRowIndex == -1){
            workingRowIndex = 0;
        }
        
        NSInteger finalRowIndex = minRowIndex;
        CGPoint offset = CGPointMake(0, _visibleBounds.origin.y);
        while ( workingRowIndex < finalRowIndex) { // go through sections
            
            
            
            
            
            CGFloat height = [self _heightForRowAtIndexPath:workingRowIndex];
            
            
            
            offset.y -= height;
            
            workingRowIndex++;
        }
        
        
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        NSArray *columnSizesCache = nil;
        workingRowIndex = minRowIndexForMerge;
        if(workingRowIndex == -1){
            workingRowIndex = 0;
        }
        NSInteger indexBegin = -1;
        while ( workingRowIndex < finalRowIndex) { // go through sections
            
            
            if (!columnSizesCache) {
                columnSizesCache = [self _generateColumnSizeCacheBetweenSection:minColumnIndex index:maxColumnIndex  headersOnly:NO];
            }
            
            
            CGFloat height = [self _heightForRowAtIndexPath:workingRowIndex];
            offset.x = _visibleBounds.origin.x;
            //NSLog(@"_layoutRowAtIndexPathForMerge %d", rowIndexPath.row);
            NSArray *row = [self _layoutRowAtIndexPathForMerge:workingRowIndex
                                                      isHeader:NO headerContents:NO
                                                        offset:offset height:height columnSizesCache:columnSizesCache targetRow:(int)finalRowIndex];
            
            if (row) {
                [rows addObject:row];
                if(indexBegin < 0){
                    indexBegin = workingRowIndex;
                }
            }
            
            offset.y += height;
            
            workingRowIndex++;
        }
        
        [_canvas.mapForContent insertRowsBefore:rows indexBegin:indexBegin];
        columnSizesCache = nil;
        
    }
    
    
    
    
    // STEP 4
    //NSLog(@"step 4 Frame time: %.1fms row before %d row after %d", (CFAbsoluteTimeGetCurrent() - frameTime)*1000., minRowIndexPath.row, minRowIndex);
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 4 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    if ([_canvas.mapForColumnHeaders hasContent]) {
        
        
        
        // add rows before
        if (minRowIndexPath > minRowIndex) {
            
            
            NSInteger workingRowIndex = minRowIndex;
            
            //  NSInteger finalRowSection = minRowIndexPath.section;
            NSInteger finalRowIndex = minRowIndexPath;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            
            
            while (workingRowIndex < finalRowIndex) { // go through sections
                
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:0
                                                                              index:0
                                                                        headersOnly:YES];
                }
                
                
                CGFloat height = [self _heightForRowAtIndexPath:workingRowIndex];
                NSArray *row = [self _layoutRowAtIndexPath:workingRowIndex
                                                  isHeader:NO headerContents:YES
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows addObject:row];
                }
                
                offset.y += height;
                
                workingRowIndex++;
                
            }
            
            [_canvas.mapForColumnHeaders insertRowsBefore:rows];
            columnSizesCache = nil;
        }
        
        // add rows after
        if ( maxRowIndexPath < maxRowIndex) {
            
            
            NSInteger workingRowIndex = maxRowIndex;
            
            //  NSInteger finalRowSection = maxRowIndexPath.section;
            NSInteger finalRowIndex = maxRowIndexPath;
            
            CGPoint offset = CGPointMake(0, _visibleBounds.origin.y + _visibleBounds.size.height);
            
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            NSArray *columnSizesCache = nil;
            
            
            
            while (workingRowIndex > finalRowIndex) { // go through sections
                
                
                if (!columnSizesCache) {
                    columnSizesCache = [self _generateColumnSizeCacheBetweenSection:0
                                                                              index:0
                                                                        headersOnly:YES];
                }
                
                
                CGFloat height = [self _heightForRowAtIndexPath:workingRowIndex];
                offset.y -= height;
                NSArray *row = [self _layoutRowAtIndexPath:workingRowIndex
                                                  isHeader:NO headerContents:YES
                                                    offset:offset height:height columnSizesCache:columnSizesCache];
                
                if (row) {
                    [rows insertObject:row atIndex:0];
                }
                
                workingRowIndex--;
            }
            
            [_canvas.mapForColumnHeaders insertRowsAfter:rows];
            columnSizesCache = nil;
        }
        
        
        
    } else { // if there is nothing, start fresh, and do the whole thing in one go
        
        [_canvas.mapForColumnHeaders removeAllCells];
        
        
        
        CGPoint offset = CGPointZero;
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        // while (workingColumnSection <= maxColumnSection) { // go through sections
        
        
        if (!rowSizesCache) {
            rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex  index:maxRowIndex  headersOnly:NO];
        }
        
        
        
        
        
        
        CGFloat width = [self _widthForColumnAtIndexPath:-1];
        offset.x = 0;
        offset.y = _visibleBounds.origin.y;
        NSArray *header = [self _layoutColumnAtIndexPath:-1
                                                isHeader:YES headerContents:NO
                                                  offset:offset width:width rowSizesCache:rowSizesCache];
        
        if (header) {
            [columns addObject:header];
        }
        
        
        [_canvas.mapForColumnHeaders insertColumnsAfter:columns];
        rowSizesCache = nil;
    }
    
    // STEP 5
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 5 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    if ([_canvas.mapForColumnHeaders hasContent]) {
        
        NSArray *columns = _canvas.mapForColumnHeaders.allColumns;
        
        BOOL isHeader = YES;
        
        
        NSArray *column = [columns firstObject] ;
        
        MDSpreadViewSection *currentSection = [columnSections firstObject];
        CGFloat headerWidth = [self _widthForColumnHeaderInSection];
        CGFloat sectionSize = currentSection.size;
        
        CGFloat newOffset = 0;
        
        if (isHeader) {
            if ( sectionSize - headerWidth  < insetBounds.origin.x) {
                newOffset =  sectionSize - headerWidth ;
            } else if (0 < insetBounds.origin.x) {
                newOffset = insetBounds.origin.x;
            } else {
                newOffset = 0;
            }
            
        }
        
        for (MDSpreadViewCell *cell in column) {
            if ((NSNull *)cell == [NSNull null]) continue;
            
            CGRect frame = cell._pureFrame;
            
            frame.origin.x = newOffset;
            
            cell.frame = frame;
        }
        
        
        
    }
    
    // STEP 6
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 6 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    if ([_canvas.mapForRowHeaders hasContent]) {
        
        
        
        
        
        
        // add columns before
        if (minColumnIndexPath > minColumnIndex) {
            
            
            NSInteger workingColumnIndex = minColumnIndex;
            
            // NSInteger finalColumnSection = minColumnIndexPath.section;
            NSInteger finalColumnIndex = minColumnIndexPath;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            
            
            while (workingColumnIndex < finalColumnIndex) { // go through sections
                
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex index:maxRowIndex headersOnly:YES];
                }
                
                
                CGFloat width = [self _widthForColumnAtIndexPath:workingColumnIndex];
                NSArray *column = [self _layoutColumnAtIndexPath:workingColumnIndex
                                                        isHeader:NO headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns addObject:column];
                }
                
                offset.x += width;
                
                workingColumnIndex++;
                
            }
            
            [_canvas.mapForRowHeaders insertColumnsBefore:columns];
            rowSizesCache = nil;
        }
        
        // add columns after
        if ( maxColumnIndexPath < maxColumnIndex) {
            
            NSInteger workingColumnIndex = maxColumnIndex;
            
            //    NSInteger finalColumnSection = maxColumnIndexPath.section;
            NSInteger finalColumnIndex = maxColumnIndexPath;
            
            CGPoint offset = CGPointMake(_visibleBounds.origin.x + _visibleBounds.size.width, 0);
            
            NSMutableArray *columns = [[NSMutableArray alloc] init];
            NSArray *rowSizesCache = nil;
            
            
            
            while (workingColumnIndex > finalColumnIndex) { // go through sections
                
                if (!rowSizesCache) {
                    rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex  index:maxRowIndex headersOnly:YES];
                }
                
                
                CGFloat width = [self _widthForColumnAtIndexPath:workingColumnIndex];
                offset.x -= width;
                NSArray *column = [self _layoutColumnAtIndexPath:workingColumnIndex
                                                        isHeader:NO headerContents:YES
                                                          offset:offset width:width rowSizesCache:rowSizesCache];
                
                if (column) {
                    [columns insertObject:column atIndex:0];
                }
                
                workingColumnIndex--;
                
            }
            
            [_canvas.mapForRowHeaders insertColumnsAfter:columns];
            rowSizesCache = nil;
        }
        
    } else { // if there is nothing, start fresh, and do the whole thing in one go
        
        [_canvas.mapForRowHeaders removeAllCells];
        
        
        NSInteger workingColumnIndex = minColumnIndex;
        
        CGPoint offset = CGPointMake(_visibleBounds.origin.x, 0);
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        
        
        while (workingColumnIndex <= maxColumnIndex) { // go through sections
            
            
            if (!rowSizesCache) {
                rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex  index:maxRowIndex  headersOnly:YES];
            }
            
            
            CGFloat width = [self _widthForColumnAtIndexPath:workingColumnIndex];
            NSArray *column = [self _layoutColumnAtIndexPath:workingColumnIndex
                                                    isHeader:NO headerContents:YES
                                                      offset:offset width:width rowSizesCache:rowSizesCache];
            
            if (column) {
                [columns addObject:column];
            }
            
            offset.x += width;
            
            workingColumnIndex++;
            
        }
        
        [_canvas.mapForRowHeaders insertColumnsAfter:columns];
        rowSizesCache = nil;
    }
    
    // STEP 7
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 7 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    if ([_canvas.mapForRowHeaders hasContent]) {
        
        NSArray *rows = _canvas.mapForRowHeaders.allRows;
        
        BOOL isHeader = YES;
        NSInteger workingRowSection = 0;
        
        NSArray *row = [rows firstObject];
        NSAssert((workingRowSection < 1), @"Over section bounds!");
        
        MDSpreadViewSection *currentSection = [rowSections firstObject];
        CGFloat headerHeight = [self _heightForRowHeaderInSection];
        // CGFloat footerHeight = [self _heightForRowFooterInSection];
        //    CGFloat sectionOffset = currentSection.offset;
        CGFloat sectionSize = currentSection.size;
        
        CGFloat newOffset = 0;
        
        if (isHeader) {
            if ( sectionSize - headerHeight  < insetBounds.origin.y) {
                newOffset =  sectionSize - headerHeight ;
            } else if (0 < insetBounds.origin.y) {
                newOffset = insetBounds.origin.y;
            } else {
                newOffset = 0;
            }
        }
        
        for (MDSpreadViewCell *cell in row) {
            if ((NSNull *)cell == [NSNull null]) continue;
            
            CGRect frame = cell._pureFrame;
            
            frame.origin.y = newOffset;
            
            cell.frame = frame;
        }
        
        
        rows = nil;
        row = nil;
    }
    
    // STEP 8
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 8 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    if (![_canvas.mapForCornerHeaders hasContent]) {
        
        
        [_canvas.mapForCornerHeaders removeAllCells];
        
        
        
        CGPoint offset = CGPointZero;
        
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        NSArray *rowSizesCache = nil;
        
        
        
        if (!rowSizesCache) {
            rowSizesCache = [self _generateRowSizeCacheBetweenSection:minRowIndex  index:maxRowIndex  headersOnly:YES];
        }
        
        
        
        
        
        
        CGFloat width = [self _widthForColumnAtIndexPath:-1];
        offset.x = 0;
        offset.y = _visibleBounds.origin.y;
        NSArray *header = [self _layoutColumnAtIndexPath:-1
                                                isHeader:YES headerContents:YES
                                                  offset:offset width:width rowSizesCache:rowSizesCache];
        
        if (header) {
            [columns addObject:header];
        }
        
        
        [_canvas.mapForCornerHeaders insertColumnsAfter:columns];
        rowSizesCache = nil;
    }
    
    // STEP 9
#ifdef MDSpreadViewFrameTime
    NSLog(@"step 9 Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    if ([_canvas.mapForCornerHeaders hasContent]) {
        
        NSArray *columns = _canvas.mapForCornerHeaders.allColumns;
        
        BOOL isColumnHeader = YES;
        NSInteger workingColumnSection = 0;
        
        NSArray *column = [columns firstObject];
        
        
        
        MDSpreadViewSection *currentColumnSection = [columnSections objectAtIndex:workingColumnSection];
        CGFloat headerWidth = [self _widthForColumnHeaderInSection];
        // CGFloat footerWidth = [self _widthForColumnFooterInSection];
        //CGFloat sectionOffset = currentColumnSection.offset;
        CGFloat sectionSize = currentColumnSection.size;
        
        CGPoint newOffset = CGPointZero;
        
        if (isColumnHeader) {
            if (sectionSize - headerWidth  < insetBounds.origin.x) {
                newOffset.x =  sectionSize - headerWidth ;
            } else if (0 < insetBounds.origin.x) {
                newOffset.x = insetBounds.origin.x;
            } else {
                newOffset.x = 0;
            }
        }
        
        BOOL isRowHeader = YES;
        NSInteger workingRowSection = 0;
        
        MDSpreadViewCell *cell = [column firstObject];
        if ((NSNull *)cell != [NSNull null]) {
            
            
            
            MDSpreadViewSection *currentRowSection = [rowSections objectAtIndex:workingRowSection];
            CGFloat headerHeight = [self _heightForRowHeaderInSection];
            // CGFloat footerHeight = [self _heightForRowFooterInSection];
            //CGFloat sectionOffset = currentRowSection.offset;
            sectionSize = currentRowSection.size;
            
            if (isRowHeader) {
                if ( sectionSize - headerHeight  < insetBounds.origin.y) {
                    newOffset.y =  sectionSize - headerHeight ;
                } else if (0 < insetBounds.origin.y) {
                    newOffset.y = insetBounds.origin.y;
                } else {
                    newOffset.y = 0;
                }
            }
            
            
            CGRect frame = cell._pureFrame;
            
            frame.origin = newOffset;
            
            cell.frame = frame;
        }
        
    }
    
    
    mapBounds = _visibleBounds;
    minColumnIndexPath = minColumnIndex;
    maxColumnIndexPath = maxColumnIndex;
    minRowIndexPath = minRowIndex;
    maxRowIndexPath = maxRowIndex;
    
    
#ifdef MDSpreadViewFrameTime
    NSLog(@"Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
#endif
    
    _canvas.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.frame.size.width, self.frame.size.height);
    
}

// Only call this if the frame is non-zero!!
- (MDSpreadViewCell *)_preparedCellForRowAtIndexPath:(NSInteger)rowIndexPath forColumnAtIndexPath:(NSInteger)columnIndexPath frame:(CGRect)frame
{
    MDSpreadViewCell *cell = nil;
    //CFAbsoluteTime frameTime = CFAbsoluteTimeGetCurrent();
    
    NSInteger row = rowIndexPath;
    NSInteger rowSection = 0;
    NSInteger column = columnIndexPath;
    NSInteger columnSection = 0;
    
    //dequeuedCellSizeHint = frame.size;
    //dequeuedCellRowIndexHint = rowIndexPath;
    //dequeuedCellColumnIndexHint = columnIndexPath;
    
    if (row == -1 && column == -1) { // corner header
        cell = [self _cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
        
        
    }
    
    else if (row == -1) { // header row
        cell = [self _cellForHeaderInRowSection:rowSection forColumnAtIndexPath:columnIndexPath];
        
    } else if (column == -1) { // header column
        cell = [self _cellForHeaderInColumnSection:columnSection forRowAtIndexPath:rowIndexPath];
        
    } else { // content
        cell = [self _cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath];
        
    }
    //CFAbsoluteTime frameTime2 = CFAbsoluteTimeGetCurrent();
    /*********************pheecian*********************/
    
    long mergeId = [self _getMergeId:row forColumnAtIndexPath:column];
    if(mergeId != 0 ){
        bool shouldShow = false;
        if(row == 0 && column == 0)shouldShow = true;
        else if(row ==0){
            long leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            if(leftMergeId != mergeId)shouldShow = true;
        }
        else if(column == 0){
            long upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
            if(upMergeId != mergeId)shouldShow = true;
        }
        else{
            long leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            long upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
            if(leftMergeId != mergeId && upMergeId != mergeId)shouldShow = true;
        }
        if(shouldShow){
            CGRect newFrame = CGRectZero;
            CGSize size = [self _generateMergeCellSize:row column:column mergeId:mergeId];
            newFrame.size = size;
            newFrame.origin = frame.origin;
            cell._pureFrame = newFrame;
        }
        else{
            cell._pureFrame = CGRectZero;
        }
    }
    else {
        cell._pureFrame = frame;
    }
    cell.hidden = NO;
    
    BOOL shouldSelect = NO;
    
    for (MDSpreadViewSelection *selection in _selectedCells) {
        
        if (cell._columnPath == selection.columnPath) {
            
            
            if (cell._rowPath == selection.rowPath) {
                shouldSelect = YES;
            }
        }
    }
    
    [cell setSelected:shouldSelect animated:NO];
    
    BOOL shouldHighlight = NO;
    
    
    
    [cell setHighlighted:shouldHighlight animated:NO];
    
    
    [self _willDisplayCell:cell forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath];
    
    cell.needDraw = true;
    //NSLog(@"prepare time: %.1fms %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000., 1000*(frameTime2 - frameTime));
    return cell;
}

// Only call this if the frame is non-zero!!
- (MDSpreadViewCell *)_preparedCellForRowAtIndexPathForMerge:(NSInteger)rowIndexPath forColumnAtIndexPath:(NSInteger)columnIndexPath  frame:(CGRect)frame targetRow:(int)targetRow
{
    MDSpreadViewCell *cell = nil;
    UIView *anchor = nil;
    
    NSInteger row = rowIndexPath;
    //NSInteger rowSection = rowIndexPath.section;
    NSInteger column = columnIndexPath;
    //NSInteger columnSection = columnIndexPath.section;
    
    //dequeuedCellSizeHint = frame.size;
    //dequeuedCellRowIndexHint = rowIndexPath;
    //dequeuedCellColumnIndexHint = columnIndexPath;
    
    
    
    /*********************merge cell*********************/
    
    long mergeId = [self _getMergeId:row forColumnAtIndexPath:column];
    if(mergeId != 0 ){
        bool shouldShow = false;
        if(row == 0 && column == 0)shouldShow = true;
        else if(row ==0){
            long leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            if(leftMergeId != mergeId)shouldShow = true;
        }
        else if(column == 0){
            long upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
            if(upMergeId != mergeId)shouldShow = true;
        }
        else{
            long leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            long upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
            if(leftMergeId != mergeId && upMergeId != mergeId)shouldShow = true;
        }
        if(shouldShow){
            long targetMergeId = [self _getMergeId:targetRow forColumnAtIndexPath:column];
            if(targetMergeId == mergeId){
                cell = [self _cellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath];
                anchor = anchorCell;
                CGRect newFrame = CGRectZero;
                CGSize size = [self _generateMergeCellSize:row column:column mergeId:mergeId];
                newFrame.size = size;
                newFrame.origin = frame.origin;
                cell._pureFrame = newFrame;
            }
            else{
                return nil;
            }
        }
        else{
            return nil;
        }
    }
    else {
        return nil;
    }
    cell.hidden = NO;
    
    BOOL shouldSelect = NO;
    
    for (MDSpreadViewSelection *selection in _selectedCells) {
        if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
        
        if (cell._rowPath == selection.rowPath) {
            if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldSelect = YES;
            }
        }
        
        if (cell._columnPath == selection.columnPath) {
            if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                shouldSelect = YES;
            }
            
            if (cell._rowPath == selection.rowPath && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                shouldSelect = YES;
            }
        }
    }
    
    [cell setSelected:shouldSelect animated:NO];
    
    BOOL shouldHighlight = NO;
    
   
    
    [cell setHighlighted:shouldHighlight animated:NO];
    
    
    
    [self _willDisplayCell:cell forRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath];
    
    cell.needDraw = true;
    
    return cell;
}


- (NSArray *)_generateColumnSizeCacheBetweenSection:(NSInteger)minColumnIndex index:(NSInteger)maxColumnIndex headersOnly:(BOOL)headersOnly
{
    NSMutableArray *columnSizesCache = [[NSMutableArray alloc] init];
    
    if (headersOnly) {
        minColumnIndex = -1;
        maxColumnIndex = -1;
    }
    
    
    NSInteger workingColumnIndex = minColumnIndex;
    
    
    while (workingColumnIndex <= maxColumnIndex) { // go through sections
        
        
        
        
        if (!headersOnly || (workingColumnIndex == -1 ))
            [columnSizesCache addObject:[[MDSpreadViewSizeCache alloc] initWithIndexPath:workingColumnIndex size:[self _widthForColumnAtIndexPath:workingColumnIndex]]];
        
        workingColumnIndex++;
        
    }
    
    return columnSizesCache;
}

/************************pheecian****************/
- (CGSize)_generateMergeCellSize:(NSInteger)row column:(NSInteger)column mergeId:(long)mergeId
{
    
    CGFloat totalHeight = 0;
    NSInteger numberOfRows = [self _numberOfRowsInSection];
    while(row < numberOfRows && ([self _getMergeId:row forColumnAtIndexPath:column] == mergeId)){
        totalHeight += [self _heightForRowAtIndexPath:row];
        row++;
    }
    row--;
    CGFloat totalWidth = 0;
    NSInteger numberOfColumns = [self _numberOfColumnsInSection];
    while(column < numberOfColumns && ([self _getMergeId:row forColumnAtIndexPath:column] == mergeId)){
        totalWidth += [self _widthForColumnAtIndexPath:column];
        column++;
    }
    
    return CGSizeMake(totalWidth,totalHeight);
}

- (NSArray *)_generateRowSizeCacheBetweenSection:(NSInteger)minRowIndex index:(NSInteger)maxRowIndex  headersOnly:(BOOL)headersOnly
{
    NSMutableArray *rowSizesCache = [[NSMutableArray alloc] init];
    
    if (headersOnly) {
        minRowIndex = -1;
        maxRowIndex = -1;
    }
    
    
    NSInteger workingRowIndex = minRowIndex;
    
    
    while (workingRowIndex <= maxRowIndex) { // go through sections
        
        
        
        
        if (!headersOnly || (workingRowIndex == -1 ))
            [rowSizesCache addObject:[[MDSpreadViewSizeCache alloc] initWithIndexPath:workingRowIndex size:[self _heightForRowAtIndexPath:workingRowIndex]]];
        
        workingRowIndex++;
        
    }
    
    return rowSizesCache;
}

- (NSArray *)_layoutColumnAtIndexPath:(NSInteger)columnIndexPath
                             isHeader:(BOOL)isHeader headerContents:(BOOL)headerContents
                               offset:(CGPoint)offset width:(CGFloat)width rowSizesCache:(NSArray *)rowSizesCache
{
    NSInteger workingColumnIndex = columnIndexPath;
    
    NSMutableArray *column = [[NSMutableArray alloc] init];
    
    CGRect frame = CGRectZero;
    frame.origin = offset;
    frame.size.width = width;
    
    if ((workingColumnIndex >= 0) || isHeader) {
        if (width > 0) {
            for (MDSpreadViewSizeCache *aSizeCache in rowSizesCache) {
                NSInteger rowIndexPath = aSizeCache.indexPath;
                
                
                CGFloat height = aSizeCache.size;
                frame.size.height = height;
                
                if (headerContents) {
                    MDSpreadViewSection *currentSection = [rowSections objectAtIndex:0];
                    
                    if (rowIndexPath == -1) {
                        frame.origin.y = 0;
                    } else {
                        frame.origin.y = currentSection.size - height;
                    }
                }
                
                NSInteger row = rowIndexPath;
                
                if ((row >= 0) || headerContents) {
                    if (height > 0 && width > 0) {
                        [column addObject:[self _preparedCellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath
                                                                         frame:frame]];
                    } else {
                        [column addObject:[NSNull null]];
                    }
                }
                
                frame.origin.y += height;
            }
        } else {
            for (MDSpreadViewSizeCache *aSizeCache in rowSizesCache) {
                
                NSInteger rowIndexPath = aSizeCache.indexPath;
                
                NSInteger row = rowIndexPath;
                
                
                if ((row >= 0) || headerContents) {
                    [column addObject:[NSNull null]];
                }
            }
        }
        
        return column;
    }
    
    return nil;
}

- (NSArray *)_layoutRowAtIndexPath:(NSInteger)rowIndexPath
                          isHeader:(BOOL)isHeader headerContents:(BOOL)headerContents
                            offset:(CGPoint)offset height:(CGFloat)height columnSizesCache:(NSArray *)columnSizesCache
{
    //CFAbsoluteTime frameTime = CFAbsoluteTimeGetCurrent();
    NSInteger workingRowIndex = rowIndexPath;
    
    NSMutableArray *row = [[NSMutableArray alloc] init];
    
    CGRect frame = CGRectZero;
    frame.origin = offset;
    frame.size.height = height;
    
    if ((workingRowIndex >= 0) || isHeader) {
        if (height > 0) {
            for (MDSpreadViewSizeCache *aSizeCache in columnSizesCache) {
                NSInteger columnIndexPath = aSizeCache.indexPath;
                //NSLog(@"layoutone time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
                
                CGFloat width = aSizeCache.size;
                frame.size.width = width;
                
                if (headerContents) {
                    MDSpreadViewSection *currentSection = [columnSections objectAtIndex:0];
                    
                    if (columnIndexPath == -1) {
                        frame.origin.x = 0;
                    } else {
                        frame.origin.x = currentSection.size - width;
                    }
                }
                
                NSInteger column = columnIndexPath;
                
                if ((column >= 0) || headerContents) {
                    if (width > 0 && height > 0) {
                        [row addObject:[self _preparedCellForRowAtIndexPath:rowIndexPath forColumnAtIndexPath:columnIndexPath
                                                                      frame:frame]];
                    } else {
                        [row addObject:[NSNull null]];
                    }
                }
                
                frame.origin.x += width;
            }
        } else {
            for (MDSpreadViewSizeCache *aSizeCache in columnSizesCache) {
                
                NSInteger columnIndexPath = aSizeCache.indexPath;
                
                NSInteger column = columnIndexPath;
                
                if ((column >= 0) || headerContents) {
                    [row addObject:[NSNull null]];
                }
                
            }
        }
        //if((CFAbsoluteTimeGetCurrent() - frameTime)*1000. > 10)
        //NSLog(@"layout time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
        return row;
    }
    
    return nil;
}

- (NSArray *)_layoutRowAtIndexPathForMerge:(NSInteger)rowIndexPath
                                  isHeader:(BOOL)isHeader headerContents:(BOOL)headerContents
                                    offset:(CGPoint)offset height:(CGFloat)height columnSizesCache:(NSArray *)columnSizesCache
                                 targetRow:(int)targetRow
{
    NSInteger workingRowIndex = rowIndexPath;
    
    NSMutableArray *row = [[NSMutableArray alloc] init];
    
    CGRect frame = CGRectZero;
    frame.origin = offset;
    frame.size.height = height;
    
    if ((workingRowIndex >= 0) || isHeader) {
        if (height > 0) {
            for (MDSpreadViewSizeCache *aSizeCache in columnSizesCache) {
                NSInteger columnIndexPath = aSizeCache.indexPath;
                
                
                CGFloat width = aSizeCache.size;
                frame.size.width = width;
                
                if (headerContents) {
                    MDSpreadViewSection *currentSection = [columnSections objectAtIndex:0];
                    
                    if (columnIndexPath == -1) {
                        frame.origin.x = 0;
                    } else {
                        frame.origin.x = currentSection.size - width;
                    }
                }
                
                NSInteger column = columnIndexPath;
                
                if ((column >= 0) || headerContents) {
                    if (width > 0 && height > 0) {
                        MDSpreadViewCell * cellPointer = [self _preparedCellForRowAtIndexPathForMerge:rowIndexPath forColumnAtIndexPath:columnIndexPath
                                                                                                frame:frame targetRow:targetRow];
                        if(cellPointer == nil) {
                            [row addObject:[NSNull null]];
                        }
                        else {
                            [row addObject:cellPointer];
                        }
                        
                    } else {
                        [row addObject:[NSNull null]];
                    }
                }
                
                frame.origin.x += width;
            }
        } else {
            for (MDSpreadViewSizeCache *aSizeCache in columnSizesCache) {
                
                
                
                NSInteger columnIndexPath = aSizeCache.indexPath;
                
                NSInteger column = columnIndexPath;
                
                if ((column >= 0) || headerContents) {
                    
                    
                    [row addObject:[NSNull null]];
                }
                
            }
        }
        
        return row;
    }
    
    return nil;
}

- (CGRect)rectForRowSection:(NSInteger)rowSection columnSection:(NSInteger)columnSection
{
    if (!rowSections || !columnSections ||
        rowSection < 0 || rowSection >= rowSections.count ||
        columnSection < 0 || columnSection >= columnSections.count) return CGRectNull;
    
    MDSpreadViewSection *column = [columnSections objectAtIndex:columnSection];
    MDSpreadViewSection *row = [rowSections objectAtIndex:rowSection];
    
    return CGRectMake(column.offset, row.offset, column.size, row.size);
}

- (CGRect)cellRectForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath
{
    if (!rowSections || !columnSections) return CGRectNull;
    
    MDSpreadViewSection *columnSection = [columnSections objectAtIndex:0];
    MDSpreadViewSection *rowSection = [rowSections objectAtIndex:0];
    
    if (rowPath < -1 || rowPath > rowSection.numberOfCells ||
        columnPath < -1 || columnPath > columnSection.numberOfCells) return CGRectNull;
    
    CGRect rect = CGRectMake(columnSection.offset, rowSection.offset, [self _widthForColumnAtIndexPath:columnPath], [self _heightForRowAtIndexPath:rowPath]);
    
    for (int i = -1; i < columnPath; i++) {
        rect.origin.x += [self _widthForColumnAtIndexPath:i];
    }
    
    for (int i = -1; i < rowPath; i++) {
        rect.origin.y += [self _heightForRowAtIndexPath:i];
    }
    
    return rect;
}

#pragma mark - Cell Management

- (MDSpreadViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier row:(int)row column:(int)column
{
    MDSpreadViewCell *dequeuedCell = nil;
    //NSUInteger _reuseHash = [identifier hash];
    /*
     for (MDSpreadViewCell *aCell in _dequeuedCells) {
     if (aCell->_reuseHash == _reuseHash ) {
     dequeuedCell = aCell;
     break;
     }
     }
     */
    
    dequeuedCell = [_dequeuedCells getCell:row column:column];
    
    
    
    return dequeuedCell;
}

- (void)_clearAllCells
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:[_canvas.mapForContent removeAllCells]];
    [array addObjectsFromArray:[_canvas.mapForColumnHeaders removeAllCells]];
    [array addObjectsFromArray:[_canvas.mapForRowHeaders removeAllCells]];
    [array addObjectsFromArray:[_canvas.mapForCornerHeaders removeAllCells]];
    
    for (MDSpreadViewCell *cell in array) {
        if ((NSNull *)cell != [NSNull null]) {
            cell.hidden = YES;
            
            [cell.connectionIds removeAllObjects];
            [_dequeuedCells putCell:cell row:(int)cell._rowPath column:(int)cell._columnPath];
        }
    }
    array = nil;
    
}

- (MDSpreadViewCell *)cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath
{
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:_canvas.mapForContent.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForCornerHeaders.allCells];
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        if (cell._rowPath == rowPath && cell._columnPath == columnPath) {
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - Fetchers

#pragma mark — Sizes
- (CGFloat)_widthForColumnHeaderInSection
{
    
    
    if ([self.dataSource respondsToSelector:@selector(widthForColumnHeaderInSection)]) {
        return [self.dataSource widthForColumnHeaderInSection];
    }
    
    
    
    return self.sectionColumnHeaderWidth;
}

- (CGFloat)_widthForColumnAtIndexPath:(NSInteger)columnPath
{
    if (columnPath < 0) return [self _widthForColumnHeaderInSection];
    else if (columnPath >= [self _numberOfColumnsInSection]){
        
        NSLog(@"bad bad");
        return 0;//[self _widthForColumnFooterInSection];
    }
    
    return [self.dataSource spreadView:self widthForColumnAtIndexPath:columnPath];
    
    
    
}



- (CGFloat)_heightForRowHeaderInSection
{
   
    if ([self.dataSource respondsToSelector:@selector(heightForRowHeaderInSection)]) {
        return [self.dataSource heightForRowHeaderInSection];
    }
    
    
    
    return self.sectionRowHeaderHeight;
}

- (CGFloat)_heightForRowAtIndexPath:(NSInteger)rowPath
{
    if (rowPath < 0) return [self _heightForRowHeaderInSection];
    else if (rowPath >= [self _numberOfRowsInSection]){
        NSLog(@"bad two");
        return 0;
    }
    
    
    return [self.dataSource spreadView:self heightForRowAtIndexPath:rowPath];
    
    
    
}



#pragma mark — Counts



- (NSInteger)_numberOfColumnsInSection
{
    
    
    NSInteger returnValue = 0;
    
    
    returnValue = MAX([_dataSource numberOfColumnsInSection], 0);
    
    return returnValue;
}

- (NSInteger)_numberOfRowsInSection
{
    
    
    NSInteger returnValue = 0;
    
    
    returnValue = MAX([_dataSource numberOfRowsInSection], 0);
    
    return returnValue;
}

#pragma mark — Cells
- (void)_willDisplayCell:(MDSpreadViewCell *)cell forRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath
{
    //NSInteger numberOfRowsInSection = [[rowSections objectAtIndex:rowPath.section] numberOfCells];
    //NSInteger numberOfColumnsInSection = [[columnSections objectAtIndex:columnPath.section] numberOfCells];
    
    //NSAssert((rowPath.row >= -1 && rowPath.row <= numberOfRowsInSection && columnPath.column >= -1 && columnPath.column <= numberOfColumnsInSection), @"Trying to display an out of range cell");
    
    if (rowPath != -1 && columnPath != -1) {
        
        
        
        
        
        //[self.delegate spreadView:self willDisplayCell:cell forRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    }
}

- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    //    NSLog(@"Getting header cell %d %d", rowSection, columnSection);
    MDSpreadViewCell *returnValue = nil;
    
    
    returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:rowSection forColumnSection:columnSection];
    
    
    
    returnValue.spreadView = self;
    returnValue._rowPath = -1;
    returnValue._columnPath = -1;
    
    
    
    
    return returnValue;
}

- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)rowSection forColumnFooterSection:(NSInteger)columnSection
{
    MDSpreadViewCell *returnValue = nil;
    
    if ([_dataSource respondsToSelector:@selector(spreadView:cellForHeaderInRowSection:forColumnFooterSection:)])
        returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:rowSection forColumnFooterSection:columnSection];
    
    NSInteger numberOfColumnsInSection = [[columnSections objectAtIndex:columnSection] numberOfCells];
    
    returnValue.spreadView = self;
    returnValue._rowPath = -1;
    returnValue._columnPath = numberOfColumnsInSection;
    
    
    
    return returnValue;
}



- (MDSpreadViewCell *)_cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(NSInteger)rowPath
{
    //    NSLog(@"Getting header cell %@ %d", rowPath, section);
    MDSpreadViewCell *returnValue = nil;
    
    
    returnValue = [_dataSource spreadView:self cellForHeaderInColumnSection:section forRowAtIndexPath:rowPath];
    
    
    
    returnValue.spreadView = self;
    returnValue._rowPath = rowPath;
    
    returnValue._columnPath = -1;
    //    [returnValue._tapGesture removeTarget:nil action:NULL];
    //    [returnValue._tapGesture addTarget:self action:@selector(_selectCell:)];
    
    
    
    return returnValue;
}





- (MDSpreadViewCell *)_cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(NSInteger)columnPath
{
    //    NSLog(@"Getting header cell %d %@", section, columnPath);
    MDSpreadViewCell *returnValue = nil;
    
    
    returnValue = [_dataSource spreadView:self cellForHeaderInRowSection:section forColumnAtIndexPath:columnPath];
    
    
    
    returnValue.spreadView = self;
    returnValue._rowPath = -1;
    returnValue._columnPath = columnPath;
    //    [returnValue._tapGesture removeTarget:nil action:NULL];
    //    [returnValue._tapGesture addTarget:self action:@selector(_selectCell:)];
    
    
    
    return returnValue;
}


- (MDSpreadViewCell *)_cellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath
{
    //    NSLog(@"Getting cell %@ %@", rowPath, columnPath);
    MDSpreadViewCell *returnValue = nil;
    
    
    returnValue = [_dataSource spreadView:self cellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    
    
    
    returnValue.spreadView = self;
    returnValue._rowPath = rowPath;
    returnValue._columnPath = columnPath;
    
    
    
    return returnValue;
}

- (long)_getMergeId:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath
{
    //    NSLog(@"Getting cell %@ %@", rowPath, columnPath);
    
    
    
    long returnValue = [_dataSource spreadViewMergeId:self cellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    
    return returnValue;
}







#pragma mark - Selection

- (BOOL)_touchesBeganInCell:(CanvasView *)cell
{//no matter you wanna scroll or select one cell, this method will always trigger
    
    //return NO means the gesture will end and the touchesEnd or touchedCancel will neither trigger
    
    //  NSLog(@"touchesBegan");
    [self _didTouchScroll];
    
    
    if (!allowsSelection) return NO;
    
    
    int rowPath = cell.touchRow;
    int columnPath = cell.touchColumn;
    NSInteger row = rowPath;
    NSInteger column = columnPath;
    long mergeId = [self _getMergeId:row forColumnAtIndexPath:column];
    if(mergeId != 0 ){
        if(row == 0 && column == 0){}
        else if(row ==0){
            long leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            while(leftMergeId == mergeId){
                column--;
                if(column == 0){
                    break;
                }
                leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            }
        }
        else if(column == 0){
            long upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
            while(upMergeId != mergeId){
                row--;
                if(row == 0){
                    break;
                }
                upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
            }
        }
        else{
            long leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            while(leftMergeId == mergeId){
                column--;
                if(column == 0){
                    break;
                }
                leftMergeId = [self _getMergeId:row forColumnAtIndexPath:column-1];
            }
            if(row > 0){
                long upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
                while(upMergeId != mergeId){
                    row--;
                    if(row == 0){
                        break;
                    }
                    upMergeId = [self _getMergeId:row-1 forColumnAtIndexPath:column];
                }
            }
        }
    }
    
    
    
    if ((row == -1 && column == -1))
    { // corner header
        if (!_allowsCornerHeaderSelection) {
            return NO;
        }
    }
    else if (row == -1 ) { // header row
        
        if (!_allowsColumnHeaderSelection) {
            return NO;
        }
    } else if (column == -1 ) { // header column
        
        if (!_allowsRowHeaderSelection) {
            return NO;
        }
    }
    MDSpreadViewSelection *selection = [MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:MDSpreadViewSelectionModeCell];
    self._currentSelection = selection;
    
    if (self._currentSelection) {
        allowsSelection = NO;
        return YES;
    } else {
        return NO;
    }
    
    
}

- (void)_touchesEndedInCell:(CanvasView *)cell
{//if you just scroll the screen, this function will not trigger, but the touchedCancelledInCell will trigger
    
    
    
    allowsSelection = YES;
    
    if (!self._currentSelection) return;
    
    
    
    MDSpreadViewSelectionMode resolvedSelectionMode = MDSpreadViewSelectionModeAutomatic;
    
    NSInteger rowPath = cell.touchRow;
    NSInteger columnPath = cell.touchColumn;
    NSInteger row = rowPath;
    
    NSInteger column = columnPath;
    
    
    if ((row == -1 && column == -1)) { // corner header
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _cornerHeaderHighlightMode;
        }
    } else if (row == -1 ) { // header row
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _columnHeaderHighlightMode;
        }
    } else if (column == -1 ) { // header column
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = _rowHeaderHighlightMode;
        }
    }
    
    if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
        resolvedSelectionMode = _highlightMode;
        
        if (resolvedSelectionMode == MDSpreadViewSelectionModeAutomatic) {
            resolvedSelectionMode = MDSpreadViewSelectionModeNone;
        }
    }
    
    MDSpreadViewSelection *selection = [MDSpreadViewSelection selectionWithRow:self._currentSelection.rowPath
                                                                        column:self._currentSelection.columnPath
                                                                          mode:resolvedSelectionMode];
    
    MDSpreadViewSelection *newSelection = [self _willSelectCellForSelection:selection];
    
    
    
    
    if (newSelection) {
        
        [self _addSelection:newSelection animated:YES notify:YES];
        
        CGFloat height = 0;
        for (NSInteger rowIter = -1; rowIter < row; rowIter++) { // take into account header and footer
            
            height += [self _heightForRowAtIndexPath:rowIter];
            
        }
        CGFloat width = 0;
        for (NSInteger columnIter = -1; columnIter < column; columnIter++) { // take into account header and footer
            
            width += [self _widthForColumnAtIndexPath:columnIter];
            
        }
        CGRect cellFrame = CGRectMake(width, height, [self _widthForColumnAtIndexPath:column], [self _heightForRowAtIndexPath:row]);
        int mergeId = (int)[self _getMergeId:row forColumnAtIndexPath:column];
        if(mergeId != 0){
            cellFrame.size = [self _generateMergeCellSize:row column:column mergeId:[self _getMergeId:row forColumnAtIndexPath:column]];
        }
        
        cellFrame.origin.y += cellFrame.size.height + DIST_BETWEEN_COMMENT_AND_CELL;
        if (cellFrame.origin.y + 30 > self.contentSize.height){
            cellFrame.origin.y -= cellFrame.size.height + DIST_BETWEEN_COMMENT_AND_CELL;
            cellFrame.origin.y -= 30 + DIST_BETWEEN_COMMENT_AND_CELL;
        }
       
       
        
        [self _didSelectCellForRowAtIndexPath:self._currentSelection.rowPath forColumnIndex:self._currentSelection.columnPath];
    }
    self._currentSelection = nil;
    
    
}




- (void)_touchesCancelledInCell:(CanvasView *)cell
{//this means it is actually a scroll action, not to select the cell
    
    
    allowsSelection = YES;
    
    
    if (!self._currentSelection) return;
    
    
    
    
    self._currentSelection = nil;
    
}




- (void)_addSelection:(MDSpreadViewSelection *)selection animated:(BOOL)animated notify:(BOOL)notify
{
    NSUInteger index = [_selectedCells indexOfObject:selection];
    while (index != NSNotFound) {
        [_selectedCells removeObjectAtIndex:index];
        index = [_selectedCells indexOfObject:selection];
    }
    
    [_selectedCells addObject:selection];
    
    if (!allowsMultipleSelection) {
        NSMutableArray *bucket = [[NSMutableArray alloc] initWithCapacity:_selectedCells.count];
        
        for (MDSpreadViewSelection *oldSelection in _selectedCells) {
            if (![oldSelection isEqual:selection]) {
                [bucket addObject:oldSelection];
            }
        }
        
        [self _removeSelections:bucket animated:YES notify:YES];
        bucket = nil;
        return;
    }
    
}

- (void)_removeSelection:(MDSpreadViewSelection *)selection animated:(BOOL)animated notify:(BOOL)notify
{
    if (selection) [self _removeSelections:@[selection] animated:animated notify:notify];
}

- (void)_removeSelections:(NSArray *)selections animated:(BOOL)animated notify:(BOOL)notify
{
    NSMutableSet *deselectedSet = [NSMutableSet setWithArray:_selectedCells];
    [deselectedSet intersectSet:[NSSet setWithArray:selections]];
    
    [_selectedCells removeObjectsInArray:selections];
    
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:_canvas.mapForContent.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForCornerHeaders.allCells];
    
    BOOL shouldSelect = NO;
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        shouldSelect = NO;
        for (MDSpreadViewSelection *selection in _selectedCells) {
            if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
            
            if (cell._rowPath == selection.rowPath) {
                if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
            }
            
            if (cell._columnPath  == selection.columnPath) {
                if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
                
                if (cell._rowPath == selection.rowPath && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                    shouldSelect = YES;
                }
            }
        }
        [cell setSelected:shouldSelect animated:NO];
    }
    
    if (notify) for (MDSpreadViewSelection *selection in deselectedSet) {
        [self _didDeselectCellForRowAtIndexPath:selection.rowPath forColumnIndex:selection.columnPath];
    }
    allVisibleCells = nil;
}


-(void)updateRowColumnHeader:(int)fromRow toRow:(int)toRow fromColumn:(int)fromColumn toColumn:(int)toColumn {
    for (MDSpreadViewCell * cell in _canvas.mapForRowHeaders.allCells) {
        
        if(cell._columnPath >= fromColumn && cell._columnPath <= toColumn ) {
            [cell setBackgroundColor:[UIColor grayColor]];
            [cell setNewFontColor:[UIColor whiteColor]];
        }
        else {
            [cell setBackgroundColor:[UIColor grayColor]];
            [cell setNewFontColor:[UIColor whiteColor]];
        }
        
    }
    for (MDSpreadViewCell * cell in _canvas.mapForColumnHeaders.allCells) {
        if(cell._rowPath >= fromRow && cell._rowPath <= toRow) {
            [cell setBackgroundColor:[UIColor grayColor]];
            [cell setNewFontColor:[UIColor whiteColor]];
        }
        else if(cell._rowPath < [self _numberOfRowsInSection] - 1){
            [cell setBackgroundColor:[UIColor grayColor]];
            [cell setNewFontColor:[UIColor whiteColor]];
        }
        else {
            [cell setBackgroundColor:[UIColor whiteColor]];
            [cell setNewFontColor:[UIColor grayColor]];
        }
    }
    [self.canvas setNeedsDisplay];
}

- (void)removeAllSelections:(BOOL)animated notify:(BOOL)notify
{
    
    
    NSMutableSet *deselectedSet = [NSMutableSet setWithArray:_selectedCells];
    //[deselectedSet intersectSet:[NSSet setWithArray:selections]];
    
    [_selectedCells removeAllObjects];
    
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:_canvas.mapForContent.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForColumnHeaders.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForRowHeaders.allCells];
    [allVisibleCells addObjectsFromArray:_canvas.mapForCornerHeaders.allCells];
    
    BOOL shouldSelect = NO;
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        shouldSelect = NO;
        for (MDSpreadViewSelection *selection in _selectedCells) {
            if (selection.selectionMode == MDSpreadViewSelectionModeNone) continue;
            
            if (cell._rowPath == selection.rowPath) {
                if (selection.selectionMode == MDSpreadViewSelectionModeRow ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
            }
            
            if (cell._columnPath == selection.columnPath) {
                if (selection.selectionMode == MDSpreadViewSelectionModeColumn ||
                    selection.selectionMode == MDSpreadViewSelectionModeRowAndColumn) {
                    shouldSelect = YES;
                }
                
                if (cell._rowPath  == selection.rowPath && selection.selectionMode == MDSpreadViewSelectionModeCell) {
                    shouldSelect = YES;
                }
            }
        }
        [cell setSelected:shouldSelect animated:NO];
    }

    if (notify) for (MDSpreadViewSelection *selection in deselectedSet) {
        [self _didDeselectCellForRowAtIndexPath:selection.rowPath forColumnIndex:selection.columnPath];
    }
}


- (void)selectCellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath withSelectionMode:(MDSpreadViewSelectionMode)mode animated:(BOOL)animated scrollPosition:(MDSpreadViewScrollPosition)scrollPosition
{
    [self _addSelection:[MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:mode] animated:animated notify:NO];
    
    
}

- (void)deselectCellForRowAtIndexPath:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath animated:(BOOL)animated
{
    [self _removeSelection:[MDSpreadViewSelection selectionWithRow:rowPath column:columnPath mode:MDSpreadViewSelectionModeNone] animated:animated notify:NO];
}

- (MDSpreadViewSelection *)_willHighlightCellWithSelection:(MDSpreadViewSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(spreadView:willHighlightCellWithSelection:)])
        selection = [self.delegate spreadView:self willHighlightCellWithSelection:selection];
    
    return selection;
}

- (void)_didHighlightCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
    if ([self.delegate respondsToSelector:@selector(spreadView:didHighlightCellForRowAtIndexPath:forColumnAtIndexPath:)])
        [self.delegate spreadView:self didHighlightCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}

- (MDSpreadViewSelection *)_willSelectCellForSelection:(MDSpreadViewSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(spreadView:willSelectCellWithSelection:)])
        selection = [self.delegate spreadView:self willSelectCellWithSelection:selection];
    
    return selection;
}

- (void)_didUnhighlightCellForRowAtIndexPath:(MDIndexPath *)indexPath forColumnIndex:(MDIndexPath *)columnPath
{
    if ([self.delegate respondsToSelector:@selector(spreadView:didUnhighlightCellForRowAtIndexPath:forColumnAtIndexPath:)])
        [self.delegate spreadView:self didUnhighlightCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}

- (void)_didSelectCellForRowAtIndexPath:(NSInteger)indexPath forColumnIndex:(NSInteger)columnPath
{
    if ([self.delegate respondsToSelector:@selector(spreadView:didSelectCellForRowAtIndexPath:forColumnAtIndexPath:)])
        [self.delegate spreadView:self didSelectCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}



- (MDSpreadViewSelection *)_willDeselectCellWithSelection:(MDSpreadViewSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(spreadView:willDeselectCellWithSelection:)])
        selection = [self.delegate spreadView:self willDeselectCellWithSelection:selection];
    
    return selection;
}

- (void)_didDeselectCellForRowAtIndexPath:(NSInteger)indexPath forColumnIndex:(NSInteger)columnPath
{
    if ([self.delegate respondsToSelector:@selector(spreadView:didDeselectCellForRowAtIndexPath:forColumnAtIndexPath:)])
        [self.delegate spreadView:self didDeselectCellForRowAtIndexPath:indexPath forColumnAtIndexPath:columnPath];
}

- (void)_didTouchScroll
{
    
}

#pragma mark - Sorting




- (NSArray *)getContentMap{
    
    return [_canvas.mapForContent allCells] ;
    
}

- (NSArray *)getColumnHeaders{
    
    return [_canvas.mapForColumnHeaders allCells] ;
    
}
- (NSArray *)getRowHeaders{
    
    return [_canvas.mapForRowHeaders allCells] ;
    
}

-(void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    
    if(!(self.contentSize.width <= 0 || self.contentSize.height <=0)){
        if(contentOffset.x + self.frame.size.width> self.contentSize.width){
            contentOffset.x = self.contentSize.width - self.frame.size.width;
        }
        if(contentOffset.y + self.frame.size.height > self.contentSize.height){
            contentOffset.y = self.contentSize.height - self.frame.size.height;
        }
    }
    if(contentOffset.x >= 0 && contentOffset.y >= 0){
        [super setContentOffset:contentOffset animated:animated];
    }
    else if(contentOffset.x < 0 && contentOffset.y >= 0){
        contentOffset.x = 0;
        [super setContentOffset:contentOffset animated:animated];
    }
    else if(contentOffset.x >= 0 && contentOffset.y < 0){
        contentOffset.y = 0;
        [super setContentOffset:contentOffset animated:animated];
    }
    else{
        contentOffset.y = 0;
        contentOffset.x = 0;
        [super setContentOffset:contentOffset animated:animated];
    }
    
}



- (void)touchDataValidationIndicator {
    
}




- (void)updateCurrentComment:(NSInteger)rowPath forColumnAtIndexPath:(NSInteger)columnPath{
    NSMutableSet *allVisibleCells = [NSMutableSet setWithArray:_canvas.mapForContent.allCells];
    
    
    for (MDSpreadViewCell *cell in allVisibleCells) {
        if (cell._rowPath == rowPath && cell._columnPath == columnPath) {
            cell.backgroundColor = [UIColor yellowColor];
        }
    }
    
    
    
   
    [self.canvas setNeedsDisplay];
    
}





- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated{
    [self setContentOffset:CGPointMake(rect.origin.x, rect.origin.y) animated:NO];
}








- (void)clearCanvas{
    _canvas.canvasReady = NO;
    
}

@end

