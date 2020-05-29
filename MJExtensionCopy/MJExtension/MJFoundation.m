//
//  MJFoundation.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/22.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "MJFoundation.h"
#import "MJExtensionConst.h"
#import <CoreData/CoreData.h>
#import <objc/runtime.h>
@implementation MJFoundation
+ (BOOL)isClassFromFoundation:(Class)c{
    
    if(c == [NSObject class] || c == [NSManagedObject class]) return YES;
    
    static NSSet *foundationClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        foundationClasses = [NSSet setWithObjects:
                             [NSURL class],
                             [NSDate class],
                             [NSValue class],
                             [NSData class],
                             [NSError class],
                             [NSArray class],
                             [NSDictionary class],
                             [NSString class],
                             [NSAttributedString class],
                             nil];
    });
    
    __block BOOL result = NO;
    [foundationClasses enumerateObjectsUsingBlock:^(Class foundationClass, BOOL * _Nonnull stop) {
        if([c isSubclassOfClass:foundationClass]){
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

+ (BOOL)isFromNSObjectProtocolProperty:(NSString *)propertyName{
    if(!propertyName) return NO;
    
    static NSSet <NSString *>*objectProtocolPropertyNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsigned int count = 0;
        objc_property_t *properties = protocol_copyPropertyList(@protocol(NSObject), &count);
        NSMutableSet *propertyNames = [NSMutableSet setWithCapacity:count];
//         kCFStringEncodingUTF8
//        NSUTF8StringEncoding
         for (int i = 0; i < count; i++) {
             objc_property_t property = properties[i];
#pragma mark ---propertyName 这个传进来的属性名 好像没用到啊???
             NSString *propertyName_ = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
             if (propertyName_) {
                 [propertyNames addObject:propertyName_];
             }
         }
        objectProtocolPropertyNames = [propertyNames copy];
        free(properties);
    });

    
    return [objectProtocolPropertyNames containsObject:propertyName];
}
@end
