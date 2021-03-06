//
//  SCQuotedPriceCell.h
//  MaintenanceCar
//
//  Created by ShiCang on 15/4/10.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCQuotedPriceCellDelegate <NSObject>

@optional
- (void)shouldSpecialReservationWithIndex:(NSInteger)index;

@end

@class SCQuotedPrice;

@interface SCQuotedPriceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet  UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet  UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet  UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *reservationButton;

@property (weak, nonatomic) IBOutlet  UILabel *leftParenthesis;
@property (weak, nonatomic) IBOutlet  UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet  UILabel *rightParenthesis;
@property (weak, nonatomic) IBOutlet   UIView *grayLine;

@property (nonatomic, weak)                id  <SCQuotedPriceCellDelegate>delegate;
@property (nonatomic, assign)       NSInteger  index;

- (IBAction)reservationButtonPressed:(id)sender;

- (void)displayCellWithPrice:(SCQuotedPrice *)price;

@end
