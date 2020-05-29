//
//  NSObject+MJClass.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 遍历所有类的block (父类)
typedef void (^MJClassesEnumeration)(Class c,BOOL *stop);

/// 这个数组中的属性名 才会进行字典转模型
typedef NSArray * _Nullable (^MJAllowedPropertyNames)(void);

/// 这个数组中的属性名 不会进行字典转模型
typedef NSArray * _Nullable (^MJIgnoredPropertyNames)(void);

/// 这个数组中的属性名 才会进行字典转模型
typedef NSArray * _Nullable (^MJAllowedCodingPropertyNames)(void);

/// 这个数组中的属性名 不会进行字典转模型
typedef NSArray * _Nullable (^MJIgnoredCodingPropertyNames)(void);


/// 类相关的扩展
@interface NSObject (MJClass)

/// 遍历所有的类
/// @param enumeration 遍历的block
+ (void)mj_enumerateClasses:(MJClassesEnumeration)enumeration;
+ (void)mj_enumerateAllClasses:(MJClassesEnumeration)enumeration;


#pragma mark - 属性白名单配置

/// 这个数组中的属性名,才会进行字典转模型
/// @param allowedPropertyNames 遍历的block
+ (void)mj_setupAllowedPropertyNames:(MJAllowedPropertyNames)allowedPropertyNames;
/// 这个数组中的属性名,才会进行字典转模型
+ (NSMutableArray *)mj_totalAllowedPropertyNames;

#pragma mark - 属性黑名单配置

/// 这个数组中的属性名将会被忽略：不进行归档
/// @param ignoredPropertyNames 遍历的block
+ (void)mj_setupIgnoredPropertyNames:(MJIgnoredPropertyNames)ignoredPropertyNames;

/// 这个数组中的属性名将会被忽略：不进行归档
+ (NSMutableArray *)mj_totalIgnoredPropertyNames;

#pragma mark - 归档白名单配置

/// 这个数组中的属性名,才会进行字典转模型
/// @param allowedCodingPropertyNames 遍历的block
+ (void)mj_setupAllowedCodingPropertyNames:(MJAllowedCodingPropertyNames)allowedCodingPropertyNames;
/// 这个数组中的属性名,才会进行字典转模型
+ (NSMutableArray *)mj_totalAllowedCodingPropertyNames;

#pragma mark - 归档黑名单配置

/// 这个数组中的属性名将会被忽略：不进行归档
/// @param ignoredCodingPropertyNames 遍历的block
+ (void)mj_setupIgnoredCodingPropertyNames:(MJIgnoredCodingPropertyNames)ignoredCodingPropertyNames;

/// 这个数组中的属性名将会被忽略：不进行归档
+ (NSMutableArray *)mj_totalIgnoredCodingPropertyNames;


#pragma mark - 内部使用
+ (void)mj_setupBlockReturnValue:(id (^)(void))block key:(const char *)key;

@end

NS_ASSUME_NONNULL_END
