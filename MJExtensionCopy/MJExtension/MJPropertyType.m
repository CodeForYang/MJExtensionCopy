//
//  MJPropertyType.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/22.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "MJPropertyType.h"
#import "MJFoundation.h"
#import "MJExtensionConst.h"

@implementation MJPropertyType
+ (instancetype)cachedTypeWithCode:(NSString *)code{
    MJExtensionAssertParamNotNil2(code, nil);
    
    static NSMutableDictionary *types;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = [NSMutableDictionary dictionary];
    });
    
    MJPropertyType *type = types[code];
    if (type == nil) {
        type = [[self alloc]init];
        type.code = code;
        types[code] = type;
    }
    
    return type;
}

#pragma mark ---公共方法
- (void)setCode:(NSString *)code{
    _code = code;
    
    MJExtensionAssertParamNotNil(code);
    if ([code isEqualToString:MJPropertyTypeId]) {
        _idType = YES;
    }else if (code.length == 0){
        _KVCDisabled = YES;
    }else if (code.length > 3 && [code hasPrefix:@"@\""]){
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [MJFoundation isClassFromFoundation:_typeClass];
        //isSubclassOfClass和isKindOfClass 作用一致,类方法和对象方法的区别
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];//是否为当前类,或者当前类的子类
    }else if([code isEqualToString:MJPropertyTypeSEL] ||
             [code isEqualToString:MJPropertyTypeIvar] ||
             [code isEqualToString:MJPropertyTypeMethod]
             ){
        _KVCDisabled = YES;
    }
    
    //是否为基本数据类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[MJPropertyTypeInt,MJPropertyTypeBool1,MJPropertyTypeBool2,MJPropertyTypeFloat,MJPropertyTypeDouble,MJPropertyTypeLong,MJPropertyTypeLongLong,MJPropertyTypeShort,MJPropertyTypeChar];
#pragma mark --MJ 好像没有对指针类型的数据赋值进行处理???
#pragma mark--- MJPropertyTypeChar 基本数据类型
    if ([numberTypes containsObject:lowerCode]) {//c语言的false也属于基本数据类型,会进入这里
        _numberType = YES;
        
        if ([lowerCode isEqualToString:MJPropertyTypeBool1] ||[lowerCode isEqualToString:MJPropertyTypeBool2]) {//boolean || BOOL
            _boolType = YES;
        }
    }
    
    
}
@end
