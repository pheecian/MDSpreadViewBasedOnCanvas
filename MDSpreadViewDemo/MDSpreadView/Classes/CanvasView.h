
#import <Foundation/Foundation.h>
#import "MDSpreadViewCellMap.h"
#import "MDSpreadView.h"
#import "MDSpreadViewCell.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/CoreAnimation.h>

#define RADIUM 2.5

#define DIST 3


#define TRIANGLE_SIZE 8
#define PEER_HEIGHT 13
#define SEPARATOR_SIZE (1.0/screenScale)
@interface CanvasView : UIView <UIGestureRecognizerDelegate> {
    MDSpreadViewCellMap *mapForContent;
    MDSpreadViewCellMap *mapForColumnHeaders;
    MDSpreadViewCellMap *mapForRowHeaders;
    MDSpreadViewCellMap *mapForCornerHeaders;
    float screenScale;
    BOOL _shouldCancelTouches;
}

@property (nonatomic, strong) MDSpreadViewCellMap *mapForContent;
@property (nonatomic, strong) MDSpreadViewCellMap *mapForColumnHeaders;
@property (nonatomic, strong) MDSpreadViewCellMap *mapForRowHeaders;
@property (nonatomic, strong) MDSpreadViewCellMap *mapForCornerHeaders;
@property (nonatomic, readwrite, weak) MDSpreadView *spreadView;
@property (nonatomic) int touchRow;
@property (nonatomic) int touchColumn;
@property (nonatomic) BOOL canvasReady;
@end

