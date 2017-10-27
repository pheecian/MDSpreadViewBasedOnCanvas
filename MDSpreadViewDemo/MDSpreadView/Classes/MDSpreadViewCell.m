//
//  MDSpreadViewCell.m
//  MDSpreadViewDemo
//
//

#import "MDSpreadViewCell.h"
#import "MDSpreadView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <objc/runtime.h>


@interface MDSpreadViewCell () {
    
}

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, readwrite, weak) MDSpreadView *spreadView;




@property (nonatomic) CGRect _pureFrame;

@end

@interface MDSpreadView ()

- (BOOL)_touchesBeganInCell:(MDSpreadViewCell *)cell;
- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell;
- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell;


@end

@implementation MDSpreadViewCell

@synthesize leftSeparatorColor, rightSeparatorColor, topSeparatorColor, hideIndicatorImage, hideDataValidationImage,
bottomSeparatorColor, reuseIdentifier, formerColor, style, objectValue,  spreadView, _rowPath,  font,
_columnPath, _pureFrame,   strikeThrough, underline, fontColor,
hidden, frame, backgroundColor, needDraw, attrString, connectionIds, connectionColor, name;




- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"_MDDefaultCell"];
}

- (instancetype)initWithStyle:(MDSpreadViewCellStyle)aStyle reuseIdentifier:(NSString *)aReuseIdentifier
{
    screenScale = [[UIScreen mainScreen] scale];
    if (!aReuseIdentifier) return nil;
    if (self = [super init]) {
        
        
        self.reuseIdentifier = aReuseIdentifier;
        
        
        style = aStyle;
        _selectionStyle = MDSpreadViewCellSelectionStyleDefault;
        
        
        
        
        attrString  = [[NSMutableAttributedString alloc]init];
        
        
        
        
    }
    return self;
}


-(void)setContent:(NSString*)newContent{
    self.text = newContent;
    [attrString.mutableString setString:newContent];
}


-(void)setNewFontColor:(UIColor *)newColor{
    
    
    self.fontColor = newColor;
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:newColor
                       range:NSMakeRange(0, self.text.length)];
}

-(void)setNewFont:(UIFont *)newFont{
    
    self.font = newFont;
    [attrString addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, self.text.length)];
}

-(void)setLeftBoardType:(BoardType)leftBoardType{
    if(leftBoardType == Empty){
        _leftSeparatorStyle = MDSpreadViewCellSeparatorStyleNone;
    }
    else if(leftBoardType == Line){
        _leftSeparatorStyle = MDSpreadViewCellSeparatorStyleLine;
        
    }
    else if(leftBoardType == SparseDot){
        _leftSeparatorStyle = MDSpreadViewCellSeparatorStyleSparseDot;
        
    }
    else {
        _leftSeparatorStyle = MDSpreadViewCellSeparatorStyleDenseDot;
        
    }
    
    
    
}

-(void)setRightBoardType:(BoardType)rightBoardType{
    if(rightBoardType == Empty){
        _rightSeparatorStyle = MDSpreadViewCellSeparatorStyleNone;
    }
    else if(rightBoardType == Line){
        _rightSeparatorStyle = MDSpreadViewCellSeparatorStyleLine;
        
    }
    else if(rightBoardType == SparseDot){
        _rightSeparatorStyle = MDSpreadViewCellSeparatorStyleSparseDot;
        
    }
    else {
        _rightSeparatorStyle = MDSpreadViewCellSeparatorStyleDenseDot;
        
    }
    
    
    
}

-(void)setTopBoardType:(BoardType)topBoardType{
    if(topBoardType == Empty){
        _topSeparatorStyle = MDSpreadViewCellSeparatorStyleNone;
    }
    else if(topBoardType == Line){
        _topSeparatorStyle = MDSpreadViewCellSeparatorStyleLine;
        
    }
    else if(topBoardType == SparseDot){
        _topSeparatorStyle = MDSpreadViewCellSeparatorStyleSparseDot;
        
    }
    else {
        _topSeparatorStyle = MDSpreadViewCellSeparatorStyleDenseDot;
        
    }
    
    
    
}

