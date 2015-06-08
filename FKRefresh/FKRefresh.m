//
//  FKRefresh.m
//  FKRefreshDemo
//
//  Created by Andwell on 15/6/8.
//  Copyright (c) 2015年 FunkingGuo. All rights reserved.
//

#import "FKRefresh.h"

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

@interface FKRefresh ()
@property (nonatomic, strong) UIImage *carWheel;
@property (nonatomic, strong) CALayer *carWheelLayer;
@property (nonatomic, strong) CALayer *maskingLayer;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) double prevProgress;
@property (nonatomic, assign) BOOL isMoreMax;
@end

@implementation FKRefresh

- (id)initWithFrame:(CGRect)frame
         scrollView:(UIScrollView*)scrollView
       triggerBlock:(refreshDidTriggerLoadingBlock)triggerBlock
{
    self= [super initWithFrame:frame];
    if (self) {
        self.scrollView = scrollView;
        self.triggerBlock = triggerBlock;
        _carWheel = [UIImage imageNamed:@"home_wheel"];
        _carWheelLayer = [CALayer layer];
        _carWheelLayer.contentsScale = [UIScreen mainScreen].scale;
        _carWheelLayer.frame = CGRectMake(CGRectGetWidth(frame)/2.-25/2., CGRectGetHeight(frame)/2.-22, 25, 25);
        _carWheelLayer.contents = (id)self.carWheel.CGImage;
        _carWheelLayer.contentsGravity = kCAGravityResizeAspect;
        _carWheelLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180),0,0,1);
        [self.layer addSublayer:_carWheelLayer];
        
        _refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_carWheelLayer.frame)+5, CGRectGetWidth(frame), 15)];
        [_refreshLabel setBackgroundColor:[UIColor clearColor]];
        [_refreshLabel setTextColor:[UIColor colorWithRed:0x39/255. green:0xb9/255. blue:0xa0/255. alpha:1.]];
        [_refreshLabel setTextAlignment:NSTextAlignmentCenter];
        [_refreshLabel setFont:[UIFont systemFontOfSize:11]];
        [_refreshLabel setText:PRFS_NORMAL_TEXT];
        [self addSubview:_refreshLabel];
        
        _maskingLayer = [CALayer layer];
        [_maskingLayer setFrame:self.bounds];
        [self.layer addSublayer:_maskingLayer];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self.maskingLayer setBackgroundColor:[newSuperview backgroundColor].CGColor];
}

- (void)handleRotateAnimate:(CGFloat)offset
{
    CGFloat triggerOffset = PULLMAXOFFSET - 10.;
    if(self.scrollView.isDragging) {
        if (offset<=0) {
            self.state = VIPullRefreshPulling;
        }else {
            if (offset<triggerOffset) {
                self.state = VIPullRefreshPulling;
            }else self.state = VIPullRefreshPullWillLoading;
            self.progress = offset/triggerOffset;
        }
    }else {
        if (offset>0){
            if (offset <= triggerOffset) {
                if (self.state == VIPullRefreshPulling) {
                    self.state = VIPullRefreshNormal;
                    self.progress = 0.0;
                }
            }else {
                if (self.state == VIPullRefreshPullWillLoading) {
                    self.state = VIPullRefreshLoading;
                    self.maskingLayer.affineTransform = CGAffineTransformMakeTranslation(0, PULLMAXOFFSET);
                }else if (self.state == VIPullRefreshFinishLoaded) {
                    self.state = VIPullRefreshNormal;
                }
                if (offset == PULLMAXOFFSET && self.state == VIPullRefreshLoading) {
                    self.progress = 1.0;//roate
                }
            }
        }else {
            if (self.state != VIPullRefreshNormal && self.state != VIPullRefreshLoading) {
                self.state = VIPullRefreshNormal;
                [self recoverAnimate];
            }
        }
    }
}

- (void)setState:(VIPullRefreshState)state
{
    _state = state;
    [self.scrollView setScrollEnabled:(state!=VIPullRefreshLoading)];
    switch (state) {
        case VIPullRefreshNormal:
        {
            [_refreshLabel setText:PRFS_NORMAL_TEXT];
            if (self.scrollView.contentInset.top != 0)
                self.scrollView.contentInset = UIEdgeInsetsZero;
        }
            break;
        case VIPullRefreshPulling:
        {
            [_refreshLabel setText:PRFS_NORMAL_TEXT];
        }
            break;
        case VIPullRefreshPullWillLoading:
        {
            [_refreshLabel setText:PRFS_WILLLOADING_TEXT];
        }
            break;
        case VIPullRefreshLoading:
        {
            [_refreshLabel setText:PRFS_LOADING_TEXT];
            if (_triggerBlock) _triggerBlock();
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.2];
            [self.scrollView setContentInset:UIEdgeInsetsMake(PULLMAXOFFSET, 0.0f, 0.0f, 0.0f)];
            [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1., 1.) animated:NO];
            [UIView commitAnimations];
            if (_progress < 1.0) self.progress = 1.0;
        }
            break;
        case VIPullRefreshFinishLoaded:
        {
            [_refreshLabel setText:PRFS_FINISH_TEXT];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.2];
            [self.scrollView setContentInset:UIEdgeInsetsZero];
            [UIView commitAnimations];
        }
            break;
        default:
            break;
    }
}

//animate pregress
- (void)setProgress:(double)progress
{
    if (progress >= 0 && progress <1.0) {
        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animationImage.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*self.prevProgress)];
        animationImage.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*progress)];
        animationImage.duration = 0.15;
        animationImage.removedOnCompletion = NO;
        animationImage.fillMode = kCAFillModeForwards;
        [self.carWheelLayer addAnimation:animationImage forKey:@"animationImage"];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        animation.fromValue = [NSNumber numberWithFloat:PULLMAXOFFSET*self.prevProgress];
        animation.toValue = [NSNumber numberWithFloat:PULLMAXOFFSET*progress];
        animation.duration = 0.15;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.maskingLayer addAnimation:animation forKey:@"animation"];
        self.prevProgress = progress;
        self.isMoreMax = NO;
    }else if (progress >= 1.0 && !self.isMoreMax) {
        self.isMoreMax = YES;
        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animationImage.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*self.prevProgress)];
        animationImage.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(-180-180*self.prevProgress)];
        animationImage.duration = .5;
        animationImage.repeatCount = LONG_MAX;
        animationImage.removedOnCompletion = NO;
        animationImage.fillMode = kCAFillModeForwards;
        [self.carWheelLayer addAnimation:animationImage forKey:@"animationImage"];
        [self.maskingLayer removeAnimationForKey:@"animation"];
        self.maskingLayer.affineTransform = CGAffineTransformMakeTranslation(0, PULLMAXOFFSET);
    }else if (self.isMoreMax) self.maskingLayer.affineTransform = CGAffineTransformMakeTranslation(0, PULLMAXOFFSET);
    _progress = progress;
}

- (void)autoRotateAnimate
{
    if (self.state != VIPullRefreshLoading) {
        self.state = VIPullRefreshLoading;
    }
}

- (void)stopRotateAnimate
{
    self.state = VIPullRefreshFinishLoaded;
    [self recoverAnimate];
}

- (void)recoverAnimate
{
    [self.carWheelLayer removeAnimationForKey:@"animationImage"];
    self.carWheelLayer.affineTransform = CGAffineTransformIdentity;
    [self.maskingLayer removeAnimationForKey:@"animation"];
    self.maskingLayer.affineTransform = CGAffineTransformIdentity;
}

@end
