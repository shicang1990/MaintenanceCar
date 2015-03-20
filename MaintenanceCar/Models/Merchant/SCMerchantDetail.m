//
//  SCMerchantDetail.m
//  MaintenanceCar
//
//  Created by ShiCang on 14/12/26.
//  Copyright (c) 2014年 MaintenanceCar. All rights reserved.
//

#import "SCMerchantDetail.h"
#import "SCLocationManager.h"
#import "SCAllDictionary.h"

@implementation SCMerchantDetail

#pragma mark - Init Methods
- (id)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    self = [super initWithDictionary:dict error:err];
    if (self)
    {
        if (_flags)
        _merchantFlags     = [_flags componentsSeparatedByString:@","];
        [[SCAllDictionary share] generateServiceItemsWtihMerchantImtes:_service_items inspectFree:[_inspect_free boolValue]];
        
        _merchantImages    = [self handleMerchantImages];
        _serviceItems      = [self handleServiceItmes];
        
        if (!_time_open)
            _time_open = @"";
        if (!_time_closed)
            _time_closed = @"";
        
        [self handleProducts:_products];
    }
    return self;
}

#pragma mark - Private Methods
- (void)handleProducts:(NSArray *)products
{
    [products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SCGroupProduct *product = obj;
        product.companyID       = _company_id;
        product.merchantName    = _name;
    }];
}

- (NSArray *)handleMerchantImages
{
    NSMutableArray *images = [NSMutableArray arrayWithArray:_images];
    for (NSDictionary *pic in images)
    {
        if (pic[@"pic_type"])
        {
            [images removeObject:pic];
            [images insertObject:pic atIndex:0];
            break;
        }
    }
    
    return images;
}

- (NSDictionary *)handleServiceItmes
{
    NSMutableDictionary *serviceItems = [@{} mutableCopy];
    NSDictionary *washItem        = _service_items[@"1"];
    NSDictionary *maintenanceItem = _service_items[@"2"];
    NSDictionary *repairItem      = _service_items[@"3"];
    
    if (washItem.count)
        [serviceItems setObject:washItem forKey:@"1"];
    if (maintenanceItem.count)
        [serviceItems setObject:maintenanceItem forKey:@"2"];
    if (repairItem.count)
        [serviceItems setObject:repairItem forKey:@"3"];
    if (_inspect_free)
        [serviceItems setObject:@[@"免费检测"] forKey:@"4"];
    
    return serviceItems;
}

#pragma mark - Setter And Getter Methods
- (NSString *)distance
{
    // 本地处理位置距离
    return [[SCLocationManager share] distanceWithLatitude:[_latitude doubleValue] longitude:[_longtitude doubleValue]];
}

@end
