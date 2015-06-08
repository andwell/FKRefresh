//
//  UIScrollView+FKRefresh.m
//  FKRefreshDemo
//
//  Created by Andwell on 15/6/8.
//  Copyright (c) 2015年 FunkingGuo. All rights reserved.
//

#import "UIScrollView+FKRefresh.h"
#import <objc/runtime.h>

NSString *const PullRefreshViewKey = @"FKRefreshRefreshView";

@implementation UIScrollView (FKRefresh)

- (void)pullRefreshTriggerLoading:(refreshDidTriggerLoadingBlock)triggerBlock
{
    FKRefresh *freshView = objc_getAssociatedObject(self, &PullRefreshViewKey);
    if (!freshView) {
        freshView = [[FKRefresh alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.frame), CGRectGetWidth(self.bounds), PULLMAXOFFSET) scrollView:self triggerBlock:triggerBlock];
        [self addObserverScroll];//add observer
        [self.superview insertSubview:freshView belowSubview:self];
        objc_setAssociatedObject(self, &PullRefreshViewKey, freshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else {//refresh block
        freshView.triggerBlock = triggerBlock;
    }
}

- (void)autoTriggerRefreshLoading
{
    FKRefresh *freshView = objc_getAssociatedObject(self, &PullRefreshViewKey);
    [freshView autoRotateAnimate];
}

- (void)stopRefreshLoading
{
    FKRefresh *freshView = objc_getAssociatedObject(self, &PullRefreshViewKey);
    [freshView stopRotateAnimate];
}

- (void)addObserverScroll
{
    [self addObserver:self
           forKeyPath:@"contentOffset"
              options:NSKeyValueObservingOptionNew
              context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && [object isEqual:self]) {
        FKRefresh *freshView = objc_getAssociatedObject(self, &PullRefreshViewKey);
        [freshView handleRotateAnimate:-1*self.contentOffset.y];
    }
}

- (void)removeObserverScroll
{
    @try {
        [self removeObserver:self forKeyPath:@"contentOffset"];
    } @catch (NSException *exception) {
    }
    objc_removeAssociatedObjects(self);
}

@end
