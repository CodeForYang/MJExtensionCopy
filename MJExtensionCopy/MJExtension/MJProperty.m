//
//  MJProperty.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "MJProperty.h"
#import "MJFoundation.h"
#import "MJExtensionConst.h"
#import <objc/message.h>
#include "TargetConditionals.h"
@interface MJProperty()
@property (nonatomic,strong)NSMutableDictionary *propertyKeysDict;//保存多级key的字典,MJPerson-NSArray/ MJPerson-NSDictionary
@property (nonatomic,strong)NSMutableDictionary *objectClassInArrayDict;
@property (nonatomic,strong)dispatch_semaphore_t propertyKeysLock;
@property (nonatomic,strong)dispatch_semaphore_t objectClassInArrayLock;
@end

@implementation MJProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyKeysDict = [NSMutableDictionary dictionary];
        _objectClassInArrayDict = [NSMutableDictionary dictionary];
        _propertyKeysLock = dispatch_semaphore_create(1);
        _objectClassInArrayLock = dispatch_semaphore_create(1);


    }
    return self;
}

#pragma mark - 缓存

/// 缓存关联对象
/// @param property 需要关联的属性
+ (instancetype)cachedPropertyWithProperty:(objc_property_t)property{
    MJProperty *propertyObj = objc_getAssociatedObject(self, property);
    if (propertyObj == nil) {
        propertyObj = [[self alloc]init];
        propertyObj.property = property;
        objc_setAssociatedObject(self, property, propertyObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return propertyObj;
}

- (void)setProperty:(objc_property_t)property{
    _property = property;
    
    MJExtensionAssertParamNotNil(property);
    
    //属性名
    _name = @(property_getName(property));//const char -->NSString
    
    //成员类型 - Returns the attribute string of a property.
    NSString *attrs = @(property_getAttributes(property));//TB,N,V_isMarried
    NSUInteger dotLoc = [attrs rangeOfString:@","].location;
    NSString *code = nil;
    NSUInteger loc = 1;
    if (dotLoc == NSNotFound) {
        code = [attrs substringFromIndex:loc];
    }else{
        code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
    }
    //缓存属性类型
    _type = [MJPropertyType cachedTypeWithCode:code];////缓存这个属性的类型BOOL,NSString...
    
}

/// 获得成员变量的值
/// @param object 目标对象
- (id)valueForObject:(id)object{
#pragma mark - 返回nil可以吗???
    if(self.type.KVCDisabled) return [NSNull null];
    
    id value = [object valueForKey:self.name];
#if defined(__arm__) || (TARGET_OS_SIMULATOR && !__LP64__)
    if (self.type.isBoolType) {
        value = @([(NSNumber *)value boolValue]);
    }
#endif
    
    return value;
}

/// 设置成员变量的值--这是最后一步
/// @param value 设置的值
/// @param object 目标对象
- (void)setValue:(id)value forObject:(id)object{
    if (self.type.KVCDisabled || value == nil) return;
    [object setValue:value forKey:self.name];
}

/// 根据字符串key 创建对应的keys
/// @param stringKey 字符串key
- (NSArray *)propertyKeysWithStringKey:(NSString *)stringKey{
    if(stringKey.length == 0)return nil;
    
    NSMutableArray *propertyKeys = [NSMutableArray array];
    
    //如果有多级映射
    NSArray *oldKeys = [stringKey componentsSeparatedByString:@"."];
    for (NSString *oldKey in oldKeys) {
        NSUInteger start = [oldKey rangeOfString:@"["].location;//看看有没有多级映射的key-数组类,比如@"name":@"studentsArray[1].name"
        if (start != NSNotFound) {
            NSString *prefixKey = [oldKey substringToIndex:start];
            NSString *indexKey = prefixKey;
            if (prefixKey.length) {
                MJPropertyKey *propertyKey = [[MJPropertyKey alloc]init];
                propertyKey.name = prefixKey;
                [propertyKeys addObject:propertyKey];
                indexKey = [oldKey stringByReplacingOccurrencesOfString:prefixKey withString:@""];//字符串处理成-->[1]
            }
            //拿到数组索引-取出后数组两个元素 @[@"1",@""]
            NSArray *cmps = [[indexKey stringByReplacingOccurrencesOfString:@"[" withString:@""] componentsSeparatedByString:@"]"];
#pragma mark - 这里就是取数组的索引,为什么不cmps[0],还有下面的循环就只有一个可用元素,为什么要遍历???
            for (int i = 0; i<cmps.count - 1; i++) {
                MJPropertyKey *propertyKey = [[MJPropertyKey alloc]init];
				propertyKey.type = MJPropertyKeyTypeArray;
                propertyKey.name = cmps[i];
                [propertyKeys addObject:propertyKey];
            }
        }else{// 没有索引的key-可能是一级key,也可能是多级key
            MJPropertyKey *propertyKey = [[MJPropertyKey alloc]init];
            propertyKey.name = oldKey;
            [propertyKeys addObject:propertyKey];
        }
    }
    
    return propertyKeys;//这里如果有N多级映射-返回N多个MJPropertyKey,如果只有一级映射,就返回一个元素
}


/// 将字典的key转换成-MJPropertyKey,如果有多级映射,顺便处理
/// @param origionKey json字典的 原始key
/// @param c 模型类
- (void)setOriginKey:(id)origionKey forClass:(Class)c{
    if ([origionKey isKindOfClass:[NSString class]]) {//-字符串类型的key
        NSArray *propertyKeys = [self propertyKeysWithStringKey:origionKey];//包装成MJPropertyKey
        [self setPorpertyKeys:@[propertyKeys] forClass:c];
    }else if ([origionKey isKindOfClass:[NSArray class]]){//可能有
#pragma mark - 这里什么情况下会是数组内容
        NSMutableArray *keyses = [NSMutableArray array];
        for (NSString *stringKey in origionKey) {
             NSArray *propertyKeys = [self propertyKeysWithStringKey:stringKey];
            if(propertyKeys.count) [keyses addObject:propertyKeys];
        }
        if(keyses.count) [self setPorpertyKeys:keyses forClass:c];
    }
}

/// 将属性保存在字典中
/// @param propertyKeys 属性名
/// @param c 属性所属的类
- (void)setPorpertyKeys:(NSArray *)propertyKeys forClass:(Class)c{
    if(propertyKeys.count == 0) return;
    NSString *key = NSStringFromClass(c);//对应的模型类取出作为key
    if(!key) return;
    
    MJ_LOCK(self.propertyKeysLock);//为属性key加锁
    self.propertyKeysDict[key] = propertyKeys;//类名为key,属性名为值
    MJ_UNLOCK(self.propertyKeysLock);
}


/// 给定一个类,取出它包含的所有MJPropertyKey
/// @param c 模型类
- (NSArray *)propertyKeysForClass:(Class)c{
    
    NSString *key = NSStringFromClass(c);//对应的模型类取出作为key
    if(!key) return nil;
    MJ_LOCK(self.propertyKeysLock);//为属性key加锁
    NSArray *propertyKeys = self.propertyKeysDict[key];
    MJ_UNLOCK(self.propertyKeysLock);
    return propertyKeys;
}


/// 处理数组里面包含模型的情况-通过调用"mj_objectClassInArray",返回一个映射关系@"studentsArray":@"MJStudent",MJPerson的某个属性数组(studentsArray)包含MJStudent
/// @param objectClass 被包含的类-MJStudent
/// @param c 包含的类MJPerson
- (void)setObjectClassInArray:(Class)objectClass forClass:(Class)c{
    if(!objectClass) return;
    NSString *key = NSStringFromClass(c);
    if(!key) return;
    MJ_LOCK(self.objectClassInArrayLock);
    self.objectClassInArrayDict[key] = objectClass;
    MJ_UNLOCK(self.objectClassInArrayLock);
    
}



/// 给我一个MJProperty,根据它里面的name属性有没有映射的数组,如果有,返回对应需要转换的模型类,例如 studentsArray - MJStudent,如果没有返回nil
/// @param c 转换的当前模型类
- (Class )objectClassInArrayForClass:(Class)c{
    NSString *key = NSStringFromClass(c);
    if(!key) return nil;
    MJ_LOCK(self.objectClassInArrayLock);
    Class objectClass = self.objectClassInArrayDict[key];
    MJ_UNLOCK(self.objectClassInArrayLock);
    return objectClass;
}
@end
