//
//  NSObject+MJProperty.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "NSObject+MJProperty.h"
#import "NSObject+MJKeyValue.h"
#import "NSObject+MJCoding.h"
#import "NSObject+MJClass.h"
#import "MJProperty.h"
#import "MJFoundation.h"
#import <objc/runtime.h>


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static const char MJReplacedKeyFromPropertyNameKey = '\0';
static const char MJReplacedKeyFromPropertyName121Key = '\0';
static const char MJNewValueFromOldValueKey = '\0';
static const char MJObjectClassInArraykey = '\0';
static const char MJCachedPropertiesKey = '\0';

@implementation NSObject (MJProperty)

/// 创建数个可变字典-存储转换所需信息
/// @param key 根据这个key返回对应字典
+ (NSMutableDictionary *)mj_propertyDictForKey:(const void *)key{
    static NSMutableDictionary *MJReplacedKeyFromPropertyNameDict;
    static NSMutableDictionary *MJReplacedKeyFromPropertyName121Dict;
    static NSMutableDictionary *MJNewValueFromOldValueDict;
    static NSMutableDictionary *MJObjectClassInArrayDict;
    static NSMutableDictionary *MJCachedPropertiesDict;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MJReplacedKeyFromPropertyNameDict = [NSMutableDictionary dictionary];
        MJReplacedKeyFromPropertyName121Dict = [NSMutableDictionary dictionary];
        MJNewValueFromOldValueDict = [NSMutableDictionary dictionary];
        MJObjectClassInArrayDict = [NSMutableDictionary dictionary];
        MJCachedPropertiesDict = [NSMutableDictionary dictionary];

    });
    
    if(key == &MJReplacedKeyFromPropertyNameKey) return MJReplacedKeyFromPropertyNameDict;
    if(key == &MJReplacedKeyFromPropertyName121Key) return MJReplacedKeyFromPropertyName121Dict;
    if(key == &MJNewValueFromOldValueKey) return MJNewValueFromOldValueDict;
    if(key == &MJObjectClassInArraykey) return MJObjectClassInArrayDict;
    if(key == &MJCachedPropertiesKey) return MJCachedPropertiesDict;

    return nil;
}

#pragma mark - 私有方法

/// 这整个方法就是查看外界有没有实现属性替换的方法,如果有-替换原来的key,如果没有-用原来的key
/// @param propertyName 属性名
+ (id)mj_propertyKey:(NSString *)propertyName{
    MJExtensionAssertParamNotNil2(propertyName, nil);//判空处理
    
    __block id key = nil;
    
    if([self respondsToSelector:@selector(mj_replacedKeyFromPropertyName121:)]){
        //@interface NSObject (MJKeyValue) <MJKeyValue>//遵守协议 否则无法调用
        key = [self mj_replacedKeyFromPropertyName121:propertyName];//没有替换的属性
    }
    
    //调用block
    if(!key){
        //这个方法
        [self mj_enumerateAllClasses:^(Class  _Nonnull __unsafe_unretained c, BOOL * _Nonnull stop) {
            //调用mj_setupReplacedKeyFromPropertyName121 这个方法的时候就缓存了这个block,返回值为id类型
            //这个block是需要用户自己实现,里面返回值就是需要替换的block
            MJReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyName121Key);//-拿到缓存的block
            if(block){
                key = block(propertyName);//-传入需要替换的类名,返回替换好的key
            }
            if(key) *stop = YES;
        }];
    }
    
    //查看有没有需要替换的key
    if((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(mj_replacedKeyFromPropertyName)]){
        key = [self mj_replacedKeyFromPropertyName][propertyName];
    }
    
    if (!key || [key isEqual:propertyName]) {//这个跟上面的方法调用逻辑同理
        [self mj_enumerateAllClasses:^(Class  _Nonnull __unsafe_unretained c, BOOL * _Nonnull stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyNameKey);
            if(dict){
                key = dict[propertyName];
            }
            if(key && ![key isEqual:propertyName]) *stop = YES;
        }];
    }
    
    
    // 如果没有替换的,就用回原来的key
    if(!key) key = propertyName;
    return key;
}



/// 检查是否有数组里面包含模型
/// @param propertyName 属性名
+ (Class)mj_propertyObjectClassInArray:(NSString *)propertyName{
    __block id clazz = nil;
    if ([self respondsToSelector:@selector(mj_objectClassInArray)]) {
        //模型包含模型-根据多级映射的key取值,@"studentsArray":@"MJStudent" 告诉它属性数组(studentsArray) 里面装的是MJStudent模型类
        clazz = [self mj_objectClassInArray][propertyName];
    }
    
    if(!clazz){
        [self mj_enumerateAllClasses:^(Class  _Nonnull __unsafe_unretained c, BOOL * _Nonnull stop) {
            //检查外面是否手动实现mj_setupObjectClassInArray
            NSDictionary *dict = objc_getAssociatedObject(c, &MJObjectClassInArraykey);
            if(dict) clazz = dict[propertyName];
            if(clazz) *stop = YES;
        }];
    }
    
    //如果clazz是字符串,转成类
    if([clazz isKindOfClass:[NSString class]]) clazz = NSClassFromString(propertyName);
    
    return clazz;
}

