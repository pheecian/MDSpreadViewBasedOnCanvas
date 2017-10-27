//
//  CanvasView.m
//  company-ess-ios
//
//  Created by worksap on 10/10/16.
//  Copyright © 2016 worksap. All rights reserved.
//

#import "CanvasView.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface MDSpreadViewCellTapGestureRecognizer : UIGestureRecognizer {
    CGPoint touchDown;
}
@property CGPoint touchDown;
@end


@implementation MDSpreadViewCellTapGestureRecognizer


@synthesize touchDown;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.state = UIGestureRecognizerStateBegan;
    touchDown = [[touches anyObject] locationInView:self.view];
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint newPoint = [[touches anyObject] locationInView:self.view];
    if (fabs(touchDown.x - newPoint.x) > 5 || fabs(touchDown.y - newPoint.y) > 5) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

@end

@interface CanvasView () {
    CGLayerRef stripeLayer;
    CGLayerRef cacheLayer;
    CGContextRef myLayerContext1;
    CGContextRef cacheContext;
    int size;
    
    CGPoint positionOffset;
}



@property (nonatomic, readonly) MDSpreadViewCellTapGestureRecognizer *_tapGesture;



@end

@interface MDSpreadView ()

- (BOOL)_touchesBeganInCell:(CanvasView *)cell;
- (void)_touchesEndedInCell:(CanvasView *)cell;
- (void)_touchesCancelledInCell:(CanvasView *)cell;


@end

@implementation CanvasView
@synthesize mapForContent, mapForRowHeaders, mapForColumnHeaders, mapForCornerHeaders, _tapGesture, spreadView,
touchRow, touchColumn, canvasReady;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        mapForContent = [[MDSpreadViewCellMap alloc] init];
        mapForColumnHeaders = [[MDSpreadViewCellMap alloc] init];
        mapForRowHeaders = [[MDSpreadViewCellMap alloc] init];
        mapForCornerHeaders = [[MDSpreadViewCellMap alloc] init];
        screenScale = [[UIScreen mainScreen] scale];
        _tapGesture = [[MDSpreadViewCellTapGestureRecognizer alloc] init];
        _tapGesture.cancelsTouchesInView = NO;
        _tapGesture.delaysTouchesEnded = NO;
        _tapGesture.delegate = self;
        [_tapGesture addTarget:self action:@selector(_handleTap:)];
        [self addGestureRecognizer:_tapGesture];
        int a  = [UIScreen mainScreen].bounds.size.width;
        int b= [UIScreen mainScreen].bounds.size.height;
        size = a > b ? a : b;
        canvasReady = NO;
    }
    return self;
}

- (void)rowOfTouch:(float)ypos xpos:(float)xpos{
    for(MDSpreadViewCell * cell in mapForContent.allCells){
        if(cell.frame.origin.y  <= ypos && cell.frame.origin.y + cell.frame.size.height >= ypos && cell.frame.origin.x  <= xpos && cell.frame.origin.x + cell.frame.size.width >= xpos){
            touchRow = (int)cell._rowPath;
            touchColumn = (int)cell._columnPath;
            break;
        }
    }
    
    for(MDSpreadViewCell * cell in mapForRowHeaders.allCells){
        if(cell.frame.origin.y  <= ypos && cell.frame.origin.y + cell.frame.size.height >= ypos && cell.frame.origin.x  <= xpos && cell.frame.origin.x + cell.frame.size.width >= xpos){
            touchRow = (int)cell._rowPath;
            touchColumn = (int)cell._columnPath;
            break;
        }
    }
    
    for(MDSpreadViewCell * cell in mapForColumnHeaders.allCells){
        if(cell.frame.origin.y  <= ypos && cell.frame.origin.y + cell.frame.size.height >= ypos && cell.frame.origin.x  <= xpos && cell.frame.origin.x + cell.frame.size.width >= xpos){
            touchRow = (int)cell._rowPath;
            touchColumn = (int)cell._columnPath;
            break;
        }
    }
    
    for(MDSpreadViewCell * cell in mapForCornerHeaders.allCells){
        if(cell.frame.origin.y  <= ypos && cell.frame.origin.y + cell.frame.size.height >= ypos && cell.frame.origin.x  <= xpos && cell.frame.origin.x + cell.frame.size.width >= xpos){
            touchRow = (int)cell._rowPath;
            touchColumn = (int)cell._columnPath;
            break;
        }
    }
    
    
}


