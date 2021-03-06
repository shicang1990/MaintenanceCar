//
//  SCCollectionsViewController.m
//  MaintenanceCar
//
//  Created by ShiCang on 15/1/5.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCCollectionsViewController.h"
#import "SCMerchantTableViewCell.h"
#import "SCReservationViewController.h"
#import "SCLocationManager.h"

static NSString *const CollectionNavControllerID = @"CollectionsNavigationController";

@implementation SCCollectionsViewController

#pragma mark - Init Methods
+ (UINavigationController *)navigationInstance {
    static UINavigationController *navigationController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navigationController = [SCStoryBoardManager navigaitonControllerWithIdentifier:CollectionNavControllerID
                                                                        storyBoardName:SCStoryBoardNameCollection];
    });
    return navigationController;
}

+ (instancetype)instance {
    return [SCStoryBoardManager viewControllerWithClass:self storyBoardName:SCStoryBoardNameCollection];
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    // 用户行为统计，页面停留时间
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"[个人中心] - 收藏"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self panGestureSupport:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    // 用户行为统计，页面停留时间
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"[个人中心] - 收藏"];
    
    [self panGestureSupport:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Action
- (IBAction)menuButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(shouldShowMenu)]) {
        [_delegate shouldShowMenu];
    }
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SCMerchant *merchant = _dataList[indexPath.row];
    SCMerchantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MerchantCellReuseIdentifier forIndexPath:indexPath];
    cell.reservationButton.tag    = indexPath.row;
    cell.reservationButton.hidden = !merchant.serviceItems.count;
    
    // 刷新商家列表，设置相关数据
    [cell handelWithMerchant:merchant];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;     // 允许列表编辑
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 如果用户经行删除或者滑动删除操作，设置数据缓存，并进行相关删除操作请求，同步服务器数据
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _deleteDataCache = _dataList[indexPath.row];        // 设置数据缓存
        [_dataList removeObjectAtIndex:indexPath.row];      // 清楚数据
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];   // 列表中删除相关数据行
        [self startCancelCollectionMerchantRequestWithIndex:indexPath.row];                             // 同步服务器
    }
}

#pragma mark - Table View Delegate Methods
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消收藏";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SCMerchantDetailViewController *merchantDetialViewControler = [SCMerchantDetailViewController instance];
    merchantDetialViewControler.delegate           = self;
    merchantDetialViewControler.merchant           = (SCMerchant *)_dataList[indexPath.row];
    merchantDetialViewControler.canSelectedReserve = YES;
    [self.navigationController pushViewController:merchantDetialViewControler animated:YES];
}

#pragma mark - Public Methods
- (void)startDropDownRefreshReuqest {
    [super startDropDownRefreshReuqest];
    [self refreshCollectionListMerchantList];
}

- (void)startPullUpRefreshRequest {
    [super startPullUpRefreshRequest];
    [self refreshCollectionListMerchantList];
}

- (void)refreshCollectionListMerchantList {
    WEAK_SELF(weakSelf);
    [[SCLocationManager share] getLocationSuccess:^(BMKUserLocation *userLocation, NSString *latitude, NSString *longitude) {
        [weakSelf startMerchantCollectionListRequest:latitude longitude:longitude];
    } failure:^(NSString *latitude, NSString *longitude, NSError *error) {
        [weakSelf showHUDAlertToViewController:weakSelf.navigationController text:@"定位失败，采用当前城市中心坐标!"];
        [weakSelf showAlertWithMessage:@"定位失败，请检查您的定位服务是否打开：设置->隐私->定位服务"];
        [weakSelf startMerchantCollectionListRequest:latitude longitude:longitude];
    }];
}

#pragma mark - Private Methods
/**
 *  收藏列表数据请求方法，必选参数：user_id，limit，offset
 */
- (void)startMerchantCollectionListRequest:(NSString *)latitude longitude:(NSString *)longitude {
    WEAK_SELF(weakSelf);
    // 配置请求参数
    NSDictionary *parameters = @{@"user_id": [SCUserInfo share].userID,
                                   @"limit": @(SearchLimit),
                                  @"offset": @(self.offset)};
    [[SCAppApiRequest manager] startCollectionsAPIRequestWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf endRefresh];
        if (operation.response.statusCode == SCApiRequestStatusCodeGETSuccess) {
            NSInteger statusCode    = [responseObject[@"status_code"] integerValue];
            NSString *statusMessage = responseObject[@"status_message"];
            switch (statusCode) {
                case SCAppApiRequestErrorCodeNoError: {
                    NSArray *merchants = responseObject[@"data"];
                    if (weakSelf.requestType == SCRequestRefreshTypeDropDown) {
                        [weakSelf clearListData];
                    }
                    [merchants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        SCMerchant *merchant = [[SCMerchant alloc] initWithDictionary:obj error:nil];
                        [_dataList addObject:merchant];
                    }];
                    
                    weakSelf.offset += SearchLimit;                 // 偏移量请求参数递增
                    [weakSelf.tableView reloadData];                // 数据配置完成，刷新商家列表
                    [weakSelf addRefreshHeader];
                    [weakSelf addRefreshFooter];
                    if (merchants.count < SearchLimit) {
                        [weakSelf removeRefreshFooter];
                    }
                    break;
                }
                    
                case SCAppApiRequestErrorCodeListNotFoundMore: {
                    [weakSelf.tableView reloadData];
                    [weakSelf addRefreshHeader];
                    [weakSelf removeRefreshFooter];
                    break;
                }
            }
            if (statusMessage.length) {
                [weakSelf showHUDAlertToViewController:weakSelf text:statusMessage];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf hanleFailureResponseWtihOperation:operation];
        [weakSelf endRefresh];
    }];
}

/**
 *  取消收藏商家请求方法，必选参数：company_id，user_id
 */
- (void)startCancelCollectionMerchantRequestWithIndex:(NSInteger)index {
    WEAK_SELF(weakSelf);
    NSDictionary *paramters = @{@"company_id": ((SCMerchant *)_deleteDataCache).company_id,
                                   @"user_id": [SCUserInfo share].userID};
    [[SCAppApiRequest manager] startCancelCollectionAPIRequestWithParameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 根据返回结果进行相应提示
        if (operation.response.statusCode == SCApiRequestStatusCodeGETSuccess) {
            [weakSelf showHUDAlertToViewController:weakSelf.navigationController text:@"删除成功" delay:0.5f];
        } else {
            [weakSelf deleteFailureAtIndex:index];
            [weakSelf showHUDAlertToViewController:weakSelf.navigationController text:@"删除失败，请重试！" delay:0.5f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf deleteFailureAtIndex:index];
        [weakSelf showHUDAlertToViewController:weakSelf.navigationController text:@"删除失败，请检查网络！" delay:0.5f];
    }];
}

- (void)panGestureSupport:(BOOL)support {
    if (_delegate && [_delegate respondsToSelector:@selector(shouldSupportPanGesture:)]) {
        [_delegate shouldSupportPanGesture:support];
    }
}

#pragma mark - SCMerchantDetailViewControllerDelegate Methods
- (void)cancelCollectionSuccess {
    [self.tableView.header beginRefreshing];
}

@end
