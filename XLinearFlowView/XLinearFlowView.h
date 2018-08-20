//
//  XLinearFlowView.h
//
//
//  Created by for on 2018/8/6.
//  Copyright © 2018年 for. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FlowType) {
    FlowTypeHorizontal,
};

@class XLinearFlowView, XLinearFlowCell;
@protocol XLinearFlowViewDataSource <NSObject>

/**
 根据index返回需要被显示的View

 @param flowView FlowView 实例
 @param index 索引位置
 @return 要被显示的view
 */
- (XLinearFlowCell *)flowView:(XLinearFlowView *)flowView cellForIndex:(NSUInteger)index;

/**
 流式布局中元素的数量

 @param flowView 布局实例
 @return 元素的数量
 */
- (NSUInteger)numberOfItemsInFlowView:(XLinearFlowView *)flowView;

@end

@protocol XLinearFlowViewDelegate <NSObject>
@optional
/**
 选择了某个View

 @param flowView FlowView实例
 @param index 被选择View的索引
 */
- (void)flowView:(XLinearFlowView *)flowView didSelectedItemForIndex:(NSUInteger)index;

/**
 元素从fromIndex位置移动到toIndex位置

 @param flowView 布局实例
 @param fromIndex 源位置
 @param toIndex 目标位置
 */
- (void)flowView:(XLinearFlowView *)flowView moveItemFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex;

/**
 是否可移动某个位置的元素

 @param flowView 流式布局view实例
 @param index 被移动的元素
 @return YES 可移动
 */
- (BOOL)flowView:(XLinearFlowView *)flowView canMoveItemAtIndex:(NSUInteger)index;

/**
 当即将发生位置变换时调用。表示originalIndex位置的元素即将移动到proposedIndex。可修改与propasedIndex不同的索引，拒绝这种移动

 @param flowView 实例本身
 @param originalIndex 初始位置的元素索引
 @param proposedIndex 将移动的目标位置索引
 @return 纠正后的索引，如果返回originalIndex，本次将不会发生移动
 */
- (NSUInteger)flowView:(XLinearFlowView *)flowView targetIndexForMoveFromItemAtIndex:(NSUInteger)originalIndex toProposedIndex:(NSUInteger)proposedIndex;

@end

@protocol XLinearFlowViewDelegateLayout <XLinearFlowViewDelegate>

@optional

/**
 流式布局的内边距

 @param flowView 布局实例
 @return 内边距
 */
- (UIEdgeInsets)insetsForCellsInFlowView:(XLinearFlowView *)flowView;

/**
 在索引index位置的元素Size

 @param flowView 布局实例
 @param index 元素索引
 @return 元素size
 */
- (CGSize)flowView:(XLinearFlowView *)flowView sizeForItemAtIndex:(NSUInteger)index;

/**
 同一行中，索引index指向元素的后方间距

 @param flowView 布局实例
 @param index 元素索引
 @return 间距
 */
- (CGFloat)flowView:(XLinearFlowView *)flowView minimumInteritemSpacingAtIndex:(NSUInteger)index;

/**
 换行时，行间距

 @param flowView 布局实例
 @param index 换行元素的索引
 @return 行间距
 */
- (CGFloat)flowView:(XLinearFlowView *)flowView minimumLineSpacingAtIndex:(NSUInteger)index;

@end

@interface XLinearFlowCell : UIView

@property (nonatomic, strong) UILabel *textLabel;

@end

/**
 @class XLinearFlowView
 @brief 完成子视图的线性排版
 @discussion 根据上层指定方向排版子视图
 */
@interface XLinearFlowView : UIView

@property (nonatomic, weak) id<XLinearFlowViewDelegate> delegate;
@property (nonatomic, weak) id<XLinearFlowViewDataSource> dataSource;

/**
 返回在点point位的元素索引

 @param point 指定坐标点
 @return 元素索引，point点处没有元素，返回NSNotFound
 */
- (NSUInteger)indexForItemAtPoint:(CGPoint)point;
- (XLinearFlowCell *)cellAtIndex:(NSUInteger)index;

/**
 注册Cell类。
 
 @warning reuse 暂不可用

 @param clz 类名
 @param identifier reuse id
 */
- (void)registerClass:(Class)clz forCellReuseIdentifier:(NSString *)identifier;
- (__kindof XLinearFlowCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSUInteger)index;

/**
 重新排版子视图
 */
- (void)reloadData;

// 手势拖动时调用，如LongPress. 根据手势不同的state调用下列方法
- (BOOL)beginInteractiveMovementForItemAtIndex:(NSUInteger)index; // returns NO if reordering was prevented from beginning - otherwise YES
- (void)updateInteractiveMovementTargetPosition:(CGPoint)targetPosition;
- (void)endInteractiveMovement;
- (void)cancelInteractiveMovement;

@end
