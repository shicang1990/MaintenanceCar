//
//  SCMyOderDetailViewController.m
//  MaintenanceCar
//
//  Created by ShiCang on 15/4/27.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCMyOderDetailViewController.h"
#import "SCMyOderDetailInfoCell.h"
#import "SCMyOderDetailPromptCell.h"
#import "SCMyOderDetailProgressCell.h"
#import "SCMoreMenu.h"

typedef NS_ENUM(NSUInteger, SCMyOderDetailAlertType) {
    SCMyOderAlertDetailTypeCallMerchant,
    SCMyOderAlertDetailTypeCancelReserve
};

typedef NS_ENUM(NSUInteger, SCMyOderDetailMenuType) {
    SCMyOderDetailMenuTypeCancelReservetion
};

@interface SCMyOderDetailViewController () <SCMyOderDetailInfoCellDelegate>
{
    SCMyOderDetailInfoCell     *_myOderDetailInfoCell;
    SCMyOderDetailProgressCell *_myOderDetailProgressCell;
}

@end

@implementation SCMyOderDetailViewController

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    // 用户行为统计，页面停留时间
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"[个人中心] - 订单详情"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 用户行为统计，页面停留时间
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"[个人中心] - 订单详情"];
    
    if (_needRefresh)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(shouldRefresh)])
            [_delegate shouldRefresh];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig
{
    [super initConfig];
}

- (void)viewConfig
{
    [super viewConfig];
    
    UIView *footer                 = [[UIView alloc] initWithFrame:CGRectMake(ZERO_POINT, ZERO_POINT, SCREEN_WIDTH, 40.0f)];
    footer.backgroundColor         = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
}

#pragma mark - Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _detail ? 2 : Zero;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _detail ? (section ? _detail.processes.count + 1 : 1) : Zero;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (_detail)
    {
        switch (indexPath.section)
        {
            case 1:
            {
                if (indexPath.row)
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SCMyOderDetailProgressCell" forIndexPath:indexPath];
                    [(SCMyOderDetailProgressCell *)cell displayCellWithDetail:_detail index:(indexPath.row-1)];
                }
                else
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SCMyOderDetailPromptCell" forIndexPath:indexPath];
            }
                break;
                
            default:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SCMyOderDetailInfoCell" forIndexPath:indexPath];
                [(SCMyOderDetailInfoCell *)cell displayCellWithDetail:_detail];
            }
                break;
        }
    }
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (_detail)
    {
        switch (indexPath.section)
        {
            case 1:
            {
                if (indexPath.row)
                {
                    if(!_myOderDetailProgressCell)
                        _myOderDetailProgressCell = [tableView dequeueReusableCellWithIdentifier:@"SCMyOderDetailProgressCell"];
                    height = [_myOderDetailProgressCell displayCellWithDetail:_detail index:(indexPath.row-1)];
                }
                else
                    height = 43.0f;
            }
                break;
                
            default:
            {
                if(!_myOderDetailInfoCell)
                    _myOderDetailInfoCell = [tableView dequeueReusableCellWithIdentifier:@"SCMyOderDetailInfoCell"];
                height = [_myOderDetailInfoCell displayCellWithDetail:_detail];
            }
                break;
        }
    }
    
    return height;
}

#pragma mark - Public Methods
- (void)startDropDownRefreshReuqest
{
    [super startDropDownRefreshReuqest];
    [self startMyOderDetailRequest];
}

#pragma mark - Private Methods
/**
 *  订单详情数据请求方法，必选参数：user_id，reserve_id
 */
- (void)startMyOderDetailRequest
{
    __weak typeof(self) weakSelf = self;
    // 配置请求参数
    NSDictionary *parameters = @{@"user_id": [SCUserInfo share].userID,
                              @"reserve_id": _reserveID};
    [[SCAPIRequest manager] startMyOderDetailAPIRequestWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == SCAPIRequestStatusCodeGETSuccess)
        {
            NSInteger statusCode    = [responseObject[@"status_code"] integerValue];
            NSString *statusMessage = responseObject[@"status_message"];
            switch (statusCode)
            {
                case SCAPIRequestErrorCodeNoError:
                {
                    _detail = [[SCMyOderDetail alloc] initWithDictionary:responseObject[@"data"] error:nil];
                    [weakSelf displayDetailViewController];
                }
                    break;
            }
            if (![statusMessage isEqualToString:@"success"])
                [weakSelf showHUDAlertToViewController:weakSelf text:statusMessage];
        }
        [weakSelf endRefresh];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf hanleFailureResponseWtihOperation:operation];
        [weakSelf endRefresh];
    }];
}

- (void)displayDetailViewController
{
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = _detail.canCancel ? [self rightBarButtonItem] : nil;
}

- (UIBarButtonItem *)rightBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MoreIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showCancelAlert)];
    return item;
}

- (void)showCancelAlert
{
    __weak typeof(self)weakSelf = self;
    SCMoreMenu *moreMenu = [[SCMoreMenu alloc] initWithTitles:@[@"取消订单"] images:nil];
    [moreMenu show:^(NSInteger selectedIndex) {
        switch (selectedIndex)
        {
            case SCMyOderDetailMenuTypeCancelReservetion:
                [weakSelf showAlertWithTitle:@"您确定要取消此订单吗？" message:nil delegate:self tag:SCMyOderAlertDetailTypeCancelReserve cancelButtonTitle:@"否" otherButtonTitle:@"是"];
                break;
                
            default:
                break;
        }
    }];
}

/**
 *  取消预约请求方法，必选参数：company_id，user_id，reserve_id，status
 */
- (void)startCancelReservationRequest
{
    [self showHUDOnViewController:self.navigationController];
    __weak typeof(self) weakSelf = self;
    NSDictionary *paramters = @{@"user_id": [SCUserInfo share].userID,
                             @"company_id": _detail.companyID,
                             @"reserve_id": _detail.reserveID,
                                 @"status": @"4"};
    [[SCAPIRequest manager] startUpdateReservationAPIRequestWithParameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf hideHUDOnViewController:weakSelf.navigationController];
        if (operation.response.statusCode == SCAPIRequestStatusCodePOSTSuccess)
        {
            NSInteger statusCode    = [responseObject[@"status_code"] integerValue];
            NSString *statusMessage = responseObject[@"status_message"];
            switch (statusCode)
            {
                case SCAPIRequestErrorCodeNoError:
                {
                    _needRefresh = YES;
                    [weakSelf.tableView.header beginRefreshing];
                }
                    break;
            }
            [weakSelf showHUDAlertToViewController:weakSelf.navigationController text:statusMessage];
        }
        else
            [weakSelf showHUDAlertToViewController:weakSelf text:DataError];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf hideHUDOnViewController:weakSelf.navigationController];
        [weakSelf hanleFailureResponseWtihOperation:operation];
    }];
}

#pragma mark - SCMyOderDetailInfoCellDelegate Methods
- (void)shouldCallMerchantWithPhone:(NSString *)phone
{
    [self showAlertWithTitle:@"是否拨打商家电话？" message:phone delegate:self tag:Zero cancelButtonTitle:@"取消" otherButtonTitle:@"拨打"];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        switch (alertView.tag)
        {
            case SCMyOderAlertDetailTypeCallMerchant:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", alertView.message]]];
                break;
            case SCMyOderAlertDetailTypeCancelReserve:
                [self startCancelReservationRequest];
                break;
            case SCViewControllerAlertTypeNeedLogin:
                [self checkShouldLogin];
                break;
        }
    }
}

@end
