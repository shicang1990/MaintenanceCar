//
//  SCMerchantViewController.h
//  MaintenanceCar
//
//  Created by ShiCang on 14/12/19.
//  Copyright (c) 2014年 MaintenanceCar. All rights reserved.
//

#import "SCViewControllerCategory.h"

@class SCSearchFilterView;

@interface SCMerchantViewController : UIViewController

@property (weak, nonatomic) IBOutlet SCSearchFilterView *searchFilterView;      // 商家列表的筛选View
@property (weak, nonatomic) IBOutlet UITableView        *tableView;             // 商家列表View

// [地图]按钮触发事件
- (IBAction)mapItemPressed:(UIBarButtonItem *)sender;

@end
