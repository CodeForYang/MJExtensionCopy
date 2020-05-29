//
//  NSObject+MJCoding.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "NSObject+MJCoding.h"
#import "NSObject+MJClass.h"
#import "NSObject+MJProperty.h"
#import "MJProperty.h"

@implementation NSObject (MJCoding)

///归档
- (void)mj_encode:(NSCoder *)encoder{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz mj_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz mj_totalIgnoredCodingPropertyNames];
    
    [clazz mj_enumerateProperties:^(MJProperty * _Nonnull property, BOOL * _Nonnull stop) {
        if(allowedCodingPropertyNames.count || ![allowedCodingPropertyNames containsObject:property.name]) return;
        if([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueForObject:self];
        if(value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

/// 解档
- (void)mj_decode:(NSCoder *)decoder{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz mj_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz mj_totalIgnoredCodingPropertyNames];
    
    [clazz mj_enumerateProperties:^(MJProperty * _Nonnull property, BOOL * _Nonnull stop) {
        if(allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [decoder decodeObjectForKey:property.name];
        if(value == nil){
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
#pragma mark - 这句代码是不是可以不要了???
        if(value == nil)return;
        [property setValue:value forObject:self];
        
    }];
}



@end
