//
//  XLinearFlowView.m
//
//
//  Created by 吴新庭 on 2018/8/6.
//  Copyright © 2018年 吴新庭. All rights reserved.
//

#import "XLinearFlowView.h"
#import <JKCategories/JKCategories.h>

@implementation XLinearFlowCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_textLabel];
    }
    return self;
}

@end

@interface XLinearFlowView ()

@property (nonatomic, strong) NSMutableArray<XLinearFlowCell *> *cells;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *registerClasses;

@property (nonatomic, assign) CGPoint layoutPoint;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGFloat minimumSpace;
@property (nonatomic, assign) CGFloat minimunLineSpace;
@property (nonatomic, strong) NSArray<NSValue *> *frames;

// interact
@property (nonatomic, weak) XLinearFlowCell *interactCell;
@property (nonatomic, assign) NSUInteger interactIndex;
@property (nonatomic, assign) NSUInteger proposalIndex;
@property (nonatomic, assign) CGRect interactProposalFrame;
@property (nonatomic, assign) CGPoint preInteractPosition;

// select
@property (nonatomic, strong) UITapGestureRecognizer *tapGR;

@end

@implementation XLinearFlowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addGestureRecognizer:self.tapGR];
    }
    return self;
}

- (NSUInteger)indexForItemAtPoint:(CGPoint)point {
    for (NSUInteger index = 0; index < self.cells.count; index++) {
        XLinearFlowCell *cell = [self.cells objectAtIndex:index];
        if (CGRectContainsPoint(cell.frame, point)) {
            return index;
        }
    }
    return NSNotFound;
}

- (XLinearFlowCell *)cellAtIndex:(NSUInteger)index {
    return [self.cells objectAtIndex:index];
}

- (void)registerClass:(Class)clz forCellReuseIdentifier:(NSString *)identifier {
    [self.registerClasses setObject:clz forKey:identifier];
}

- (XLinearFlowCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSUInteger)index {
    XLinearFlowCell *cell = [[[self.registerClasses objectForKey:identifier] alloc] initWithFrame:[self.frames objectAtIndex:index].CGRectValue];
    return cell;
}

- (void)reloadData {
    for (XLinearFlowCell *cell in self.cells) {
        [cell removeFromSuperview];
    }
    [self.cells removeAllObjects];
    
    self.frames = [self preLayoutFrames];
    
    NSUInteger number = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInFlowView:)]) {
        number = [self.dataSource numberOfItemsInFlowView:self];
    }
    
    CGPoint layoutPoint = CGPointMake(-1, -1);
    NSUInteger line = 0;
    for (NSUInteger i = 0; i < number; i++) {
        XLinearFlowCell *cell = [self.dataSource flowView:self cellForIndex:i];
        if (cell.frame.origin.y > layoutPoint.y) {
            line++;
            layoutPoint = cell.frame.origin;
        }
        if (self.maxLine > 0 && self.maxLine < line) {
            // 超出最大行数
            if (self.frames.count > i && self.overview) {
                XLinearFlowCell *lastCell = self.cells.lastObject;
                if (CGRectGetMaxX(lastCell.frame) + self.minimumSpace + self.overview.bounds.size.width > self.bounds.size.width - self.insets.right) {
                    // 超出右边界
                    self.overview.jk_origin = lastCell.frame.origin;
                    [lastCell removeFromSuperview];
                    [self.cells removeLastObject];
                } else {
                    self.overview.jk_origin = CGPointMake(CGRectGetMaxX(lastCell.frame) + self.minimumSpace, lastCell.jk_top);
                }
                [self addSubview:self.overview];
            }
            
            break;
        }
        
        [self addSubview:cell];
        [self.cells addObject:cell];
    }
    [self invalidateIntrinsicContentSize];
    
    if ([self.delegate respondsToSelector:@selector(flowView:didFinishLayout:)]) {
        [self.delegate flowView:self didFinishLayout:NSMakeRange(0, self.cells.count)];
    }
}

- (BOOL)beginInteractiveMovementForItemAtIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(flowView:canMoveItemAtIndex:)]) {
        if (![self.delegate flowView:self canMoveItemAtIndex:index]) {
            return NO;
        }
    }
    self.interactCell = [self.cells objectAtIndex:index];
    self.interactProposalFrame = self.interactCell.frame;
    self.interactIndex = index;
    self.proposalIndex = self.interactIndex;
    [self bringSubviewToFront:self.interactCell];
    
    self.preInteractPosition = CGPointZero;
    return YES;
}