- (void)_handleTap:(MDSpreadViewCellTapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [self rowOfTouch:gesture.touchDown.y + self.frame.origin.y xpos:gesture.touchDown.x + self.frame.origin.x];
        //touchColumn = [self columnOfTouch:gesture.touchDown.x + self.frame.origin.x];
        //NSLog(@"%f %f %d %d",gesture.touchDown.x, gesture.touchDown.y, row, column);
        _shouldCancelTouches = ![spreadView _touchesBeganInCell:self];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (!_shouldCancelTouches){
            
            [spreadView _touchesEndedInCell:self];
        }
        
        _shouldCancelTouches = NO;
    } else if (gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        if (!_shouldCancelTouches){
            
            [spreadView _touchesCancelledInCell:self];
        }
        _shouldCancelTouches = NO;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect {
    NSArray * contentcell = mapForContent.allCells;
    NSArray * leftercell = mapForColumnHeaders.allCells;
    NSArray * headercell = mapForRowHeaders.allCells;
    NSArray * cornercell = mapForCornerHeaders.allCells;
    MDSpreadViewCell * headerFirstCell = [headercell firstObject];
    MDSpreadViewCell * lefterFirstCell = [leftercell firstObject];
    
    if(!canvasReady){
        CGFloat scale = self.contentScaleFactor;
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if(stripeLayer == NULL){
            
            CGRect bounds = CGRectMake(0, 0, size * scale, size * scale);
            stripeLayer = CGLayerCreateWithContext (context, // 11
                                                    bounds.size, NULL);
            cacheLayer = CGLayerCreateWithContext(context, bounds.size, NULL);
            cacheContext = CGLayerGetContext(cacheLayer);
            myLayerContext1 = CGLayerGetContext (stripeLayer);
            
            
        } else {
            [self clearCanvas:myLayerContext1 rectSize:size * scale];
        }
        
        
        CGContextSaveGState(myLayerContext1);
        CGContextScaleCTM(myLayerContext1, scale, scale);
        
        
        for(MDSpreadViewCell * cell in contentcell){
            [self drawCell:cell ctx:myLayerContext1];
        }
        
        
        
        
        for(MDSpreadViewCell * cell in leftercell){
            [self drawLefterCellForce:cell ctx:myLayerContext1];
        }
        for(MDSpreadViewCell * cell in headercell){
            [self drawHeaderCellForce:cell ctx:myLayerContext1];
        }
        
        for(MDSpreadViewCell * cell in cornercell){
            [self drawCell:cell ctx:myLayerContext1];
        }
        
        
        
        
        CGRect bounds2 = CGRectMake(0, 0, size, size);
        CGContextDrawLayerInRect(context, bounds2, stripeLayer);
        CGContextRestoreGState(myLayerContext1);
        
        canvasReady = YES;
        positionOffset = self.frame.origin;
        
    }
    else {
        //CFAbsoluteTime frameTime = CFAbsoluteTimeGetCurrent();
        CGFloat scale = self.contentScaleFactor;
        float deltaX = (self.frame.origin.x - positionOffset.x) * scale;
        float deltaY = (self.frame.origin.y - positionOffset.y) * scale;
        CGRect bounds = CGRectMake(-deltaX, -deltaY, size * scale, size * scale);
        CGContextDrawLayerInRect(cacheContext, CGRectMake(0, 0, size * scale, size * scale), stripeLayer);
        CGContextDrawLayerInRect(myLayerContext1, bounds, cacheLayer);
        CGContextSaveGState(myLayerContext1);
        CGContextScaleCTM(myLayerContext1, scale, scale);
        
        //NSLog(@"0Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
        for(MDSpreadViewCell * cell in contentcell){
            [self drawCellTry:cell ctx:myLayerContext1 headercount:headercell.count leftercount:leftercell.count headerFirstCell:headerFirstCell lefterFirstCell:lefterFirstCell];
        }
        
        
        
        
        
        //NSLog(@"4Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
        
        for(MDSpreadViewCell * cell in leftercell){
            [self drawLefterCellForce:cell ctx:myLayerContext1];
        }
        //NSLog(@"2Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
        for(MDSpreadViewCell * cell in headercell){
            [self drawHeaderCellForce:cell ctx:myLayerContext1];
        }
        //NSLog(@"3Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
        for(MDSpreadViewCell * cell in cornercell){
            [self drawCell:cell ctx:myLayerContext1];
        }
        CGRect bounds2 = CGRectMake(0, 0, size, size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawLayerInRect(context, bounds2, stripeLayer);
        CGContextRestoreGState(myLayerContext1);
        //NSLog(@"1Frame time: %.1fms", (CFAbsoluteTimeGetCurrent() - frameTime)*1000.);
        positionOffset = self.frame.origin;
        
    }
    
}

-(void)drawCellTry:(MDSpreadViewCell *)cell ctx:(CGContextRef)ctx headercount:(NSUInteger)headercount leftercount:(NSUInteger)leftercount headerFirstCell:(MDSpreadViewCell *)headerFirstCell lefterFirstCell:(MDSpreadViewCell *)lefterFirstCell{
    if(cell.needDraw){
        [self drawCell:cell ctx:ctx];
        cell.needDraw = NO;
        
    }
    else {
        if(self.frame.origin.x > positionOffset.x) {
            if(cell.frame.origin.x + cell.frame.size.width > positionOffset.x + self.frame.size.width){
                [self drawCell:cell ctx:ctx];
                
            }
        } else {
            if(leftercount > 0){
                MDSpreadViewCell * column = lefterFirstCell;
                
                if(cell.frame.origin.x <= column.frame.origin.x + column.frame.size.width - self.frame.origin.x + positionOffset.x){
                    [self drawCell:cell ctx:ctx];
                    
                }
                
            } else {
                if(cell.frame.origin.x <= positionOffset.x){
                    [self drawCell:cell ctx:ctx];
                    
                }
            }
        }
        
        if (self.frame.origin.y > positionOffset.y){
            if(cell.frame.origin.y + cell.frame.size.height > positionOffset.y + self.frame.size.height){
                [self drawCell:cell ctx:ctx];
                
            }
        } else {
            if(headercount > 0){
                MDSpreadViewCell * row = headerFirstCell;
                
                if(cell.frame.origin.y <= row.frame.origin.y + row.frame.size.height - self.frame.origin.y + positionOffset.y){
                    [self drawCell:cell ctx:ctx];
                    
                }
            } else {
                if(cell.frame.origin.y <= positionOffset.y){
                    [self drawCell:cell ctx:ctx];
                    
                }
            }
        }
    }
}



- (void)clearCanvas:(CGContextRef)ctx rectSize:(float)rectSize{
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, rectSize, 0);
    CGContextAddLineToPoint(ctx, rectSize, rectSize);
    CGContextAddLineToPoint(ctx, 0, rectSize);
    CGContextAddLineToPoint(ctx, 0, 0);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillPath(ctx);
}

-(void)drawCellPeerSelect:(MDSpreadViewCell *)cell ctx:(CGContextRef)ctx{
    
    
    
    
    
    CGContextSetFillColorWithColor(ctx, cell.backgroundColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y, cell.frame.size.width, cell.frame.size.height));
    
    
    
    
    
    
    CGContextSetLineWidth(ctx, SEPARATOR_SIZE * 3);
    
    CGContextSetStrokeColorWithColor(ctx, cell.connectionColor.CGColor);
    CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
    CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
    CGContextStrokePath(ctx);
    CGContextSetLineDash(ctx, 0, NULL, 0);
    
    
    CGContextSetStrokeColorWithColor(ctx, cell.connectionColor.CGColor);
    CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
    CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
    CGContextStrokePath(ctx);
    CGContextSetLineDash(ctx, 0, NULL, 0);
    
    
    CGContextSetStrokeColorWithColor(ctx, cell.connectionColor.CGColor);
    CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
    CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
    CGContextStrokePath(ctx);
    CGContextSetLineDash(ctx, 0, NULL, 0);
    
    CGContextSetStrokeColorWithColor(ctx, cell.connectionColor.CGColor);
    CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
    CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
    
    
    CGContextStrokePath(ctx);
    CGContextSetLineDash(ctx, 0, NULL, 0);
    
    
    
    CGContextSaveGState(ctx);
    //CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    
    
    
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    
    
    CFMutableAttributedStringRef attrString = (__bridge CFMutableAttributedStringRef)cell.attrString;
    long length = (long)CFAttributedStringGetLength(attrString);
    
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString(attrString);
    
    
    //CFRelease(attrString);
    
    CGSize constraint = CGSizeMake(cell.frame.size.width, cell.frame.size.height);
    CFRange range;
    
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, length), NULL, constraint, &range);
    //NSLog(@"coretext %@ height %f constraint %f", cell.text, coreTextSize.height, cell.frame.size.height);
    
    float ypos;
    float delta;
    switch(cell.vAlign){
        case VerticalAlignmentTop:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height;
            delta = 0;
            break;
        case VerticalAlignmentBottom:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height);
            delta = (cell.frame.size.height - coreTextSize.height);
            break;
        case VerticalAlignmentMiddle:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height)/2;
            delta = (cell.frame.size.height - coreTextSize.height)/2;
            break;
            
    }
    
    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();
    
    // In this simple example, initialize a rectangular path.
    CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, ypos, cell.frame.size.width, cell.frame.size.height);
    //CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, -25, cell.frame.size.width, cell.frame.size.height);
    CGPathAddRect(path, NULL, bounds);
    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, 0), path, NULL);
    NSMutableArray *linesToDraw = [[NSMutableArray alloc] init];
    if(cell.strikeThrough){
        
        
        
        
        CFArrayRef lines = CTFrameGetLines(frame);
        CGPoint *origins = malloc(sizeof(CGPoint)*[(__bridge NSArray *)lines count]);
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
        NSInteger lineIndex = 0;
        for(id oneline in (__bridge NSArray *)lines){
            CFArrayRef runs = CTLineGetGlyphRuns((CTLineRef)oneline);
            CGRect lineBounds = CTLineGetImageBounds((CTLineRef)oneline, NULL);
            lineBounds.origin.x += origins[lineIndex].x;
            lineBounds.origin.y += origins[lineIndex].y;
            lineIndex++;
            CGFloat offset = 0;
            NSArray *runsref = (__bridge NSArray*)runs;
            if(runsref.count > 0){
                CTRunRef onerun = (__bridge CTRunRef)[runsref firstObject];
                CGFloat ascent = 0;
                CGFloat descent = 0;
                CTRunGetTypographicBounds((CTRunRef)onerun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                
                for(id onerun in (__bridge NSArray*)runs){
                    
                    CGFloat width = CTRunGetTypographicBounds((CTRunRef)onerun, CFRangeMake(0, 0), NULL, NULL, NULL);
                    
                    CGRect bounds = CGRectMake(lineBounds.origin.x + offset, lineBounds.origin.y, width, ascent + descent);
                    if(bounds.origin.x + bounds.size.width > CGRectGetMaxX(lineBounds)){
                        bounds.size.width = CGRectGetMaxX(lineBounds) - bounds.origin.x;
                        
                    }
                    //CGContextSetStrokeColorWithColor(ctx, cell.fontColor.CGColor);
                    CGFloat y = roundf(bounds.origin.y + bounds.size.height/2.0);
                    //CGContextMoveToPoint(ctx, bounds.origin.x, y);
                    //CGContextAddLineToPoint(ctx, bounds.origin.x + bounds.size.width, y);
                    [linesToDraw addObject:[NSValue valueWithCGRect:CGRectMake( bounds.origin.x, y, bounds.origin.x + bounds.size.width, y)]];
                    //CGContextStrokePath(ctx);
                    
                    
                    offset += width;
                }
            }
        }
        free(origins);
    }
    
    
    
    // Draw the specified frame in the given context.
    CTFrameDraw(frame, ctx);
    
    // Release the objects we used.
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    //CFRelease(font);
    CGContextRestoreGState(ctx);
    if(cell.strikeThrough){
        CGContextSetLineWidth(ctx, cell.font.pointSize / 20);
        CGContextSetStrokeColorWithColor(ctx, cell.fontColor.CGColor);
        for(int a = 0 ; a < [linesToDraw count]; a++){
            //NSLog(@"%@", [linesToDraw objectAtIndex:a]);
            CGRect rect = [[linesToDraw objectAtIndex:a] CGRectValue];
            CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + rect.origin.x, cell.frame.origin.y - self.frame.origin.y + rect.origin.y - delta);
            CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + rect.size.width, cell.frame.origin.y - self.frame.origin.y + rect.size.height - delta);
            CGContextStrokePath(ctx);
        }
        
    }
    [linesToDraw removeAllObjects];
    
    
    CFAttributedStringRef nameAttrString = (__bridge CFAttributedStringRef)cell.name;
    length = (long)CFAttributedStringGetLength(nameAttrString);
    
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef nameFramesetter =
    CTFramesetterCreateWithAttributedString(nameAttrString);
    
    constraint = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    
    coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(nameFramesetter, CFRangeMake(0, length), NULL, constraint, &range);
    //NSLog(@"coretext %@ height %f constraint %f", cell.text, coreTextSize.height, cell.frame.size.height);
    
    
    if(cell.frame.size.width > coreTextSize.width + 4 && cell.frame.size.height > PEER_HEIGHT) {
        CGContextSetFillColorWithColor(ctx, cell.connectionColor.CGColor);
        CGContextFillRect(ctx, CGRectMake(cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - coreTextSize.width - 4, cell.frame.origin.y - self.frame.origin.y, coreTextSize.width + 4, PEER_HEIGHT));
        
        CGContextSaveGState(ctx);
        //CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
        
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        
        ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height;////////////////////////////?
        delta = 0;
        
        // Create a path which bounds the area where you will be drawing text.
        // The path need not be rectangular.
        CGMutablePathRef path = CGPathCreateMutable();
        
        // In this simple example, initialize a rectangular path.
        CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - coreTextSize.width - 2, ypos, coreTextSize.width, cell.frame.size.height);
        
        CGPathAddRect(path, NULL, bounds);
        // Create a frame.
        CTFrameRef frame = CTFramesetterCreateFrame(nameFramesetter,
                                                    CFRangeMake(0, 0), path, NULL);
        
        // Draw the specified frame in the given context.
        CTFrameDraw(frame, ctx);
        
        // Release the objects we used.
        CFRelease(frame);
        CFRelease(path);
        CFRelease(nameFramesetter);
        //CFRelease(font);
        CGContextRestoreGState(ctx);
    }
    
    
    
    
    
}

