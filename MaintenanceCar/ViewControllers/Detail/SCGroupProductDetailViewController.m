//
//  SCGroupProductDetailViewController.m
//  MaintenanceCar
//
//  Created by ShiCang on 15/3/2.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCGroupProductDetailViewController.h"
#import <SCLoopScrollView/SCLoopScrollView.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SCBuyGroupProductCell.h"
#import "SCGroupProductMerchantCell.h"
#import "SCGroupProductDetailCell.h"
#import "SCShowMoreCell.h"
#import "SCCommentCell.h"
#import "SCOrderPayViewController.h"
#import "SCCommentsViewController.h"
#import "SCReservationViewController.h"
#import "SCMerchantDetailViewController.h"

@interface SCGroupProductDetailViewController () <SCBuyGroupProductCellDelegate, SCGroupProductMerchantCellDelegate> {
    SCGroupProductDetail *_detail;
    
    SCBuyGroupProductCell *_productCell;
    SCGroupProductMerchantCell *_merchantCell;
    SCGroupProductDetailCell *_detailCell;
    SCCommentCell *_commentCell;
}

@end

@implementation SCGroupProductDetailViewController

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    // 用户行为统计，页面停留时间
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"[团购] - 团购详情"];
}

- (void)viewWillDisappear:(BOOL)animated {
    // 用户行为统计，页面停留时间
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"[团购] - 团购详情"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Init Methods
+ (instancetype)instance {
    return [SCStoryBoardManager viewControllerWithClass:self storyBoardName:SCStoryBoardNameDetail];
}

#pragma mark - Config Methods
- (void)initConfig {
}

- (void)viewConfig {
    [self.tableView reLayoutHeaderView];
    [self startGroupProductDetailRequest];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _detail ? 5 : Zero;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _detail ? ((section == 4) ? _detail.comments.count : 1) : Zero;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (_detail) {
        switch (indexPath.section) {
            case 1: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SCGroupProductMerchantCell" forIndexPath:indexPath];
                (((SCGroupProductMerchantCell *)cell)).delegate = self;
                [(SCGroupProductMerchantCell *)cell displayCellWithDetial:_detail];
                break;
            }
            case 2: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SCGroupProductDetailCell" forIndexPath:indexPath];
                [(SCGroupProductDetailCell *)cell displayCellWithDetail:_detail];
                break;
            }
            case 3: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SCShowMoreCell" forIndexPath:indexPath];
                ((SCShowMoreCell *)cell).count = _detail.comments_num;
                break;
            }
            case 4: {
                if (_detail.comments.count) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SCCommentCell" forIndexPath:indexPath];
                    [(SCCommentCell *)cell displayCellWithComment:_detail.comments[indexPath.row]];
                } else {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SCNoneCommentCell" forIndexPath:indexPath];
                }
                break;
            }
            default: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SCBuyGroupProductCell" forIndexPath:indexPath];
                if (_price) {
                    [(SCBuyGroupProductCell *)cell displayCellWithPrice:_price];
                } else {
                    [(SCBuyGroupProductCell *)cell displayCellWithDetail:_detail];
                }
                break;
            }
        }
    }
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = ZERO_POINT;
    CGFloat separatorHeight = 1.0f;
    if (_detail) {
        switch (indexPath.section) {
            case 0: {
                if(!_productCell) {
                    _productCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCBuyGroupProductCell"];
                }
                if (_price) {
                    [_productCell displayCellWithPrice:_price];
                } else {
                    [_productCell displayCellWithDetail:_detail];
                }
                height = [_productCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                break;
            }
            case 1: {
                if(!_merchantCell) {
                    _merchantCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCGroupProductMerchantCell"];
                }
                [_merchantCell displayCellWithDetial:_detail];
                height = [_merchantCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                break;
            }
            case 2: {
                if(!_detailCell) {
                    _detailCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCGroupProductDetailCell"];
                }
                [_detailCell displayCellWithDetail:_detail];
                height = [_detailCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                break;
            }
            case 4: {
                if(!_commentCell) {
                    _commentCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCCommentCell"];
                }
                [_commentCell displayCellWithComment:_detail.comments[indexPath.row]];
                height = [_commentCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                break;
            }
            default:
                return 43.0f;
                break;
        }
    }
    return height + separatorHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 2) return 30.0f;
    return ZERO_POINT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text  = @"";
    switch (section) {
        case 1: {
            text = @"商家信息";
            break;
        }
        case 2: {
            text = _price ? @"商品详情" : @"团购详情";
            break;
        }
        default:
            return nil;
            break;
    }
    UIView *view    = [[UIView alloc] initWithFrame:CGRectMake(ZERO_POINT, ZERO_POINT, SCREEN_WIDTH, 30.0f)];
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(14.0f, ZERO_POINT, 100.0f, 30.0f)];
    label.font      = [UIFont systemFontOfSize:15.0f];
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    label.text = text;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[SCGroupProductMerchantCell class]]) {
        SCMerchantDetailViewController *merchantDetailViewController = [SCMerchantDetailViewController instance];
        merchantDetailViewController.merchant = [[SCMerchant alloc] initWithMerchantName:_detail.name companyID:_detail.company_id];
        merchantDetailViewController.canSelectedReserve = YES;
        [self.navigationController pushViewController:merchantDetailViewController animated:YES];
    } else if ([cell isKindOfClass:[SCShowMoreCell class]]) {
        SCCommentsViewController *commentListViewController = [SCCommentsViewController instance];
        commentListViewController.companyID = _detail.company_id;
        [self.navigationController pushViewController:commentListViewController animated:YES];
    }
}