- (void)updateInteractiveMovementTargetPosition:(CGPoint)targetPosition {
    if (!CGPointEqualToPoint(CGPointZero, self.preInteractPosition)) {
        CGRect newFrame = CGRectOffset(self.interactCell.frame, targetPosition.x - self.preInteractPosition.x, targetPosition.y - self.preInteractPosition.y);
        self.interactCell.frame = newFrame;
    }
    self.preInteractPosition = targetPosition;
    
    [self tracing];
    [self invalidateIntrinsicContentSize];
}

- (void)endInteractiveMovement {
    [UIView animateWithDuration:0.3 animations:^{
        self.interactCell.frame = self.interactProposalFrame;
    } completion:^(BOOL finished) {
        self.interactCell = nil;
    }];
}

- (void)cancelInteractiveMovement {
    [self endInteractiveMovement];
}

- (CGSize)intrinsicContentSize {
    CGFloat maxY = CGRectGetMaxY(self.cells.lastObject.frame);
    if ([self.cells.lastObject isEqual:self.interactCell]) {
        maxY = CGRectGetMaxY(self.interactProposalFrame);
    }
//    self.height = maxY;
    return CGSizeMake(self.bounds.size.width, maxY + self.insets.bottom);
}

#pragma mark - Private
- (void)tracing {
    XLinearFlowCell *conflictCell = nil;
    for (XLinearFlowCell *cell in self.cells) {
        if ([cell isEqual:self.interactCell]) continue;
        
        if ([self rect:self.interactCell.frame conflictRect:cell.frame]) {
            conflictCell = cell;
        }
    }
    if (!conflictCell) {
        return;
    }
    
    // 将拖动cell换到正确的位置
    self.proposalIndex = [self.cells indexOfObject:conflictCell];
    if (self.delegate && [self.delegate respondsToSelector:@selector(flowView:targetIndexForMoveFromItemAtIndex:toProposedIndex:)]) {
        NSUInteger targetIndex = [self.delegate flowView:self targetIndexForMoveFromItemAtIndex:self.interactIndex toProposedIndex:self.proposalIndex];
        if (targetIndex == self.interactIndex) {
            return;
        } else {
            self.proposalIndex = targetIndex;
        }
    }
    
    NSInteger step = (self.proposalIndex > self.interactIndex) ? 1:-1;
    for (NSUInteger i = self.interactIndex; step > 0 ? (i < self.proposalIndex) : (i > self.proposalIndex); i += step) {
        [self.cells exchangeObjectAtIndex:i withObjectAtIndex:i + step];
    }
    CGPoint layoutPoint = CGPointMake(self.insets.left, self.insets.top);
    for (NSUInteger i = 0; i < self.cells.count; i++) {
        XLinearFlowCell * cell = [self.cells objectAtIndex:i];
        if (CGPointEqualToPoint(cell.frame.origin, layoutPoint)) {
            // 不用换位置的cell
            layoutPoint = CGPointMake(CGRectGetMaxX(cell.frame) + self.minimumSpace, CGRectGetMinY(cell.frame));
        } else {
            if (layoutPoint.x + CGRectGetWidth(cell.frame) > self.bounds.size.width - self.insets.right) {
                XLinearFlowCell *lastCell = [self.cells objectAtIndex:i - 1];
                CGRect lastFrame = [lastCell isEqual:self.interactCell] ? self.interactProposalFrame : lastCell.frame;
                layoutPoint = CGPointMake(self.insets.left, CGRectGetMaxY(lastFrame) + self.minimunLineSpace);
            }
            
            if (CGPointEqualToPoint(layoutPoint, cell.frame.origin)) {
                // 不用换位置的cell
                layoutPoint = CGPointMake(CGRectGetMaxX(cell.frame) + self.minimumSpace, CGRectGetMinY(cell.frame));
            } else {
                CGRect newRect = CGRectOffset(cell.frame, layoutPoint.x - CGRectGetMinX(cell.frame), layoutPoint.y - CGRectGetMinY(cell.frame));
                if ([cell isEqual:self.interactCell]) {
                    self.interactProposalFrame = newRect;
                } else {
                    [UIView animateWithDuration:0.3 animations:^{
                        cell.frame = newRect;
                    }];
                }
                layoutPoint = CGPointMake(CGRectGetMaxX(newRect) + self.minimumSpace, CGRectGetMinY(newRect));
            }
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(flowView:moveItemFrom:to:)]) {
        [self.delegate flowView:self moveItemFrom:self.interactIndex to:self.proposalIndex];
    }
    self.interactIndex = self.proposalIndex;
}

