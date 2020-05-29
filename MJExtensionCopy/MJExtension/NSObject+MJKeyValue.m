//
//  NSObject+MJKeyValue.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/26.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "NSObject+MJKeyValue.h"
#import "NSObject+MJProperty.h"
#import "NSString+MJExtension.h"
#import "MJProperty.h"
#import "MJPropertyType.h"
#import "MJExtensionConst.h"
#import "MJFoundation.h"
#import "NSObject+MJClass.h"

//这里实现了一个NSDecimalNumber的分类
@implementation NSDecimalNumber(MJKeyValue)

- (id)standardValueWithTypeCode:(NSString *)typeCode{
    //这里涉及到编译器问题,暂时保留 Long,实际上在 64 位系统上,这 2 个经度范围相同,
    //32 位略有不同,其余都可使用 Double 进行强转 不丢失经度
    
    if([typeCode isEqualToString:MJPropertyTypeLongLong]){//q
        return @(self.longLongValue);
    }else if([typeCode isEqualToString:MJPropertyTypeLongLong.uppercaseString]){//Q
        return @(self.unsignedLongLongValue);
    }else if ([typeCode isEqualToString:MJPropertyTypeLong]){//l
        return @(self.longValue);
    }else if ([typeCode isEqualToString:MJPropertyTypeLong.uppercaseString]){//L
        return @(self.unsignedLongValue);
    }else{
        return @(self.doubleValue);
    }
    
}

@end

@implementation NSObject (MJKeyValue)

