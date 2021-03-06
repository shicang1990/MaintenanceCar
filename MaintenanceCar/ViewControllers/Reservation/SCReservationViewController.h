//
//  SCReservationViewController.h
//  MaintenanceCar
//
//  Created by ShiCang on 14/12/29.
//  Copyright (c) 2014年 MaintenanceCar. All rights reserved.
//

#import "SCViewControllerCategory.h"
#import "SCMerchant.h"
#import "SCServiceItem.h"
#import "SCGroupTicket.h"

@class SCTextView;
@class SCQuotedPrice;

@protocol SCReservationViewControllerDelegate <NSObject>

@optional
- (void)reservationSuccess;

@end

@interface SCReservationViewController : UITableViewController <UITextFieldDelegate> {
    NSString *_reservationType;
    NSString *_selectedCarID;
    NSString *_reservationDate;
}

@property (weak, nonatomic) IBOutlet     UILabel *merchantNameLabel;            // 商家名称栏
@property (weak, nonatomic) IBOutlet UITextField *ownerNameTextField;           // 车主姓名输入栏
@property (weak, nonatomic) IBOutlet UITextField *ownerPhoneNumberTextField;    // 车主电话输入栏
@property (weak, nonatomic) IBOutlet     UILabel *carLabel;                     // 用户车辆栏
@property (weak, nonatomic) IBOutlet     UILabel *categoryLabel;                // 类别栏
@property (weak, nonatomic) IBOutlet     UILabel *itemLabel;                    // 项目栏
@property (weak, nonatomic) IBOutlet     UILabel *dateLabel;                    // 日期显示栏
@property (weak, nonatomic) IBOutlet  SCTextView *remarkTextField;              // 其他需求输入栏
@property (weak, nonatomic) IBOutlet    UIButton *reservationButton;            // 预约按钮

@property (nonatomic, weak)              id  <SCReservationViewControllerDelegate>delegate;
@property (nonatomic, strong)    SCMerchant *merchant;                  // 商家信息
@property (nonatomic, strong) SCServiceItem *serviceItem;               // 服务项目
@property (nonatomic, strong) SCGroupTicket *groupTicket;               // 团购券数据
@property (nonatomic, strong) SCQuotedPrice *quotedPrice;
@property (nonatomic, assign)          BOOL  canChange;

- (IBAction)reservationButtonPressed:(UIButton *)sender;

+ (instancetype)instance;

@end