- (BOOL)rect:(CGRect)rect conflictRect:(CGRect)targetRect {
    CGRect innerRect = CGRectInset(targetRect, targetRect.size.width / 4.f, targetRect.size.height / 4.f);
    return CGRectContainsPoint(innerRect, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)));
}

- (NSArray<NSValue *> *)preLayoutFrames {
    NSMutableArray<NSValue *> *mFrames = [NSMutableArray array];
    
    NSUInteger number = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInFlowView:)]) {
        number = [self.dataSource numberOfItemsInFlowView:self];
    }
    
    self.insets = UIEdgeInsetsZero;
    if (self.delegate && [self.delegate respondsToSelector:@selector(insetsForCellsInFlowView:)]) {
        self.insets = [((id<XLinearFlowViewDelegateLayout>)self.delegate) insetsForCellsInFlowView:self];
    }
    
    self.layoutPoint = CGPointMake(self.insets.left, self.insets.top);
    
    CGSize size = CGSizeZero;
    self.minimumSpace = 5;
    BOOL hasSizeMethod = self.delegate && [self.delegate respondsToSelector:@selector(flowView:sizeForItemAtIndex:)];
    BOOL hasSpaceMethod = self.delegate && [self.delegate respondsToSelector:@selector(flowView:minimumInteritemSpacingAtIndex:)];
    BOOL hasLineSpaceMethod = self.delegate && [self.delegate respondsToSelector:@selector(flowView:minimumLineSpacingAtIndex:)];
    for (NSUInteger i = 0; i < number; i++) {
        if (hasSizeMethod) {
            size = [((id<XLinearFlowViewDelegateLayout>)self.delegate) flowView:self sizeForItemAtIndex:i];
            
            // 如果比本身还长，缩短为控件长度。断言
            NSAssert(size.width <= self.bounds.size.width, @"元素的宽度不可以比控件本身还宽");
            size.width = MIN(self.bounds.size.width, size.width);
        }
        
        self.minimumSpace = (hasSpaceMethod ? [((id<XLinearFlowViewDelegateLayout>)self.delegate) flowView:self minimumInteritemSpacingAtIndex:i] : self.minimumSpace);
        self.minimunLineSpace = (hasLineSpaceMethod ? ([((id<XLinearFlowViewDelegateLayout>)self.delegate) flowView:self minimumLineSpacingAtIndex:i]) : 0);
        if (self.layoutPoint.x + size.width > self.bounds.size.width - self.insets.right) {
            self.layoutPoint = CGPointMake(self.insets.left, CGRectGetMaxY(mFrames.lastObject.CGRectValue) + self.minimunLineSpace);
        }
        CGRect frame = CGRectMake(self.layoutPoint.x, self.layoutPoint.y, size.width, size.height);
        self.layoutPoint = CGPointMake(CGRectGetMaxX(frame) + self.minimumSpace, self.layoutPoint.y);
        [mFrames addObject:[NSValue valueWithCGRect:frame]];
    }
    return mFrames;
}

#pragma mark - Action
- (void)actionHandleTap:(UITapGestureRecognizer *)gr {
    NSUInteger index = [self indexForItemAtPoint:[gr locationInView:self]];
    if (index < self.cells.count) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(flowView:didSelectedItemForIndex:)]) {
            [self.delegate flowView:self didSelectedItemForIndex:index];
        }
    }
}

#pragma mark - Get
- (NSMutableArray<XLinearFlowCell *> *)cells {
    if (!_cells) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (NSMutableDictionary<NSString *,Class> *)registerClasses {
    if (!_registerClasses) {
        _registerClasses = [NSMutableDictionary dictionary];
    }
    return _registerClasses;
}

- (UITapGestureRecognizer *)tapGR {
    if(!_tapGR) {
        _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionHandleTap:)];
    }
    return _tapGR;
}

@end