#pragma mark - 错误
static const char MJErrorKey = '\0';
+ (NSError *)mj_error{
    return objc_getAssociatedObject(self, &MJErrorKey);
}
+ (void)setMj_error:(NSError *)error{
    objc_setAssociatedObject(self, &MJErrorKey, error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 模型 ->字典时的参考
// 模型转字典时,字典的key是否参考replacedKeyFromPropertyName等方法(父类设置了子类也会继承下来)
static const char MJRefremceReplacedKeyWhenCreatingKeyValuesKey = '\0';

+ (void)mj_refrenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference{
    objc_setAssociatedObject(self, &MJRefremceReplacedKeyWhenCreatingKeyValuesKey, @(reference), OBJC_ASSOCIATION_ASSIGN);
}


+ (BOOL)mj_isReferenceReplacedKeyWhenCreatingKeyValues
{    __block id value = objc_getAssociatedObject(self, &MJRefremceReplacedKeyWhenCreatingKeyValuesKey);
    if (!value) {
        [self mj_enumerateAllClasses:^(Class  _Nonnull __unsafe_unretained c, BOOL * _Nonnull stop) {
            value = objc_getAssociatedObject(c, &MJRefremceReplacedKeyWhenCreatingKeyValuesKey);
            if(value) *stop = YES;
        }];
    }
    return [value boolValue];
}

#pragma mark - --常用对象--
+(void)load{
    //默认设置
    [self mj_refrenceReplacedKeyWhenCreatingKeyValues:YES];
}

#pragma mark - --公共方法--
#pragma mark - 字典 -> 模型
- (instancetype)mj_setKeyValues:(id)keyValues{
    
    return [self mj_setKeyValues:keyValues context:nil];
}

#pragma mark - --核心代码--

/// 核心代码
/// @param keyValues 转换的字典
/// @param context 上下文
- (instancetype)mj_setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context{
    //获得JSON对象
    keyValues = [keyValues mj_JSONObject];//NSDictionary
    MJExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], self, [self class], @"keyValue不是一个字典");
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz mj_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz mj_totalIgnoredPropertyNames];
    
    NSLocale *numberLocale = nil;
    if ([[self class] respondsToSelector:@selector(mj_numberLocale)]) {
        numberLocale = self.class.mj_numberLocale;//特殊地区,字符串格式化
    }
    
    //通过封装的方法回调一个通过运行时编写的,用于返回属性列表的方法
    [clazz mj_enumerateProperties:^(MJProperty * _Nonnull property, BOOL * _Nonnull stop) {
        @try{//这里获得的都是符合要求的属性,遍历开始赋值
            //0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name])return;//-允许的属性有值 && 这个属性被包含在 allowedPropertyNames里--🙅遍历
            if([ignoredPropertyNames containsObject:property.name]) return;
            
            //1.取出属性值
            id value;
            NSArray *propertyKeyses = [property propertyKeysForClass:clazz];//根据@"MJPerson"从字典中取出MJPropertyKey数组
            for (NSArray *propertyKeys in propertyKeyses) {//包装的时候都是两层数组
                value = keyValues;
                for (MJPropertyKey *propertyKey in propertyKeys) {
                    value = [propertyKey valueInObject:value];
                }
                if(value)break;//取出来的就是属性值 @"西西里的美丽传说"
            }
            
            //外界是否有实现mj_newValueFromOldValue方法,有则替换新值
            id newValue = [clazz mj_getNewValueFromObject:self oldValue:value property:property];
            if (newValue != value) {
                [property setValue:newValue forObject:self];//直接替换旧值
                return;
            }
            
            //nil,null区别,nil针对变量, null针对类
            if(!value || value == [NSNull null]) return;
            
            //2.复杂处理
            MJPropertyType *type = property.type;
            Class propertyClass = type.typeClass;
            //查看是否有数组包含模型的情况,如果有,则返回模型类名,如果没有,返回nil
            Class objectClass = [property objectClassInArrayForClass:[self class]];
            
            //不可变 -> 可变
            if(propertyClass == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]){
                value = [NSMutableArray arrayWithArray:value];
            }else if (propertyClass == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]){
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            }else if (propertyClass == [NSMutableString class] && [value isKindOfClass:[NSString class]]){
                value = [NSMutableString stringWithString:value];
            }else if (propertyClass == [NSMutableData class] && [value isKindOfClass:[NSData class]]){
                value = [NSMutableData dataWithData:value];
            }

            if (!type.isFromFoundation && propertyClass) {
#pragma mark - 这句不是很理解??? -这是一个自建的类吗?
                value = [propertyClass mj_objectWithKeyValues:value context:context];
            }else if(objectClass){
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    //string array -> url array
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:string.mj_url];//数组里面是url
                    }
                    value = urlArray;
                }else{//字典数组 -> 模型数组
                    value = [objectClass mj_objectArrayWithKeyValuesArray:value context:context];
                }
            }else if (propertyClass == [NSString class]){
                if ([value isKindOfClass:[NSNumber class]]) {
                    //NSNumber -> NSString
                    value = [value description];
                }else if ([value isKindOfClass:[NSURL class]]){
                    //NSURL -> NSString
                    value = [value absoluteString];
                }
            }else if ([value isKindOfClass:[NSString class]]){
                if (propertyClass == [NSURL class]) {
                    //NSString -> NSURL  字符串编码
                    value = [value mj_url];
                }else if (type.isNumberType){//是否为基本数据类型
                    NSString *oldValue = value;
                    //NSString -> NSDecimalNumber(精度计算的类,防止在计算过程中丢失精度)
                    //使用 DecimalNumber 转换数字,避免丢失精度以及溢出
                    NSDecimalNumber *decimalValue = [NSDecimalNumber decimalNumberWithString:oldValue locale:numberLocale];
                    
                    //检查特殊情况
                    if (decimalValue == NSDecimalNumber.notANumber) {//false
                        value = @(0);
                    }else if (propertyClass != [NSDecimalNumber class]){
                        //转换到更高精度 - int也会转成long类型
                        value = [decimalValue standardValueWithTypeCode:type.code];
                    }else{
                        value = decimalValue;
                    }
                    
                    //如果是BOOL
                    if(type.isBoolType){
                        //字符串转BOOL(字符串没有charValue方法)
                        //系统会调用字符串的charValue转为BOOL类型
                        NSString *lower = [oldValue lowercaseString];
                        if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                            value = @YES;
                        }else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]){
                            value = @NO;
                        }

                    }
                }
            }else if ([value isKindOfClass:[NSNumber class]] && propertyClass == [NSDecimalNumber class]){
                //过滤 NSDecimalNumber 类型
                if (![value isKindOfClass:[NSDecimalNumber class]]) {//NSNumber类型转成NSDecimalNumber类型,以提高精度
                    value = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                }
            }
            
            //经过转换后, 最终检查 value 与 property是否匹配
            if (propertyClass && ![value isKindOfClass:propertyClass]) {
                value = nil;
            }
            
            //3.赋值
            [property setValue:value forObject:self];
        }@catch(NSException *exception){
            MJExtensionBuildError([self class], exception.reason);
            MJExtensionLog(@"%@",exception);
        }
    }];

    //转换完毕
    
    if ([self respondsToSelector:@selector(mj_didConvertToObjectWithKeyValues:)]) {
        [self mj_didConvertToObjectWithKeyValues:keyValues];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if([self respondsToSelector:@selector(mj_keyValueDidFinishConvertingToObject:)]){
        [self mj_keyValueDidFinishConvertingToObject:keyValues];
    }
    
    if([self respondsToSelector:@selector(mj_keyValueDidFinishConvertingToObject)]){
        [self mj_keyValueDidFinishConvertingToObject];
    }
#pragma clang diagnostic pop
    return self;
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues{
    return [self mj_objectWithKeyValues:keyValues context:nil];
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context{
    keyValues = [keyValues mj_JSONObject];
    MJExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], nil, [self class], @"keyValues参数不是一个字典");
    if([self isSubclassOfClass:[NSManagedObject class]] && context){
        NSString *entityName = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
        return [[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context] mj_setKeyValues:keyValues context:context];//NSManagedObject
    }
    
    
    return [[[self alloc]init] mj_setKeyValues:keyValues context:context];
}