-(void)setBottomBoardType:(BoardType)bottomBoardType{
    if(bottomBoardType == Empty){
        _bottomSeparatorStyle = MDSpreadViewCellSeparatorStyleNone;
    }
    else if(bottomBoardType == Line){
        _bottomSeparatorStyle = MDSpreadViewCellSeparatorStyleLine;
        
    }
    else if(bottomBoardType == SparseDot){
        _bottomSeparatorStyle = MDSpreadViewCellSeparatorStyleSparseDot;
        
    }
    else {
        _bottomSeparatorStyle = MDSpreadViewCellSeparatorStyleDenseDot;
        
    }
    
    
}






-(void)setLeftBoardColor:(UIColor *)newColor{
    self.leftSeparatorColor = newColor;
    
    
    
}

-(void)setRightBoardColor:(UIColor *)newColor{
    self.rightSeparatorColor = newColor;
    
    
    
}

-(void)setTopBoardColor:(UIColor *)newColor{
    self.topSeparatorColor = newColor;
    
    
    
}

-(void)setBottomBoardColor:(UIColor *)newColor{
    self.bottomSeparatorColor = newColor;
    
    
    
}





-(void)setNewUnderline:(BOOL)newUnderline{
    
    self.underline = newUnderline;
    if(newUnderline){
        [attrString addAttribute:NSUnderlineStyleAttributeName
                           value:@(NSUnderlineStyleSingle)
                           range:NSMakeRange(0, self.text.length)];
    } else {
        [attrString addAttribute:NSUnderlineStyleAttributeName
                           value:@(NSUnderlineStyleNone)
                           range:NSMakeRange(0, self.text.length)];
    }
}

-(void)setNewStrikeThrough:(BOOL)newStrikeThrough{
    
    self.strikeThrough = newStrikeThrough;
}

-(void)setHideIndicator:(BOOL)hideIndicator{
    
    self.hideIndicatorImage = hideIndicator;
    
}

-(void)setHideDataValidation:(BOOL)hideDataValidation{
    
    self.hideDataValidationImage = hideDataValidation;
}


-(void)setAlign:(NSTextAlignment)align{
    self.hAlign = align;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:align];
    
    
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
}



- (void)setSpreadView:(MDSpreadView *)aSpreadView
{
    spreadView = aSpreadView;
    
    
}


- (BOOL)hasSeparators
{
    return YES;
}

- (void)setReuseIdentifier:(NSString *)anIdentifier
{
    if (reuseIdentifier != anIdentifier) {
        reuseIdentifier = anIdentifier;
        
        _reuseHash = [reuseIdentifier hash];
    }
}

- (void)_handleTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        
        
    } else if (gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        
        
    }
}



- (void)tintColorDidChange
{
    
    
    
}








- (void)prepareForReuse
{
    
    self.selected = NO;
    
}



- (void)set_pureFrame:(CGRect)pureFrame
{
    _pureFrame = pureFrame;
    self.frame = _pureFrame;
}



#pragma mark - State


- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated
{
    
    
    if ((isHighlighted)) {
        
        self.backgroundColor = [UIColor yellowColor] ;
        
        
    }
    
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)isSelected animated:(BOOL)animated
{
    
    if (_selected != isSelected) {
        
        _selected = isSelected;
        
        if (( _selected)) {
            
            
            
        } else {
            self.backgroundColor = self.formerColor;
        }
        
        
    }
}

- (void)setSelectionStyle:(MDSpreadViewCellSelectionStyle)selectionStyle
{
    if (_selectionStyle != selectionStyle) {
        _selectionStyle = selectionStyle;
        
        
    }
}

#pragma mark - Value

- (void)setObjectValue:(id)anObject
{
    if (anObject != objectValue) {
        objectValue = anObject;
        
        if ([objectValue respondsToSelector:@selector(description)]) {
            self.text = [objectValue description];
        }
    }
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    
    return self.text;
}

- (NSString *)accessibilityHint
{
    return @"Double tap to show more information.";
}

- (UIAccessibilityTraits)accessibilityTraits
{
    
    return UIAccessibilityTraitNone;
}






@end