#pragma mark - --公共方法--
+ (void)mj_enumerateProperties:(MJPropertiesEnumeration)enumeration{
    //获得成员变量
    MJExtensionSemaphoreCreat
    MJExtensionSemaphoreWait
    NSArray *cachedProperties = [self mj_properties];//检查是否有 忽略,替换的属性,都处理好再遍历
    MJExtensionSemaphoreSignal
    
    BOOL stop = NO;//开始遍历所有成员变量
    for (MJProperty *property in cachedProperties) {
        enumeration(property,&stop);
        if(stop) break;
    }
}


/// -在用属性遍历之前,我先检查有没有需要替换的key,有的话我先替换,之后再用替换之后的属性遍历,(比如id->ID)
/// 筛选掉不符合的类型,比如系统的基类,系统的协议类
+ (NSMutableArray *)mj_properties{
    //-传入key,返回对应字典,字典的key 是MJPerson,value 是cachedProperties
    NSMutableArray *cachedProperties = [self mj_propertyDictForKey:&MJCachedPropertiesKey][NSStringFromClass(self)];
    if(cachedProperties == nil){
        cachedProperties = [NSMutableArray array];
        
        [self mj_enumerateClasses:^(Class  _Nonnull __unsafe_unretained c, BOOL * _Nonnull stop) {
            //获得所有成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            //遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                // 为每个属性创建一个MJProperty类,里面标记它源自哪个类,是否支持KVC等信息
                MJProperty *property = [MJProperty cachedPropertyWithProperty:properties[i]];
                //过滤掉源自Foundation框架的属性
                if([MJFoundation isClassFromFoundation:property.srcClass]) continue;
                //过滤掉 'hash', 'superclass', 'description', 'debugDescription'
                if ([MJFoundation isFromNSObjectProtocolProperty:property.name]) continue;
                
                property.srcClass = c;
                //生成MJPropertyKey,处理映射-多级映射的情况
                [property setOriginKey:[self mj_propertyKey:property.name] forClass:self];
                //处理属性包含数组模型的情况
                [property setObjectClassInArray:[self mj_propertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            free(properties);
        }];
        
        [self mj_propertyDictForKey:&MJCachedPropertiesKey][NSStringFromClass(self)] = cachedProperties;
    }
    
    return cachedProperties;
}


#pragma mark - 新值配置
+ (void)mj_setupNewValueFromOldValue:(MJNewValueFromOldValue)newValueFromOldValue{
    objc_setAssociatedObject(self, &MJNewValueFromOldValueKey, newValueFromOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)mj_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(MJProperty *__unsafe_unretained)property{
    //如果有实现方法
    if([object respondsToSelector:@selector(mj_newValueFromOldValue:property:)]){
        return [object mj_newValueFromOldValue:oldValue property:property];
    }
    
    //查看静态设置
    __block id newValue = oldValue;
    [self mj_enumerateAllClasses:^(Class  _Nonnull __unsafe_unretained c, BOOL * _Nonnull stop) {
        MJNewValueFromOldValue block = objc_getAssociatedObject(c, &MJNewValueFromOldValueKey);
        if (block) {
            
            newValue = block(object, oldValue, property);//
            *stop = YES;
        }
    }];
    
    return newValue;
}

#pragma mark - array model class配置---
+ (void)mj_setupObjectClassInArray:(MJObjectClassInArray)objectClassInArray{
    [self mj_setupBlockReturnValue:objectClassInArray key:&MJObjectClassInArraykey];
    //TODO:
    MJExtensionSemaphoreCreat
    MJExtensionSemaphoreWait
    [[self mj_propertyDictForKey:&MJCachedPropertiesKey] removeAllObjects];
    MJExtensionSemaphoreSignal
}

#pragma mark - key配置
+ (void)mj_setupReplacedKeyFromPropertyName:(MJReplacedKeyFromPropertyName)ReplacedKeyFromPropertyName{
    [self mj_setupBlockReturnValue:ReplacedKeyFromPropertyName key:&MJReplacedKeyFromPropertyNameKey];
    
    MJExtensionSemaphoreCreat
    MJExtensionSemaphoreWait
    [[self mj_propertyDictForKey:&MJCachedPropertiesKey] removeAllObjects];
    MJExtensionSemaphoreSignal
}

+ (void)mj_setupReplacedKeyFromPropertyName121:(MJReplacedKeyFromPropertyName121)ReplacedKeyFromPropertyName121{
    objc_setAssociatedObject(self, &MJReplacedKeyFromPropertyName121Key, ReplacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    MJExtensionSemaphoreCreat
    MJExtensionSemaphoreWait
    [[self mj_propertyDictForKey:&MJCachedPropertiesKey] removeAllObjects];
    MJExtensionSemaphoreSignal
}

@end