-(void)drawCell:(MDSpreadViewCell *)cell ctx:(CGContextRef)ctx{
    
    CGContextSetFillColorWithColor(ctx, cell.backgroundColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y, cell.frame.size.width, cell.frame.size.height));
    
    
    
    
    CGContextSetLineWidth(ctx, SEPARATOR_SIZE);
    if(cell.topBoard == Show){
        switch (cell.topSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
        
    }
    if(cell.bottomBoard == Show){
        switch (cell.bottomSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
        }
        
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    if(cell.leftBoard == Show){
        switch (cell.leftSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    if(cell.rightBoard == Show){
        switch (cell.rightSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    
    
    CGContextSaveGState(ctx);
    //CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    
    
    
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    
    
    CFMutableAttributedStringRef attrString = (__bridge CFMutableAttributedStringRef)cell.attrString;
    long length = (long)CFAttributedStringGetLength(attrString);
    
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString(attrString);
    
    
    //CFRelease(attrString);
    
    CGSize constraint = CGSizeMake(cell.frame.size.width, cell.frame.size.height);
    CFRange range;
    
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, length), NULL, constraint, &range);
    //NSLog(@"coretext %@ height %f constraint %f", cell.text, coreTextSize.height, cell.frame.size.height);
    
    float ypos;
    float delta;
    switch(cell.vAlign){
        case VerticalAlignmentTop:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height;
            delta = 0;
            break;
        case VerticalAlignmentBottom:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height);
            delta = (cell.frame.size.height - coreTextSize.height);
            break;
        case VerticalAlignmentMiddle:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height)/2;
            delta = (cell.frame.size.height - coreTextSize.height)/2;
            break;
            
    }
    
    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();
    
    // In this simple example, initialize a rectangular path.
    CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, ypos, cell.frame.size.width, cell.frame.size.height);
    //CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, -25, cell.frame.size.width, cell.frame.size.height);
    CGPathAddRect(path, NULL, bounds);
    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, 0), path, NULL);
    NSMutableArray *linesToDraw = [[NSMutableArray alloc] init];
    if(cell.strikeThrough){
        
        
        
        
        CFArrayRef lines = CTFrameGetLines(frame);
        CGPoint *origins = malloc(sizeof(CGPoint)*[(__bridge NSArray *)lines count]);
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
        NSInteger lineIndex = 0;
        for(id oneline in (__bridge NSArray *)lines){
            CFArrayRef runs = CTLineGetGlyphRuns((CTLineRef)oneline);
            CGRect lineBounds = CTLineGetImageBounds((CTLineRef)oneline, NULL);
            lineBounds.origin.x += origins[lineIndex].x;
            lineBounds.origin.y += origins[lineIndex].y;
            lineIndex++;
            CGFloat offset = 0;
            NSArray *runsref = (__bridge NSArray*)runs;
            if(runsref.count > 0){
                CTRunRef onerun = (__bridge CTRunRef)[runsref firstObject];
                CGFloat ascent = 0;
                CGFloat descent = 0;
                CTRunGetTypographicBounds((CTRunRef)onerun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                
                for(id onerun in (__bridge NSArray*)runs){
                    
                    CGFloat width = CTRunGetTypographicBounds((CTRunRef)onerun, CFRangeMake(0, 0), NULL, NULL, NULL);
                    
                    CGRect bounds = CGRectMake(lineBounds.origin.x + offset, lineBounds.origin.y, width, ascent + descent);
                    if(bounds.origin.x + bounds.size.width > CGRectGetMaxX(lineBounds)){
                        bounds.size.width = CGRectGetMaxX(lineBounds) - bounds.origin.x;
                        
                    }
                    //CGContextSetStrokeColorWithColor(ctx, cell.fontColor.CGColor);
                    CGFloat y = roundf(bounds.origin.y + bounds.size.height/2.0);
                    //CGContextMoveToPoint(ctx, bounds.origin.x, y);
                    //CGContextAddLineToPoint(ctx, bounds.origin.x + bounds.size.width, y);
                    [linesToDraw addObject:[NSValue valueWithCGRect:CGRectMake( bounds.origin.x, y, bounds.origin.x + bounds.size.width, y)]];
                    //CGContextStrokePath(ctx);
                    
                    
                    offset += width;
                }
            }
        }
        free(origins);
    }
    
    
    
    // Draw the specified frame in the given context.
    CTFrameDraw(frame, ctx);
    
    // Release the objects we used.
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    //CFRelease(font);
    CGContextRestoreGState(ctx);
    if(cell.strikeThrough){
        CGContextSetLineWidth(ctx, cell.font.pointSize / 20);
        CGContextSetStrokeColorWithColor(ctx, cell.fontColor.CGColor);
        for(int a = 0 ; a < [linesToDraw count]; a++){
            //NSLog(@"%@", [linesToDraw objectAtIndex:a]);
            CGRect rect = [[linesToDraw objectAtIndex:a] CGRectValue];
            CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + rect.origin.x, cell.frame.origin.y - self.frame.origin.y + rect.origin.y - delta);
            CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + rect.size.width, cell.frame.origin.y - self.frame.origin.y + rect.size.height - delta);
            CGContextStrokePath(ctx);
        }
        
    }
    [linesToDraw removeAllObjects];
    
    
    
    
}


