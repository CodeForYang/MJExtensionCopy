//
//  NSObject+MJProperty.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtensionConst.h"

NS_ASSUME_NONNULL_BEGIN

@class MJProperty;
///成员属性都包装成MJProperty对象 *stop = YES 停止遍历
typedef void (^MJPropertiesEnumeration)(MJProperty *property,BOOL *stop);

/// 属性名换成其他key去字典取值
typedef NSDictionary * _Nullable (^MJReplacedKeyFromPropertyName)(void);
typedef  id _Nullable (^MJReplacedKeyFromPropertyName121)(NSString *propertyName);

/// 数组中需要转换的模型类
typedef NSDictionary * _Nullable(^MJObjectClassInArray)(void);

///用于过滤字典中的值
typedef id _Nullable(^MJNewValueFromOldValue)(id object ,id oldValue,MJProperty *property);

///成员属性的相关扩展
@interface NSObject (MJProperty)
#pragma mark - 遍历

/// 遍历所有的成员
/// @param enumeration block遍历
+ (void)mj_enumerateProperties:(MJPropertiesEnumeration)enumeration;

#pragma mark - 配置新值

/// 用于过滤字典中的值
/// @param newValueFromOldValue 用于过滤字典中的值
+ (void)mj_setupNewValueFromOldValue:(MJNewValueFromOldValue)newValueFromOldValue;
+ (id)mj_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained MJProperty *)property;

#pragma mark - key配置

/// 将属性替换成其他key去字典中取值
/// @param ReplacedKeyFromPropertyName 将属性替换成其他key去字典中取值
+ (void)mj_setupReplacedKeyFromPropertyName:(MJReplacedKeyFromPropertyName)ReplacedKeyFromPropertyName;

/// 将属性替换成其他key去字典中取值
/// @param ReplacedKeyFromPropertyName121 将属性替换成其他key去字典中取值
+ (void)mj_setupReplacedKeyFromPropertyName121:(MJReplacedKeyFromPropertyName121)ReplacedKeyFromPropertyName121;

#pragma mark - array model class配置

/// 数组中需要转换的模型类
/// @param objectClassInArray 数组中需要转换的模型类
+ (void)mj_setupObjectClassInArray:(MJObjectClassInArray)objectClassInArray;
@end

NS_ASSUME_NONNULL_END
