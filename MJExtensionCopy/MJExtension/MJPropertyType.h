//
//  MJPropertyType.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/22.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJPropertyType : NSObject//包装一种类型

/// 类型标识符
@property (nonatomic,strong)NSString *code;

/// 是否为id类型
@property (nonatomic,readonly,getter=isIdType)BOOL idType;

/// 是否为基本数据类型
@property (nonatomic,readonly,getter=isNumberType)BOOL numberType;

/// 是否为bool类型
@property (nonatomic,readonly,getter=isBoolType)BOOL boolType;

/// 对象类型(如果为基本数据类型,此值为nil)
@property (nonatomic,readonly)Class typeClass;

/// 是否来自于Foundation框架
@property (nonatomic,readonly,getter=isFromFoundation)BOOL fromFoundation;

/// 是否支持KVC
@property (nonatomic,readonly,getter=isKVCDisabled)BOOL KVCDisabled;


/// 获得缓存的类型对象
/// @param code 传入的类型
+ (instancetype)cachedTypeWithCode:(NSString *)code;


@end

NS_ASSUME_NONNULL_END
