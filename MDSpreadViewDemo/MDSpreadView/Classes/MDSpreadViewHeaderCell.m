//
//  MDSpreadViewHeaderCell.m
//  MDSpreadViewDemo
//

#import "MDSpreadViewHeaderCell.h"


@interface MDSpreadViewHeaderCell () {
    UIView *_originalSelectedBackground;
}

@end

@implementation MDSpreadViewHeaderCell



- (instancetype)initWithStyle:(MDSpreadViewHeaderCellStyle)aStyle reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!reuseIdentifier) {
        if (aStyle == MDSpreadViewHeaderCellStyleCorner) {
            reuseIdentifier = @"_MDDefaultHeaderCornerCell";
        } else if (aStyle == MDSpreadViewHeaderCellStyleRow) {
            reuseIdentifier = @"_MDDefaultHeaderRowCell";
        } else if (aStyle == MDSpreadViewHeaderCellStyleColumn) {
            reuseIdentifier = @"_MDDefaultHeaderColumnCell";
        }
    }
    if (self = [super initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        if (NSClassFromString(@"UIMotionEffect")) {
            
        }
    }
    return self;
}

#pragma mark - Ovverides

- (BOOL)hasSeparators
{
    return YES;
}







- (void)tintColorDidChange
{
    
    
    
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    if (self.style == MDSpreadViewHeaderCellStyleColumn) {
        return [NSString stringWithFormat:@"%@ Row", self.text];
    } else {
        return [NSString stringWithFormat:@"%@ Column", self.text];
    }
    
    return self.text;
}

- (NSString *)accessibilityHint
{
    return @"";
    
}






@end

