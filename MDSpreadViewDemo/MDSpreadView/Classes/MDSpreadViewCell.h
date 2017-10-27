//
//  MDSpreadViewCell.h
//  MDSpreadViewDemo
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

#import "MDIndexPath.h"

#define TRIANGLE_SIZE 8
#define PEER_FONT 11
#define SEPARATOR_SIZE (1.0/screenScale)
@class MDSpreadView, MDSortDescriptor, MDIndexPath;




@protocol ReuseableCell<NSObject>


- (void)prepareForReuse;

@end



typedef NS_ENUM(NSUInteger, MDSpreadViewCellStyle) {
    MDSpreadViewCellStyleDefault
};

typedef NS_ENUM(NSUInteger, MDSpreadViewCellSeparatorStyle) {
    MDSpreadViewCellSeparatorStyleNone,
    MDSpreadViewCellSeparatorStyleLine,
    MDSpreadViewCellSeparatorStyleSparseDot,
    MDSpreadViewCellSeparatorStyleDenseDot
};

typedef NS_ENUM(NSUInteger, MDSpreadViewCellSelectionStyle) {
    MDSpreadViewCellSelectionStyleNone,
    MDSpreadViewCellSelectionStyleDefault
};

typedef NS_ENUM(NSUInteger, BoardType)
{
    Line,//default
    Empty,
    
    SparseDot,
    DenseDot
};

typedef NS_ENUM(NSUInteger, BoardShow)
{
    Show, //default
    Hide
};

typedef NS_ENUM(NSUInteger, FontStyle)
{
    Normal, //default
    Italic,
    Bold,
    BoldItalic
};


typedef NS_ENUM(NSUInteger, VerticalAlignment)
{
    VerticalAlignmentTop = 0, //default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} ;

@interface MDSpreadViewCell : NSObject <ReuseableCell> {
@public
    NSUInteger _reuseHash;
    NSInteger _rowPath;
    NSInteger _columnPath;
    
@private
    float screenScale;
    
    
    
    NSString *reuseIdentifier;
    
    NSInteger style;
    
    id objectValue;
    
    
    
    
    
    
}

// Designated initializer.  If the cell can be reused, you must pass in a reuse identifier.  You should use the same reuse identifier for all cells of the same form.
- (instancetype)initWithStyle:(MDSpreadViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;







@property (nonatomic) MDSpreadViewCellSelectionStyle selectionStyle;
// default is MDSpreadViewCellSelectionStyleDefault.
@property (nonatomic, getter=isSelected) BOOL selected;
// set selected state (title, image, background). default is NO. animated is NO
@property (nonatomic, readonly) NSInteger style;

@property(nonatomic,readonly,copy) NSString *reuseIdentifier;

@property (nonatomic, retain) id objectValue;
@property (nonatomic) NSInteger _rowPath;
@property (nonatomic) NSInteger _columnPath;


@property (nonatomic, strong) UIColor * formerColor;
@property (nonatomic, strong) UIColor * fontColor;
@property (nonatomic, strong) UIFont * font;

@property (nonatomic)MDSpreadViewCellSeparatorStyle leftSeparatorStyle;
@property (nonatomic)MDSpreadViewCellSeparatorStyle rightSeparatorStyle;
@property (nonatomic)MDSpreadViewCellSeparatorStyle topSeparatorStyle;
@property (nonatomic)MDSpreadViewCellSeparatorStyle bottomSeparatorStyle;
@property (nonatomic, strong)UIColor * leftSeparatorColor;
@property (nonatomic, strong)UIColor * rightSeparatorColor;
@property (nonatomic, strong)UIColor * topSeparatorColor;
@property (nonatomic, strong)UIColor * bottomSeparatorColor;


@property (nonatomic, strong) NSString * text;
@property (nonatomic) BOOL strikeThrough;
@property (nonatomic) BOOL underline;
@property (nonatomic) NSTextAlignment hAlign;
@property (nonatomic) VerticalAlignment vAlign;
@property (nonatomic) BOOL hideIndicatorImage;
@property (nonatomic) BOOL hideDataValidationImage;
@property (nonatomic) BoardShow leftBoard;
@property (nonatomic) BoardShow rightBoard;
@property (nonatomic) BoardShow topBoard;
@property (nonatomic) BoardShow bottomBoard;
@property (nonatomic) BOOL hidden;
@property (nonatomic) CGRect frame;
@property (nonatomic, strong) UIColor* backgroundColor;
@property (nonatomic, strong) UIColor* connectionColor;
@property (nonatomic) BOOL needDraw;

@property (nonatomic, strong)NSMutableAttributedString *attrString;
@property (nonatomic, strong)NSMutableArray *connectionIds;

@property (nonatomic, strong)NSAttributedString *name;

-(void)setContent:(NSString*)newContent;

-(void)setBackgroundColor:(UIColor *)newColor;
-(void)setNewFontColor:(UIColor *)newColor;
-(void)setNewFont:(UIFont *)newFont;
-(void)setLeftBoardType:(BoardType)leftBoardType;
-(void)setRightBoardType:(BoardType)rightBoardType;
-(void)setTopBoardType:(BoardType)topBoardType;
-(void)setBottomBoardType:(BoardType)bottomBoardType;
-(void)setLeftBoard:(BoardShow)leftBoard;
-(void)setRightBoard:(BoardShow)rightBoard;
-(void)setTopBoard:(BoardShow)topBoard;
-(void)setBottomBoard:(BoardShow)bottomBoard;
-(void)setLeftBoardColor:(UIColor *)newColor;
-(void)setRightBoardColor:(UIColor *)newColor;
-(void)setTopBoardColor:(UIColor *)newColor;
-(void)setBottomBoardColor:(UIColor *)newColor;
-(void)setAlign:(NSTextAlignment)align;
-(void)setVAlign:(VerticalAlignment)vAlign;
-(void)setNewUnderline:(BOOL)newUnderline;
-(void)setNewStrikeThrough:(BOOL)newStrikeThrough;
-(void)setHideIndicator:(BOOL)hideIndicatorImage;
-(void)setHideDataValidation:(BOOL)hideDataValidationImage;
- (void)prepareForReuse;
- (void)setSelected:(BOOL)isSelected animated:(BOOL)animated;


// animate between regular and selected state
- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated;
// animate between regular and highlighted state

- (BOOL)hasSeparators; // returns YES. Subclasses can turn off separators completely here;

@end