-(void)drawLefterCellForce:(MDSpreadViewCell *)cell ctx:(CGContextRef)ctx{
    
    
    
    
    
    CGContextSetFillColorWithColor(ctx, cell.backgroundColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y, cell.frame.size.width, cell.frame.size.height));
    
    
    
    CGContextSetLineWidth(ctx, SEPARATOR_SIZE);
    if(cell.topBoard == Show){
        switch (cell.topSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
        
    }
    if(cell.bottomBoard == Show){
        switch (cell.bottomSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
        }
        
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    if(cell.leftBoard == Show){
        switch (cell.leftSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    if(cell.rightBoard == Show){
        switch (cell.rightSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    
    
    CGContextSaveGState(ctx);
    //CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    
    
    
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    
    
    CFMutableAttributedStringRef attrString = (__bridge CFMutableAttributedStringRef)cell.attrString;
    long length = (long)CFAttributedStringGetLength(attrString);
    
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString(attrString);
    
    
    //CFRelease(attrString);
    
    CGSize constraint = CGSizeMake(cell.frame.size.width, cell.frame.size.height);
    CFRange range;
    
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, length), NULL, constraint, &range);
    //NSLog(@"coretext %@ height %f constraint %f", cell.text, coreTextSize.height, cell.frame.size.height);
    
    float ypos;
    float delta;
    switch(cell.vAlign){
        case VerticalAlignmentTop:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height;
            delta = 0;
            break;
        case VerticalAlignmentBottom:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height);
            delta = (cell.frame.size.height - coreTextSize.height);
            break;
        case VerticalAlignmentMiddle:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height)/2;
            delta = (cell.frame.size.height - coreTextSize.height)/2;
            break;
            
    }
    
    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();
    
    // In this simple example, initialize a rectangular path.
    CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, ypos, cell.frame.size.width, cell.frame.size.height);
    //CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, -25, cell.frame.size.width, cell.frame.size.height);
    CGPathAddRect(path, NULL, bounds);
    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, 0), path, NULL);
    
    
    
    
    // Draw the specified frame in the given context.
    CTFrameDraw(frame, ctx);
    
    // Release the objects we used.
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    //CFRelease(font);
    CGContextRestoreGState(ctx);
    
    
    
    
    
    
}

