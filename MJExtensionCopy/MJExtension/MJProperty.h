//
//  MJProperty.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MJPropertyType.h"
#import "MJPropertyKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJProperty : NSObject

/// 成员属性
@property (nonatomic,assign)objc_property_t property;
/// 成员属性的名字
@property (nonatomic,readonly)NSString *name;

/// 成员属性的类型
@property (nonatomic,readonly)MJPropertyType *type;

#pragma mark -- Class 用 strong 或者其他修饰可以吗??? --Class是一个结构体指针,strong也应该可以,
/// 成员属性来源于哪个类 (可能是父类)
@property (nonatomic,assign)Class srcClass;

/// 同一个成员属性-父类和子类的行为可能不一致(originKey, propertyKeys, objectClassInArray)
/// @param origionKey 设置最原始的key
/// @param c key对应的类
- (void)setOriginKey:(id)origionKey forClass:(Class)c;

/// 对应着字典中的多级key(数组里面都是MJProperty对象)
/// @param c 需要遍历的类
- (NSArray *)propertyKeysForClass:(Class)c;

/// 模型数组中的模型类
/// @param objectClass 对应的类
/// @param c c
- (void)setObjectClassInArray:(Class)objectClass forClass:(Class)c;
- (Class )objectClassInArrayForClass:(Class)c;
///设置object的成员变量值
- (void)setValue:(id)value forObject:(id )object;

/// 得到object的成员属性值
/// @param object 传递的object
- (id)valueForObject:(id)object;

/// 初始化
/// @param property 初始化的属性
+(instancetype)cachedPropertyWithProperty:(objc_property_t)property;
@end

NS_ASSUME_NONNULL_END
