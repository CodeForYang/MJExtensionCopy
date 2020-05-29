//
//  NSObject+MJClass.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "NSObject+MJClass.h"
#import "NSObject+MJCoding.h"
#import "NSObject+MJKeyValue.h"
#import "MJFoundation.h"
#import <objc/runtime.h>

static const char MJAllowedPropertyNamesKey = '\0';
static const char MJIgnoredPropertyNamesKey = '\0';
static const char MJAllowedCodingPropertyNamesKey = '\0';
static const char MJIgnoredCodingPropertyNamesKey = '\0';

@implementation NSObject (MJClass)

+ (NSMutableDictionary *)mj_classDictForKey:(const void *)key
{
    static NSMutableDictionary *allowedPropertyNamesDict;
    static NSMutableDictionary *ignoredPropertyNamesDict;
    static NSMutableDictionary *allowedCodingPropertyNamesDict;
    static NSMutableDictionary *ignoredCodingPropertyNamesDict;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedPropertyNamesDict = [NSMutableDictionary dictionary];
        ignoredPropertyNamesDict = [NSMutableDictionary dictionary];
        allowedCodingPropertyNamesDict = [NSMutableDictionary dictionary];
        ignoredCodingPropertyNamesDict = [NSMutableDictionary dictionary];
    });
    
    if (key == &MJAllowedPropertyNamesKey) return allowedPropertyNamesDict;
    if (key == &MJIgnoredPropertyNamesKey) return ignoredPropertyNamesDict;
    if (key == &MJAllowedCodingPropertyNamesKey) return allowedCodingPropertyNamesDict;
    if (key == &MJIgnoredCodingPropertyNamesKey) return ignoredCodingPropertyNamesDict;
    return nil;
}

+ (void)mj_enumerateClasses:(MJClassesEnumeration)enumeration{
    //没有block直接返回
    if(!enumeration) return;
    
    //停止遍历的标记
    BOOL stop = NO;
    
    //当前正在遍历的类
    Class c = self;
    
    //开始遍历每一个类
    while (c && !stop) {
        //执行操作
        enumeration(c,&stop);
        //获得父类
        c = class_getSuperclass(c);//-顺着superClass指针向上遍历,直到遍历到系统类为止
        
        if([MJFoundation isClassFromFoundation:c]) break;//-遍历到系统类就停止
    }
    
}

+ (void)mj_enumerateAllClasses:(MJClassesEnumeration)enumeration{
    //没有block直接返回
    if(!enumeration) return;
    
    //停止遍历的标记
    BOOL stop = NO;
    
    //当前正在遍历的类
    Class c = self;
    
    //开始遍历每一个类
    while (c && !stop) {
        //执行操作
        enumeration(c,&stop);
        //获得父类
        c = class_getSuperclass(c);//-顺着superClass指针向上遍历,直到遍历到系统类为止
    }
    
}

#pragma mark - 属性黑名单配置

+ (void)mj_setupIgnoredPropertyNames:(MJIgnoredPropertyNames)ignoredPropertyNames{
    //将block传递过去-并把MJIgnoredPropertyNamesKey地址值传过去
    [self mj_setupBlockReturnValue:ignoredPropertyNames key:&MJIgnoredPropertyNamesKey];
}

+ (NSMutableArray *)mj_totalIgnoredPropertyNames{
    return [self mj_totalObjectWithSelector:@selector(mj_ignoredPropertyNames) key:&MJIgnoredPropertyNamesKey];
}

#pragma mark - 归档属性黑名单配置

+ (void)mj_setupIgnoredCodingPropertyNames:(MJIgnoredCodingPropertyNames)ignoredCodingPropertyNames{
    [self mj_setupBlockReturnValue:ignoredCodingPropertyNames key:&MJIgnoredCodingPropertyNamesKey];
}

+ (NSMutableArray *)mj_totalIgnoredCodingPropertyNames{
    return [self mj_totalObjectWithSelector:@selector(mj_ignoredCodingPropertyNames) key:&MJIgnoredCodingPropertyNamesKey];
}
#pragma mark - 属性白名单配置
+ (void)mj_setupAllowedPropertyNames:(MJAllowedPropertyNames)allowedPropertyNames{
    [self mj_setupBlockReturnValue:allowedPropertyNames key:&MJAllowedPropertyNamesKey];
}

+ (NSMutableArray *)mj_totalAllowedPropertyNames{
    return [self mj_totalObjectWithSelector:@selector(mj_allowedPropertyNames) key:&MJAllowedPropertyNamesKey];

}
#pragma mark - 归档属性白名单配置
+ (void)mj_setupAllowedCodingPropertyNames:(MJAllowedCodingPropertyNames)allowedCodingPropertyNames{
    [self mj_setupBlockReturnValue:allowedCodingPropertyNames key:&MJAllowedCodingPropertyNamesKey];
}

+ (NSMutableArray *)mj_totalAllowedCodingPropertyNames{
    return [self mj_totalObjectWithSelector:@selector(mj_allowedCodingPropertyNames) key:&MJAllowedCodingPropertyNamesKey];
}




///  归档属性以及属性的白黑名单配置
/// @param selector 属性或归档属性调用的方法
/// @param key 属性或归档属性对应的key
+ (NSMutableArray *)mj_totalObjectWithSelector:(SEL)selector key:(const char *)key{
    MJExtensionSemaphoreCreat
    MJExtensionSemaphoreWait
    NSMutableArray *array = [self mj_classDictForKey:key][NSStringFromClass(self)];
    if (array == nil) {
        [self mj_classDictForKey:key][NSStringFromClass(self)] = array = [NSMutableArray array];
        
        if ([self respondsToSelector:selector]) {//-如果有实现允许转换/忽略属性的方法, 则调用它
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSArray *subArray = [self performSelector:selector];
#pragma clang diagnostic pop
            if (subArray) {
                [array addObjectsFromArray:subArray];
            }
        }
        
        [self mj_enumerateAllClasses:^(Class  _Nonnull __unsafe_unretained c, BOOL * _Nonnull stop) {
            NSArray *subArray = objc_getAssociatedObject(c, key);
            [array addObjectsFromArray:subArray];
        }];
        
    }
    
    MJExtensionSemaphoreSignal
    return array;
}
#pragma mark - block 和方法处理:存储block的返回值
+ (void)mj_setupBlockReturnValue:(id  _Nonnull (^)(void))block key:(const char *)key{
    if (block) {
        objc_setAssociatedObject(self,key ,block(),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else{//删除block关联
        objc_setAssociatedObject(self,key ,nil,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    //清空数据
    MJExtensionSemaphoreCreat
    MJExtensionSemaphoreWait
    [[self mj_classDictForKey:key] removeAllObjects];//删除对应字典存的值
    MJExtensionSemaphoreSignal
}
@end
