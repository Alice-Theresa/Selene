//
//  MainViewController.m
//  Selene
//
//  Created by Theresa on 2018/1/11.
//  Copyright © 2018年 Theresa. All rights reserved.
//

#import "MainViewController.h"
#import "ImageProcessViewController.h"
#import "VideoProcessViewController.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *tableViewCellIdentifier = @"tableViewCellIdentifier";

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellIdentifier];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[[ImageProcessViewController alloc] init] animated:true];
    } else {
        [self.navigationController pushViewController:[[VideoProcessViewController alloc] init] animated:true];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Image Process";
    } else {
        cell.textLabel.text = @"Video Process";
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