-(void)drawHeaderCellForce:(MDSpreadViewCell *)cell ctx:(CGContextRef)ctx{
    
    
    
    
    
    CGContextSetFillColorWithColor(ctx, cell.backgroundColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y, cell.frame.size.width, cell.frame.size.height));
    
    
    
    CGContextSetLineWidth(ctx, SEPARATOR_SIZE);
    if(cell.topBoard == Show){
        switch (cell.topSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.topSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
        
    }
    if(cell.bottomBoard == Show){
        switch (cell.bottomSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.bottomSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height - SEPARATOR_SIZE);
                break;
        }
        
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    if(cell.leftBoard == Show){
        switch (cell.leftSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.leftSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    if(cell.rightBoard == Show){
        switch (cell.rightSeparatorStyle){
            case MDSpreadViewCellSeparatorStyleNone:
                break;
            case MDSpreadViewCellSeparatorStyleLine:
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleDenseDot:
                
                CGContextSetLineDash(ctx, 0, (CGFloat []){3, 3}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
            case MDSpreadViewCellSeparatorStyleSparseDot:
                CGContextSetLineDash(ctx, 0, (CGFloat []){5, 5}, 2);
                CGContextSetStrokeColorWithColor(ctx, cell.rightSeparatorColor.CGColor);
                CGContextMoveToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y);
                CGContextAddLineToPoint(ctx, cell.frame.origin.x - self.frame.origin.x + cell.frame.size.width - SEPARATOR_SIZE, cell.frame.origin.y - self.frame.origin.y + cell.frame.size.height);
                break;
        }
        
        
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);
    }
    
    
    CGContextSaveGState(ctx);
    //CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    
    
    
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    
    
    CFMutableAttributedStringRef attrString = (__bridge CFMutableAttributedStringRef)cell.attrString;
    long length = (long)CFAttributedStringGetLength(attrString);
    
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString(attrString);
    
    
    //CFRelease(attrString);
    
    CGSize constraint = CGSizeMake(cell.frame.size.width, cell.frame.size.height);
    CFRange range;
    
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, length), NULL, constraint, &range);
    //NSLog(@"coretext %@ height %f constraint %f", cell.text, coreTextSize.height, cell.frame.size.height);
    
    float ypos;
    float delta;
    switch(cell.vAlign){
        case VerticalAlignmentTop:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height;
            delta = 0;
            break;
        case VerticalAlignmentBottom:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height);
            delta = (cell.frame.size.height - coreTextSize.height);
            break;
        case VerticalAlignmentMiddle:
            ypos = -cell.frame.origin.y + self.frame.origin.y - cell.frame.size.height - (cell.frame.size.height - coreTextSize.height)/2;
            delta = (cell.frame.size.height - coreTextSize.height)/2;
            break;
            
    }
    
    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();
    
    // In this simple example, initialize a rectangular path.
    CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, ypos, cell.frame.size.width, cell.frame.size.height);
    //CGRect bounds = CGRectMake(cell.frame.origin.x - self.frame.origin.x, -25, cell.frame.size.width, cell.frame.size.height);
    CGPathAddRect(path, NULL, bounds);
    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, 0), path, NULL);
    
    
    
    
    // Draw the specified frame in the given context.
    CTFrameDraw(frame, ctx);
    
    // Release the objects we used.
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    //CFRelease(font);
    CGContextRestoreGState(ctx);
    
    
    
    
    
    
}




- (void)setFrame:(CGRect)frame{
    //NSLog(@"comment indicator %f %f", frame.origin.x, frame.origin.y);
    [super setFrame:frame];
    [self setNeedsDisplay];
    
    
}


- (void)setSpreadView:(MDSpreadView *)aSpreadView
{
    spreadView = aSpreadView;
    
    
}
- (void) dealloc
{
    CGLayerRelease(stripeLayer);
    
}

@end

