//
//  MJExtensionConst.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/21.
//  Copyright © 2020 10.12. All rights reserved.
//

/// 这是什么类型文件
#ifndef __MJExtensionConst__M__
#define __MJExtensionConst__M__

#import <Foundation/Foundation.h>

#ifndef MJ_LOCK
#define MJ_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef MJ_UNLOCK
#define MJ_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

// 信号量
#define MJExtensionSemaphoreCreate \
static dispatch_semaphore_t signalSemaphore; \
static dispatch_once_t onceTokenSemaphore; \
dispatch_once(&onceTokenSemaphore, ^{ \
    signalSemaphore = dispatch_semaphore_create(1); \
});

#define MJExtensionSemaphoreWait MJ_LOCK(signalSemaphore)
#define MJExtensionSemaphoreSignal MJ_UNLOCK(signalSemaphore)

//MACOS OC 2_0版本引入,3_0版本将作废
#define MJExtensionDeprecated(instead) NS_DEPRECATED(2_0,2_0,3_0,3_0,instead);

///构建错误
#define MJExtensionBuildError(clazz,msg)\
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil];\
[clazz setMj_error:error];

///日志输出
#ifdef DEBUG
#define MJExtensionLog(...) NSLog(__VA_ARGS__)
#else
#define MJExtensionLog(...)
#endif

/**
 *断言
 *@param condition 条件
 *@param returnValue 返回值
 */
#define MJExtensionAssertError(condition,returnValue,clazz,msg)\
[clazz setMj_error:nil];\
if((condition) == NO){\
    MJExtensionBuildError(clazz,msg);\
    return returnValue;\
}

#define MJExtensionAssert2(condition,returnValue)\
if((condition) == NO) return returnValue;

/**
 *断言
 *@param condition 条件
 */
#define MJExtensionAssert(condition) MJExtensionAssert2(condition,)
/**
*断言
*@param condition 条件
*@param returnValue 返回值
*/
#define MJExtensionAssertParamNotNil2(param,returnValue)\
MJExtensionAssert2((param) != nil,returnValue)

///断言
#define MJExtensionAssertParamNotNil(param) MJExtensionAssertParamNotNil2(param,)

#define MJLogAllIvars \
- (NSString *)description \
{ \
    return [self mj_keyValues].description; \
}
#define MJExtensionLogAllProperties MJLogAllIvars

///仅在Debug 展示所有属性
#define MJImplementDebugDescription \
- (NSString *)debugDescription \
{ \
return [self mj_keyValues].debugDescription; \
}

//FOUNDATION_EXPORT 比较变量地址-效率更高
//#define 比较字符串是否相等 -调用 isEqualToString 效率更低
//extern "C" 符合 C的编译规则
//FOUNDATION_EXTERN & FOUNDATION_IMPORT & FOUNDATION_EXPORT 没什么区别

/**
 属性类型
 */
FOUNDATION_EXPORT NSString *const MJPropertyTypeInt;
FOUNDATION_EXPORT NSString *const MJPropertyTypeShort;
FOUNDATION_EXPORT NSString *const MJPropertyTypeFloat;
FOUNDATION_EXPORT NSString *const MJPropertyTypeDouble;
FOUNDATION_EXPORT NSString *const MJPropertyTypeLong;
FOUNDATION_EXPORT NSString *const MJPropertyTypeLongLong;
FOUNDATION_EXPORT NSString *const MJPropertyTypeChar;
FOUNDATION_EXPORT NSString *const MJPropertyTypeBool1;
FOUNDATION_EXPORT NSString *const MJPropertyTypeBool2;
FOUNDATION_EXPORT NSString *const MJPropertyTypePointer;

FOUNDATION_EXPORT NSString *const MJPropertyTypeIvar;
FOUNDATION_EXPORT NSString *const MJPropertyTypeMethod;
FOUNDATION_EXPORT NSString *const MJPropertyTypeBlock;
FOUNDATION_EXPORT NSString *const MJPropertyTypeClass;
FOUNDATION_EXPORT NSString *const MJPropertyTypeSEL;
FOUNDATION_EXPORT NSString *const MJPropertyTypeId;


#endif

