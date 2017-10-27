//
//  MDSpreadViewHeaderCell.h
//  MDSpreadViewDemo
//
//

#import "MDSpreadViewCell.h"
#import "MDSpreadView.h"

typedef enum {
    MDSpreadViewHeaderCellStyleCorner,
    MDSpreadViewHeaderCellStyleRow,
    MDSpreadViewHeaderCellStyleColumn
} MDSpreadViewHeaderCellStyle;

@interface MDSpreadViewHeaderCell : MDSpreadViewCell

- (id)initWithStyle:(MDSpreadViewHeaderCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;




@end

