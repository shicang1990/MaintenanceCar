//
//  SCMerchantDetailViewController.h
//  MaintenanceCar
//
//  Created by ShiCang on 14/12/26.
//  Copyright (c) 2014年 MaintenanceCar. All rights reserved.
//

#import "SCViewController.h"

@class SCMerchant;
@class SCMerchantDetail;
@class SCCollectionItem;
@class SCLoopScrollView;

@interface SCMerchantDetailViewController : UITableViewController

@property (nonatomic, strong)              SCMerchant *merchant;            // 商家信息
@property (nonatomic, strong)        SCMerchantDetail *merchantDetail;      // 商家详情数据模型

@property (weak, nonatomic) IBOutlet SCCollectionItem *collectionItem;      // 收藏按钮
@property (weak, nonatomic) IBOutlet SCLoopScrollView *merchantImagesView;  // 商户图片

/**
 *  [收藏]按钮触发事件
 */
- (IBAction)collectionItemPressed:(SCCollectionItem *)sender;

@end
