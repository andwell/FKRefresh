//
//  FKRefresh.h
//  FKRefreshDemo
//
//  Created by Andwell on 15/6/8.
//  Copyright (c) 2015年 FunkingGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PULLMAXOFFSET 80.

typedef NS_ENUM(NSInteger, VIPullRefreshState) {
    VIPullRefreshNormal = 0,                
    VIPullRefreshPulling = 1 << 0,
    VIPullRefreshPullWillLoading = 1 << 1,
    VIPullRefreshLoading = 1 << 2,
    VIPullRefreshFinishLoaded = 1 << 3
};

#define PRFS_NORMAL_TEXT @"pull refresh"
#define PRFS_PULLING_TEXT @"pull refresh"
#define PRFS_WILLLOADING_TEXT @"free to loading"
#define PRFS_LOADING_TEXT @"loading..."
#define PRFS_FINISH_TEXT @"finish loaded"

typedef void(^refreshDidTriggerLoadingBlock)(void);

@interface FKRefresh : UIView
@property (assign , nonatomic) VIPullRefreshState state;
@property (copy , nonatomic) refreshDidTriggerLoadingBlock triggerBlock;

- (id)initWithFrame:(CGRect)frame
         scrollView:(UIScrollView*)scrollView
       triggerBlock:(refreshDidTriggerLoadingBlock)triggerBlock;

- (void)handleRotateAnimate:(CGFloat)offset;

- (void)autoRotateAnimate;

- (void)stopRotateAnimate;

@end
