//
//  SCAllDictionary.h
//  MaintenanceCar
//
//  Created by ShiCang on 15/1/25.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDictionaryItem.h"
#import "SCServiceItem.h"
#import "SCOperation.h"

typedef NS_ENUM(NSInteger, SCDictionaryType) {
    SCDictionaryTypeOrderType,                          // 订单类型
    SCDictionaryTypeReservationType,                    // 预约类型
    SCDictionaryTypeQuestionType,                       // 问题类型
    SCDictionaryTypeReservationStatus,                  // 预约状态
    SCDictionaryTypeOrderStatus,                        // 订单状态
    SCDictionaryTypeDriveHabit,                         // 驾驶习惯
};

@interface SCAllDictionary : NSObject

@property (nonatomic, strong, readonly) NSArray *orderTypeItems;              // 订单类型字典
@property (nonatomic, strong, readonly) NSArray *reservationTypeItems;        // 预约类型字典
@property (nonatomic, strong, readonly) NSArray *questionTypeItems;           // 问题类型字典
@property (nonatomic, strong, readonly) NSArray *reservationStatusItems;      // 预约状态字典
@property (nonatomic, strong, readonly) NSArray *orderStatusItems;            // 订单状态字典
@property (nonatomic, strong, readonly) NSArray *driveHabitItems;             // 驾驶习惯字典

@property (nonatomic, strong, readonly) NSArray   *serviceItems;              // 服务项目

@property (nonatomic, strong, readonly) SCOperation    *special;                // 自定义数据
@property (nonatomic, strong, readonly) NSDictionary *colors;                 // 商家Flags颜色值
@property (nonatomic, strong, readonly) NSDictionary *explains;               // 商家Flags名字
@property (nonatomic, strong, readonly) NSDictionary *details;                // 商家Flags描述

/**
 *  SCAllDictionary单例方法
 *
 *  @return SCAllDictionary实例对象
 */
+ (instancetype)share;

/**
 *  字典数据请求方法
 *
 *  @param type    请求的字典类型
 *  @param finfish 数据处理后的回调block - items参数为对应请求字典类型的数据对象集合
 */
- (void)requestWithType:(SCDictionaryType)type finfish:(void(^)(NSArray *items))finfish;

/**
 *  请求商家Flags数据
 *
 *  @param finfish 数据处理后的回调block - colors:商家Flags颜色值, explain:商家Flags名字, detail:商家Flags描述
 */
- (void)requestColorsExplain:(void(^)(NSDictionary *colors, NSDictionary *explains, NSDictionary *details))finfish;

/**
 *  合成服务项目 - 用于预约提示，筛选条件
 *
 *  @param merchantItems 商家服务项目
 *  @param free          能否免费检测
 */
- (void)generateServiceItemsWtihMerchantImtes:(NSDictionary *)merchantItems inspectFree:(BOOL)free;

/**
 *  获取商家Flag标签的图片文件名
 *
 *  @param flag 商家Flag标签名称
 *
 *  @return 商家Flag标签对应图片文件名
 */
- (NSString *)imageNameOfFlag:(NSString *)flag;

@end