#pragma mark - Private Methods
- (void)startGroupProductDetailRequest {
    WEAK_SELF(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *parameters = @{@"product_id": _price ? _price.product_id : _product.product_id};
    [[SCAppApiRequest manager] startMerchantGroupProductDetailAPIRequestWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        if (operation.response.statusCode == SCApiRequestStatusCodeGETSuccess) {
            _detail = [[SCGroupProductDetail alloc] initWithDictionary:responseObject error:nil];
            [weakSelf dispalyDetialView];
            [weakSelf.tableView reloadData];
        }
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    }];
}

- (void)dispalyDetialView {
    _merchanImagesView.defaultImage = [UIImage imageNamed:@"MerchantImageDefault"];
    _merchanImagesView.images = @[[NSString stringWithFormat:@"%@%@", MerchantImageDoMain, _detail.img1 ? _detail.img1 : [NSString stringWithFormat:@"%@_1.jpg", _detail.company_id]]];
    [_merchanImagesView show:nil finished:nil];
}

#pragma mark - SCGroupProductCellDelegate Methods
- (void)shouldShowBuyProductView {
    if ([SCUserInfo share].loginState) {
        SCOrderPayViewController *payOrderViewController = [SCOrderPayViewController instance];
        payOrderViewController.groupProduct = _detail;
        [self.navigationController pushViewController:payOrderViewController animated:YES];
    } else {
        [self showShoulLoginAlert];
    }
}

- (void)shouldReserveProduct {
    // 跳转到预约页面
    [[SCUserInfo share] removeItems];
    SCReservationViewController *reservationViewController = [SCReservationViewController instance];
    reservationViewController.merchant    = [[SCMerchant alloc] initWithMerchantName:_price.merchantName
                                                                           companyID:_price.companyID];
    reservationViewController.serviceItem = [[SCServiceItem alloc] initWithServiceID:_price.type];
    reservationViewController.quotedPrice = _price;
    [self.navigationController pushViewController:reservationViewController animated:YES];
}

#pragma mark - SCGroupProductMerchantCell Delegate Methods
- (void)shouldCallToMerchant {
    if (_detail.telephone.length) {
        NSArray *phones = [_detail.telephone componentsSeparatedByString:@" "];
        UIAlertView *alertView = nil;
        if (phones.count > 1) {
            alertView = [[UIAlertView alloc] initWithTitle:@"是否拨打商家电话"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:[phones firstObject], [phones lastObject], nil];
        } else {
            alertView = [[UIAlertView alloc] initWithTitle:@"是否拨打商家电话"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:[phones firstObject], nil];
        }
        alertView.tag = 1;
        [alertView show];
    }
}

#pragma mark - Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag) {
        NSArray *phones = [_detail.telephone componentsSeparatedByString:@" "];
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [phones firstObject]]]];
        } else if (buttonIndex == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [phones lastObject]]]];
        }
    } else {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [NOTIFICATION_CENTER postNotificationName:kUserNeedLoginNotification object:nil];
        }
    }
}

@end
