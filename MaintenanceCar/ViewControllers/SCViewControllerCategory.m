//
//  SCViewController.h
//
//  Copyright (c) 2015年 ShiCang. All rights reserved.
//

#import "SCViewControllerCategory.h"

#define HUDDelay        0.5f

@implementation UIViewController (SCViewController)

#pragma mark - Public Methods
#pragma mark -
#pragma mark - Alert Methods
- (void)showAlertWithMessage:(NSString *)message {
    [self showAlertWithTitle:@"温馨提示" message:message];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title
                     message:message
                    delegate:nil
                         tag:Zero
           cancelButtonTitle:@"确定"
            otherButtonTitle:nil];
}

- (void)showShoulLoginAlert {
    [self showShoulLoginAlertWithTitle:@"您还没有登录，请先登录！"];
}

- (void)showShoulLoginAlertWithTitle:(NSString *)title {
    [self showAlertWithTitle:title
                     message:nil
                    delegate:self
                         tag:SCViewControllerAlertTypeNeedLogin
           cancelButtonTitle:@"取消"
            otherButtonTitle:@"登录"];
}

- (void)checkShouldLogin {
    if (![SCUserInfo share].loginState)
        [NOTIFICATION_CENTER postNotificationName:kUserNeedLoginNotification object:nil];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                  delegate:(id)delegate
                       tag:(NSInteger)tag
         cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitle:(NSString *)otherButtonTitle
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:otherButtonTitle, nil];
    alertView.tag = tag;
    [alertView show];
}

#pragma mark - HUD Methods
- (void)showHUDOnViewController:(UIViewController *)viewController {
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
}

- (void)hideHUDOnViewController:(UIViewController *)viewController {
    [MBProgressHUD hideAllHUDsForView:viewController.view animated:YES];
}

- (void)showHUDAlertToViewController:(UIViewController *)viewController text:(NSString *)text {
    [self showHUDAlertToViewController:viewController text:text delay:HUDDelay];
}

- (void)showHUDAlertToViewController:(UIViewController *)viewController text:(NSString *)text delay:(NSTimeInterval)delay {
    [self showHUDAlertToViewController:viewController delegate:nil text:text delay:delay];
}

- (void)showHUDAlertToViewController:(UIViewController *)viewController tag:(NSInteger)tag text:(NSString *)text {
    [self showHUDAlertToViewController:viewController tag:tag text:text delay:HUDDelay];
}

- (void)showHUDAlertToViewController:(UIViewController *)viewController
                                 tag:(NSInteger)tag
                                text:(NSString *)text
                               delay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [self showTextHUDToViewController:viewController text:text];
    hud.delegate = self;
    hud.tag      = tag;
    [hud hide:YES afterDelay:delay];
}

- (void)showHUDAlertToViewController:(UIViewController *)viewController
                            delegate:(id)delegate
                                text:(NSString *)text
                               delay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [self showTextHUDToViewController:viewController text:text];
    hud.delegate = delegate;
    [hud hide:YES afterDelay:delay];
}

- (void)showHUDPromptToViewController:(UIViewController *)viewController
                                  tag:(NSInteger)tag
                                 text:(NSString *)text
                                delay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [self showHUDToViewController:viewController text:text];
    hud.delegate = self;
    hud.mode     = MBProgressHUDModeIndeterminate;
    [hud hide:YES afterDelay:delay];
}

- (void)hanleFailureResponseWtihOperation:(AFHTTPRequestOperation *)operation {
    NSString *message = operation.responseObject[@"message"];
    if (message.length)
    {
        if (operation.response.statusCode == SCApiRequestStatusCodeTokenError) {
            [self showShoulReLoginAlert];
        } else {
            [self showHUDAlertToViewController:self text:message];
        }
    } else {
        [self showHUDAlertToViewController:self text:NetWorkingError];
    }
}

#pragma mark - Private Methods
- (MBProgressHUD *)showHUDToViewController:(UIViewController *)viewController text:(NSString *)text {
    MBProgressHUD *hud            = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.labelText                 = text;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

- (MBProgressHUD *)showTextHUDToViewController:(UIViewController *)viewController text:(NSString *)text {
    MBProgressHUD *hud = [self showHUDToViewController:viewController text:text];
    hud.mode           = MBProgressHUDModeText;
    hud.yOffset        = SCREEN_HEIGHT/2 - 110.0f;
    hud.margin         = 10.0f;
    return hud;
}

- (void)showShoulReLoginAlert {
    [[SCUserInfo share] logout];
    [self showAlertWithTitle:@"您有一段时间没有使用修养了，为了您的安全考虑，请您重新登录"
                     message:nil
                    delegate:self
                         tag:SCViewControllerAlertTypeNeedLogin
           cancelButtonTitle:@"取消"
            otherButtonTitle:@"登录"];
}

#pragma mark - Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        switch (alertView.tag) {
            case SCViewControllerAlertTypeNeedLogin:
                [self checkShouldLogin];
                break;
        }
    }
}

@end


#pragma mark - SCTableView Implementation
#pragma mark -
@implementation UITableView (SCTableView)

#pragma mark - Public Methods
- (void)reLayoutHeaderView {
    SCDeviceModelType deviceModel = [SCVersion currentModel];
    if (deviceModel == SCDeviceModelTypeIphone6) {
        self.tableHeaderView.frame = CGRectMake(ZERO_POINT, ZERO_POINT, SCREEN_WIDTH, 281.25f);
    } else if (deviceModel == SCDeviceModelTypeIphone6Plus) {
        self.tableHeaderView.frame = CGRectMake(ZERO_POINT, ZERO_POINT, SCREEN_WIDTH, 300.0f);
    }
    [self.tableHeaderView needsUpdateConstraints];
    [self.tableHeaderView layoutIfNeeded];
}

- (void)reLayoutFooterView {
    SCDeviceModelType deviceModel = [SCVersion currentModel];
    if (deviceModel == SCDeviceModelTypeIphone6) {
        self.tableFooterView.frame = CGRectMake(ZERO_POINT, ZERO_POINT, SCREEN_WIDTH, 180.0f);
    } else if (deviceModel == SCDeviceModelTypeIphone6Plus) {
        self.tableFooterView.frame = CGRectMake(ZERO_POINT, ZERO_POINT, SCREEN_WIDTH, 200.0f);
    }
    [self.tableHeaderView needsUpdateConstraints];
    [self.tableHeaderView layoutIfNeeded];
}

@end
