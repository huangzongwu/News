//
//  HgNewsViewController.m
//  News
//
//  Created by CZG on 18/2/7.
//  Copyright © 2018年 xbull. All rights reserved.
//

#import "HgNewsViewController.h"
#import "HgNews.h"
#import "HgNewsViewCell.h"
#import "HgNewsUserViewController.h"

@interface HgNewsViewController ()<UITableViewDelegate,UITableViewDataSource,clickNameDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray *groups;

@property (nonatomic, strong) NSMutableArray * data;

@property (nonatomic, strong) NSString * num;

@property (nonatomic, assign) NSInteger page;

@end

@implementation HgNewsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.data.count==0) {
        self.page = 1;
        self.num = [NSString stringWithFormat:@"%ld",self.page];
        WEAKSELF
        [HgNews requestData:self.num success:^(NSArray *group) {
            weakSelf.groups = group;
            weakSelf.data = [NSMutableArray arrayWithArray:weakSelf.groups];
            [weakSelf.tableView reloadData];
        }];
        self.page ++;
        [self setupRefresh];
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH -64 -45 -45) style:UITableViewStylePlain];
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    [self.tableView setSeparatorColor:[UIColor clearColor ]];
    [self.view addSubview:self.tableView];
    
    self.page = 2;
    
}

- (void) setupRefresh{
    WEAKSELF;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        StrongVar(strongSelf, weakSelf);
        if (strongSelf) {
            strongSelf.num = [NSString stringWithFormat:@"%ld",strongSelf.page];
            
            NSString * total_count = (NSString *)[NSObject readObjforKey:@"total_count"];
            
            int intString = ([total_count intValue])/10;
            
            [HgNews requestData:strongSelf.num success:^(NSArray *group) {
                strongSelf.groups = group;
                for (HgNews * model in strongSelf.groups) {
                    [strongSelf.data addObject:model];
                }
                [strongSelf.tableView reloadData];
                
                if (strongSelf.page == intString) {
                    [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [strongSelf.tableView.mj_footer endRefreshing];
                }
                strongSelf.page ++ ;
            }];
        }
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HgNews * model = self.data[indexPath.row];
    
    HgNewsViewCell * cell = [HgNewsViewCell cellWithTableView:tableView];
    
    cell.news = model;
    
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 141;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(void) clickName{
    HgNewsUserViewController * vc = [[HgNewsUserViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