/// plist -> 模型
/// @param fileName 文件名
+ (instancetype)mj_objectWithFileName:(NSString *)fileName{
    /**
        可以尝试传入文件路径
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fileName]) {
            NSLog(@"文件abc.plist存在");
        }
     */
   
    MJExtensionAssertError(fileName != nil, nil, [self class], @"filename参数为空");
    return [self mj_objectWithFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
}

#pragma -mark -字典数组 -> 模型数组

/// 字典数组 -> 模型数组
/// @param keyValuesArray 字典数组
+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:nil];
}


/// 字典数组 -> 模型数组
/// @param keyValuesArray 字典数组
/// @param context NSManagedObjectContext
+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context{
    //如果是JSON字符串
    keyValuesArray = [keyValuesArray mj_JSONObject];
    
    //1.判断真实性
    MJExtensionAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, [self class], @"keyValuesArray不是一个数组");
    
    //如果数组里面是NSString, NSNumber等数据
    if([MJFoundation isClassFromFoundation:self]) return [NSMutableArray arrayWithArray:keyValuesArray];
    
    //2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    //3. 遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:[NSArray class]]) {//递归调用,解析数组里面包含模型的情况
            [modelArray addObject:[self mj_objectArrayWithKeyValuesArray:keyValues context:context]];
        }else{
            id model = [self mj_objectWithKeyValues:keyValues context:context];
            if(model) [modelArray addObject:model];
        }
    }
   
    return modelArray;
}

/// plist文件数组 -> 模型数组
/// @param fileName plist文件名
+ (NSMutableArray *)mj_objectArrayWithFileName:(NSString *)fileName{
    MJExtensionAssertError(fileName != nil, nil, [self class], @"fileName参数为nil");

    return [self mj_objectArrayWithFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
}


/// plist文件数组 -> 模型数组
/// @param file 文件路径
+ (NSMutableArray *)mj_objectArrayWithFile:(NSString *)file{
    MJExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    return [self mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file]];
}

#pragma mark - 模型 ->字典
- (NSMutableDictionary *)mj_keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys{
    return [self mj_keyValuesWithKeys:nil ignoredKeys:ignoredKeys];
}
- (NSMutableDictionary *)mj_keyValuesWithKeys:(NSArray *)keys{
    return [self mj_keyValuesWithKeys:keys ignoredKeys:nil];
}
- (NSMutableDictionary *)mj_keyValues{
    return [self mj_keyValuesWithKeys:nil ignoredKeys:nil];
}

