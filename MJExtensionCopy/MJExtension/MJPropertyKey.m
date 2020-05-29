//
//  MJPropertyKey.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/22.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "MJPropertyKey.h"

@implementation MJPropertyKey

- (id)valueInObject:(id)object{
    if ([object isKindOfClass:[NSDictionary class]] && self.type == MJPropertyKeyTypeDictionary) {
        return object[self.name];
    }else if ([object isKindOfClass:[NSArray class]] && self.type == MJPropertyKeyTypeArray){
        NSArray *array = object;
        //如果type == MJPropertyKeyTypeArray类型,那就是说有对应多级key的情况(studentsArray[1].name),直接把name转化成int类型
        NSUInteger index = self.name.intValue;
        if (index < array.count) return array[index];
        return nil;
    }
    return nil;;
}
@end
