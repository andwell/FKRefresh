//
//  ViewController.m
//  FKRefreshDemo
//
//  Created by Andwell on 15/6/8.
//  Copyright (c) 2015年 FunkingGuo. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+FKRefresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *tableView;//or UIWebView/UIScrollView
@property (assign, nonatomic)NSUInteger number;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
    __weak __typeof(&*self)weakSelf = self;
    [self.tableView pullRefreshTriggerLoading:^{
        [weakSelf performSelector:@selector(doStopRefresh) withObject:nil afterDelay:3.0];
    }];
    //start refresh
    [weakSelf performSelector:@selector(doAutoReFresh) withObject:nil afterDelay:1.0];
}

- (void)dealloc
{
    [self.tableView removeObserverScroll];
}

#pragma mark -- tableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5+self.number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    return cell;
}

#pragma mark -- private method

- (void)doAutoReFresh
{
    [self.tableView autoTriggerRefreshLoading];
}

- (void)doStopRefresh
{
    self.number += 1;
    [self.tableView reloadData];
    [self.tableView stopRefreshLoading];
}

#pragma mark -- getter/seeter

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setBackgroundColor:[UIColor clearColor]];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
