//
//  SCHomePageViewController.h
//  MaintenanceCar
//
//  Created by ShiCang on 14/12/19.
//  Copyright (c) 2014年 MaintenanceCar. All rights reserved.
//

#import "SCViewControllerCategory.h"

typedef NS_ENUM(NSUInteger, SCHomePageServiceButtonType) {
    SCHomePageServiceButtonTypeRepair,
    SCHomePageServiceButtonTypeMaintance,
    SCHomePageServiceButtonTypeWash,
    SCHomePageServiceButtonTypeOperation
};

@class SCHomePageDetailView;

@interface SCHomePageViewController : UIViewController

@property (weak, nonatomic) IBOutlet SCHomePageDetailView *detailView;          // 首页详情View

+ (instancetype)instance;

@end