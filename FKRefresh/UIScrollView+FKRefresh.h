//
//  UIScrollView+FKRefresh.h
//  FKRefreshDemo
//
//  Created by Andwell on 15/6/8.
//  Copyright (c) 2015年 FunkingGuo. All rights reserved.
//

#import "FKRefresh.h"

@interface UIScrollView (FKRefresh)

- (void)pullRefreshTriggerLoading:(refreshDidTriggerLoadingBlock)triggerBlock;

- (void)autoTriggerRefreshLoading;

- (void)stopRefreshLoading;

- (void)removeObserverScroll;

@end
