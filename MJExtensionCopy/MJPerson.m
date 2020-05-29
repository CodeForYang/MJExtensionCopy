//
//  MJPerson.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/21.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "MJPerson.h"

#import "MJExtension.h"
@implementation MJPerson
+ (NSDictionary *)mj_replacedKeyFromPropertyName{//一对一映射
    return @{@"testNMB":@"testId"};
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    
    if ([property.name isEqualToString:@"birthDay"]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *currentDate = [dateFormatter dateFromString:oldValue];
        return [dateFormatter stringFromDate:currentDate];
        }

    return oldValue;
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"studentsArray":@"MJStudent",
        @"sbArray":@"MJStudent",

    };
}

//+ (id)mj_replacedKeyFromPropertyName121:(NSString *)propertyName{
//    if ([propertyName isEqualToString:@"girlsType"]) {
//        return @"ass";
//    }
//
//    return nil;
//}


//+ (void)mj_setupReplacedKeyFromPropertyName:(MJReplacedKeyFromPropertyName)replacedKeyFromPropertyName{
//    replacedKeyFromPropertyName = ^NSDictionary* (void){
//        return @{@"name" : @"studentsArray[1].name"};
//    };
//}
@end
