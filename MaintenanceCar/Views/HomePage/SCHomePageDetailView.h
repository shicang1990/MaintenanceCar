//
//  SCHomePageDetailView.h
//  MaintenanceCar
//
//  Created by ShiCang on 15/1/24.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCUserCar.h"

@class SCLoopScrollView;
@class SCSpecial;

@protocol SCHomePageDetailViewDelegate <NSObject>

@optional
- (void)shouldShowOperatAd:(SCSpecial *)special;

- (void)shouldAddCar;
- (void)shouldChangeCarData:(SCUserCar *)userCar;

@end

@interface SCHomePageDetailView : UIView

@property (nonatomic, weak) IBOutlet               id  <SCHomePageDetailViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet SCLoopScrollView *operatADView;        // 运营位
@property (weak, nonatomic) IBOutlet          UILabel *merchantNameLabel;   // 商家名称栏
@property (weak, nonatomic) IBOutlet          UILabel *serviceNameLabel;    // 服务项目名称栏
@property (weak, nonatomic) IBOutlet          UILabel *servicePromptLabel;  // 服务提示栏
@property (weak, nonatomic) IBOutlet          UILabel *serviceDaysLabel;    // 服务时间栏
@property (weak, nonatomic) IBOutlet          UILabel *promptLabel;         // 提示栏

- (IBAction)promptTap:(id)sender;

- (void)getUserCar;
- (void)refresh;

@end