/// 模型数组转字典
/// @param keys 可以转换的模型数组
/// @param ignoredKeys 忽略的模型数组
- (NSMutableDictionary *)mj_keyValuesWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys{
    
    //如果自己不是模型类,那就返回自己
    //模型类过滤掉 NSNull
    //唯一一个不返回自己的
    if([self isMemberOfClass:NSNull.class]) return nil;
    //这里虽然返回了自己,但是其实是由报错信息的.
    //TODO: 报错机制不好,需要重做
    MJExtensionAssertError(![MJFoundation isClassFromFoundation:[self class]], (NSMutableDictionary *)self, [self class], @"不是自定义模型类");
    
    id keyValues = [NSMutableDictionary dictionary];
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz mj_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz mj_totalIgnoredPropertyNames];
    [clazz mj_enumerateProperties:^(MJProperty * _Nonnull property, BOOL * _Nonnull stop) {
        @try {
            //0.检测是否被忽略
            if(allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if([ignoredPropertyNames containsObject:property.name]) return;
            if(keys.count && ![keys containsObject:property.name]) return;
            if([ignoredKeys containsObject:property.name]) return;

            //1.取出属性值
            id value = [property valueForObject:self];
            if(!value) return;
            
            //2.如果是模型属性
            MJPropertyType *type = property.type;
            Class propertyClass = type.typeClass;//对象类型
            if (!type.isFromFoundation && propertyClass) {
                value = [value mj_keyValues];//递归
            }else if ([value isKindOfClass:[NSArray class]]){
                //3.处理数组里面有模型的情况
#pragma mark - 为什么不是 self 调用这个方法??? <--> 其实也没区别-最终还是由NSObject来调用的
                //value = [self mj_keyValuesArrayWithObjectArray:value];
                value = [NSObject mj_keyValuesArrayWithObjectArray:value];
            }else if(propertyClass == [NSURL class]){
                value = [value absoluteString];
            }
            
            //4.赋值
            if ([clazz mj_isReferenceReplacedKeyWhenCreatingKeyValues]) {//这里有点懵???
                NSArray *propertyKeys = [property propertyKeysForClass:clazz].firstObject;
                NSUInteger keyCount = propertyKeys.count;
                //创建字典
                __block id innerContainer = keyValues;
                [propertyKeys enumerateObjectsUsingBlock:^(MJPropertyKey *propertyKey, NSUInteger idx, BOOL * _Nonnull stop) {
                    MJPropertyKey *nextPropertyKey = nil;
                    if (idx != keyCount - 1) {//不是最后一个
                        nextPropertyKey = propertyKeys[idx + 1];//下一个属性
                    }
                    
                    if (nextPropertyKey) {//不是最后一个key
                        //当前propertyKey对应的字典或者数组
                        id tempInnerContainer = [propertyKey valueInObject:innerContainer];
                        if (tempInnerContainer == nil || [tempInnerContainer isKindOfClass:[NSNull class]]) {
                            if (nextPropertyKey.type == MJPropertyKeyTypeDictionary) {
                                tempInnerContainer = [NSMutableDictionary dictionary];
                            }else{
                                tempInnerContainer = [NSMutableArray array];
                            }
                            
                            if (propertyKey.type == MJPropertyKeyTypeDictionary) {
                                innerContainer[propertyKey.name] = tempInnerContainer;
                            }else{
                                innerContainer[propertyKey.name.intValue] = tempInnerContainer;
                            }
                        }
                        
                        //如果是数组,证明多级映射是取的数组里面的值- @"name" : @"studentsArray[1].name"
                        if ([tempInnerContainer isKindOfClass:[NSMutableArray class]]) {
                            NSMutableArray *tempInnerContainerArray = tempInnerContainer;
                            int index = nextPropertyKey.name.intValue;
                            while (tempInnerContainerArray.count < index + 1) {//加一堆null干嘛 ???
                                [tempInnerContainerArray addObject:[NSNull null]];
                            }
                        }
                        
                        innerContainer = tempInnerContainer;
                    } else { // 最后一个key
                        if (propertyKey.type == MJPropertyKeyTypeDictionary) {
                            innerContainer[propertyKey.name] = value;
                        }else{
                            innerContainer[propertyKey.name.intValue] = value;
                        }
                    }
                }];
            }else{
                keyValues[property.name] = value;
            }
            
        } @catch (NSException *exception) {
            MJExtensionBuildError([self class], exception.reason);
            MJExtensionLog(@"%@",exception);
        }
        
    }];
    
    //转换完毕
    if ([self respondsToSelector:@selector(mj_objectDidConvertToKeyValues:)]) {
        [self mj_objectDidConvertToKeyValues:keyValues];
    }
    

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if ([self respondsToSelector:@selector(mj_objectDidFinishConvertingToKeyValues)]) {
        [self mj_objectDidFinishConvertingToKeyValues];
    }
#pragma clang diagnostic pop
    
    return keyValues;
}

#pragma mark - 模型数组 -> 字典数组
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(id)keyValuesArray{
    return [self mj_keyValuesArrayWithObjectArray:keyValuesArray ignoredKeys:nil];
}
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:ignoredKeys];
}
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:keys ignoredKeys:nil];

}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray  keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys{
    //0.真实性判断
    MJExtensionAssertError([objectArray isKindOfClass:[NSArray class]], nil, [self class], @"objectArray 不是一个数组");
    //1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        id convertedObj;
        if (keys) {
            convertedObj = [object mj_keyValuesWithKeys:keys];//模型转字典
        }else{//这里都是用ignoredKeys做包含查找操作,所以不用判空
            convertedObj = [object mj_keyValuesWithIgnoredKeys:ignoredKeys];
        }
        if(!convertedObj) continue;
        [keyValuesArray addObject:convertedObj];//字典数组
    }
    
    return keyValuesArray;
}

#pragma mark - 转换为JSON
- (NSData *)mj_JSONData{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([self isKindOfClass:[NSData class]]){
        return (NSData *)self;
    }
    
    return [NSJSONSerialization dataWithJSONObject:[self mj_JSONObject] options:kNilOptions error:nil];
}

/// NSString,NSData -> id
- (id)mj_JSONObject{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    return self.mj_keyValues;
}

- (NSString *)mj_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    
    return [[NSString alloc] initWithData:[self mj_JSONData] encoding:NSUTF8StringEncoding];
}

@end
