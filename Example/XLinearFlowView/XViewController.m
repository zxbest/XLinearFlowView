//
//  XViewController.m
//  XLineartagsView
//
//  Created by 吴新庭 on 08/20/2018.
//  Copyright (c) 2018 吴新庭. All rights reserved.
//

#import "XViewController.h"
#import <XLinearFlowView/XLinearFlowView.h>

@interface XViewController () <XLinearFlowViewDataSource, XLinearFlowViewDelegateLayout>

@property (nonatomic, strong) XLinearFlowView *tagsView;

@property (nonatomic, strong) NSMutableArray<NSString *> *strs;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *strWidths;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGR;

@end

@implementation XViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.strs = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"发给", @"大概", @"厉害个鬼", @"六", @"project", @"dependencies", @"Manipulate", @"XCollectionViewFlowLayout", @"工；朝觐在其时 嘶", @"毛"]];
    self.strWidths = [NSMutableArray array];
	
    [self.view addSubview:self.tagsView];
    [self.tagsView registerClass:XLinearFlowCell.class forCellReuseIdentifier:NSStringFromClass(XLinearFlowCell.class)];
    self.tagsView.delegate = self;
    self.tagsView.dataSource = self;
    
    self.longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.tagsView addGestureRecognizer:self.longPressGR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.strWidths removeAllObjects];
    for (NSString *str in self.strs) {
        CGFloat w = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size.width;
        [self.strWidths addObject:@(w)];
    }
    
    [self.tagsView reloadData];
}

#pragma mark - Action
- (void)handleLongPress:(UILongPressGestureRecognizer *)gr {
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            NSUInteger index = [self.tagsView indexForItemAtPoint:[gr locationInView:self.tagsView]];
            if (index) {
                [self.tagsView beginInteractiveMovementForItemAtIndex:index];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
            [self.tagsView updateInteractiveMovementTargetPosition:[gr locationInView:self.tagsView]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.tagsView endInteractiveMovement];
            break;
        case UIGestureRecognizerStateCancelled:
        default:
            [self.tagsView cancelInteractiveMovement];
            break;
    }
}

#pragma mark - Flow View
- (NSUInteger)numberOfItemsInFlowView:(XLinearFlowView *)flowView {
    return self.strs.count;
}

- (CGSize)flowView:(XLinearFlowView *)flowView sizeForItemAtIndex:(NSUInteger)index {
    return CGSizeMake(self.strWidths[index].floatValue + 40, 40);
}

- (XLinearFlowCell *)flowView:(XLinearFlowView *)flowView cellForIndex:(NSUInteger)index {
    XLinearFlowCell *cell = [flowView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(XLinearFlowCell.class) forIndex:index];
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.textLabel.text = self.strs[index];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (CGFloat)flowView:(XLinearFlowView *)flowView minimumLineSpacingAtIndex:(NSUInteger)index {
    return 10;
}

- (CGFloat)flowView:(XLinearFlowView *)flowView minimumInteritemSpacingAtIndex:(NSUInteger)index {
    return 10;
}

- (UIEdgeInsets)insetsForCellsInFlowView:(XLinearFlowView *)flowView {
    return UIEdgeInsetsMake(40, 10, 10, 10);
}

- (void)flowView:(XLinearFlowView *)flowView didSelectedItemForIndex:(NSUInteger)index {
    [flowView reloadData];
}

- (void)flowView:(XLinearFlowView *)flowView moveItemFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    NSString *from = [self.strs objectAtIndex:fromIndex];
    [self.strs removeObjectAtIndex:fromIndex];
    [self.strs insertObject:from atIndex:toIndex];
}

#pragma mark - Get
- (XLinearFlowView *)tagsView {
    if (!_tagsView) {
        _tagsView = [[XLinearFlowView alloc] initWithFrame:self.view.bounds];
    }
    return _tagsView;
}

@end
