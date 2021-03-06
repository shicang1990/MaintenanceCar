//
//  SCFilter.m
//  MaintenanceCar
//
//  Created by ShiCang on 15/6/26.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCFilter.h"

@implementation SCFilterCategoryItem

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"filterTitle": @"filter_title",
                @"subItems": @"sub_items"};
}

+ (NSDictionary *)objectClassInArray
{
    return @{@"subItems": @"SCFilterCategoryItem"};
}

@end

@implementation SCFilterCategory

+ (NSDictionary *)objectClassInArray
{
    return @{@"items": @"SCFilterCategoryItem"};
}

- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    [super setKeyValues:keyValues context:context error:error];
    [self config];
    return self;
}

- (void)config
{
    BOOL have = NO;
    for (SCFilterCategoryItem *item in _items)
    {
        if (item.subItems.count)
        {
            have = YES;
            break;
        }
    }
    _haveSubItems = have;
    NSInteger max = 0;
    for (SCFilterCategoryItem *item in _items)
    {
        NSInteger count = item.subItems.count;
        max = (count > max) ? count : max;
    }
    NSInteger count = _items.count;
    _maxCount = (count > max) ? count : max;
}

@end

@implementation SCCarModelFilterCategory

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"myCars": @"my_cars",
          @"otherCars": @"other_cars"};
}

+ (NSDictionary *)objectClassInArray
{
    return @{@"myCars": @"SCFilterCategoryItem",
          @"otherCars": @"SCFilterCategoryItem"};
}

- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    [super setKeyValues:keyValues context:context error:error];
    [self config];
    return self;
}

static double LastRowHeight = 45.0f;
static double RowHeight = 40.0f;
static double MaxHeight = 85.0f;
- (void)config
{
    double height = 20.0f;
    NSInteger count = _myCars.count;
    NSInteger section = count / 3;
    section = (count % 3) ? (section + 1) : section;
    _myCarsViewHeight = (section >= 1) ? (((section - 1) * RowHeight) + LastRowHeight) : height;
    
    count = _otherCars.count;
    section = count / 3;
    section = (count % 3) ? (section + 1) : section;
    _otherCarsViewHeight = (section >= 1) ? (((section - 1) * RowHeight) + LastRowHeight) : height;
    
    _myCarsViewHeight = (_myCarsViewHeight > MaxHeight) ? MaxHeight : _myCarsViewHeight;
    _otherCarsViewHeight = (_otherCarsViewHeight > MaxHeight) ? MaxHeight : _otherCarsViewHeight;
}

@end

@implementation SCFilter

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"serviceCategory": @"service",
              @"regionCategory": @"region",
            @"carModelCategory": @"car_model",
                @"sortCategory": @"sort"};
}

@end
