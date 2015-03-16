//
//  SCMapViewController.h
//  MaintenanceCar
//
//  Created by ShiCang on 15/1/6.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCViewController.h"

@class BMKMapView;
@class SCMapMerchantInfoView;

@interface SCMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet            BMKMapView *mapView;                    // 百度地图
@property (weak, nonatomic) IBOutlet SCMapMerchantInfoView *mapMerchantInfoView;        // 地图页面，商家信息视图，用户展示商家基本信息
@property (weak, nonatomic) IBOutlet       UIBarButtonItem *leftItem;


@property (nonatomic, strong)                      NSArray *merchants;                  // 商家列表数据
@property (nonatomic, assign)                         BOOL showInfoView;
@property (nonatomic, assign)                         BOOL isMerchantMap;

/**
 *  [列表]按钮，用于返回商家列表页面
 */
- (IBAction)listItemPressed:(UIBarButtonItem *)sender;

@end