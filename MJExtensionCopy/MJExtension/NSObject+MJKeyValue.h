//
//  NSObject+MJKeyValue.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/26.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtensionConst.h"
#import <CoreData/CoreData.h>
#import "MJProperty.h"

NS_ASSUME_NONNULL_BEGIN

/// KeyValue协议
@protocol MJKeyValue <NSObject>

@optional

/// 只有这个数组中的属性名才允许字典-模型转换
+ (NSArray *)mj_allowedPropertyNames;

/// 不进行字典转模型的数组
+ (NSArray *)mj_ignoredPropertyNames;

/// 将属性名换成其他key在字典中取值
+ (NSDictionary *)mj_replacedKeyFromPropertyName;

/// 将属性名换成其他key在字典中取值
+ (id )mj_replacedKeyFromPropertyName121:(NSString *)propertyName;

/// 数组中需要转换的模型类
+ (NSDictionary *)mj_objectClassInArray;

/// 字符串格式化的时候使用
+ (NSLocale *)mj_numberLocale;

/// 旧值换成新值-用于过滤字典中的值
/// @param oldValue 旧值
/// @param property 新值
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property;

/// 字典转模型完毕时调用
- (void)mj_keyValueDidFinishConvertingToObject MJExtensionDeprecated("请使用`mj_didConvertToObjectWithKeyValues:`替代");
- (void)mj_keyValueDidFinishConvertingToObject:(NSDictionary *)keyValues MJExtensionDeprecated("请使用`mj_didConvertToObjectWithKeyValues:`替代");
- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues;

- (void)mj_objectDidFinishConvertingToKeyValues MJExtensionDeprecated("请使用`mj_objectDidConvertToKeyValues:`替代");;
- (void)mj_objectDidConvertToKeyValues:(NSMutableDictionary *)keyValues;

@end

@interface NSObject (MJKeyValue) <MJKeyValue>//遵守协议
#pragma mark - 类方法

/// 字典转模型中遇到错误
+ (NSError *)mj_error;

/// 模型转字典时,字典的key是否参考replacedKeyFromPropertyName等方法(父类设置了子类也会集继承下来)
/// @param reference 是否参考
+ (void)mj_refrenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference;

#pragma mark - 对象方法

/// 字典的键值对转换成模型属性
/// @param keyValues 字典(可以是NSDictionary, NSData, NSString)
- (instancetype)mj_setKeyValues:(id)keyValues;

/// 字典的键值对转换成模型属性
/// @param keyValues 字典(可以是NSDictionary, NSData, NSString)
/// @param context CoreData上下文
- (instancetype)mj_setKeyValues:(id)keyValues context:( NSManagedObjectContext  * _Nullable)context;


/// 模型转字典
- (NSMutableDictionary *)mj_keyValues;
- (NSMutableDictionary *)mj_keyValuesWithKeys:(NSArray *)keys;
- (NSMutableDictionary *)mj_keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys;


/// 通过模型数组来创建一个字典数组
/// @param objectArray 模型数组
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray;
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *_Nullable)objectArray keys:(NSArray *_Nullable)keys;
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *_Nullable)objectArray ignoredKeys:(NSArray *_Nullable)ignoredKeys;


#pragma mark - 字典转模型

/// 通过字典创建一个模型
/// @param keyValues 字典(可以是NSDictionary, NSData, NSString)
+ (instancetype)mj_objectWithKeyValues:(id)keyValues;

/// 通过字典创建一个CoreData模型
/// @param keyValues 字典(可以是NSDictionary, NSData, NSString)
/// @param context CoreData 上下文
+ (instancetype)mj_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext * _Nullable)context;

/// 通过plist创建一个模型
/// @param fileName 文件名(仅限于mianBundle中的文件)
+ (instancetype)mj_objectWithFileName:(NSString *)fileName;

/// 通过plist创建一个模型
/// @param file 文件全路径
+ (instancetype)mj_objectWithFile:(NSString *)file;

#pragma mark - 字典数组转模型数组

/// 通过字典数组来创建一个模型数组
/// @param keyValuesArray 字典(可以是NSDictionary, NSData, NSString)
+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray;

/// 通过字典数组来创建一个模型数组
/// @param keyValuesArray 字典(可以是NSDictionary, NSData, NSString)
/// @param context CoreData 上下文
+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext * _Nullable)context;


/// 通过plist创建一个模型
/// @param fileName 文件名(仅限于mianBundle中的文件)
+ (NSMutableArray *)mj_objectArrayWithFileName:(NSString *)fileName;

/// 通过plist创建一个模型
/// @param file 文件全路径
+ (NSMutableArray *)mj_objectArrayWithFile:(NSString *)file;

#pragma mark - 转换为JSON

/// 转换为JSON Data
- (NSData *)mj_JSONData;

/// 转换为字典或数组
- (id)mj_JSONObject;

/// 转换为JSON字符串
- (NSString *)mj_JSONString;
@end

NS_ASSUME_NONNULL_END
