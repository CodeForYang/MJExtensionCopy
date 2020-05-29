//
//  ViewController.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/21.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "ViewController.h"
#import "MJExtension/MJExtension.h"
#import "MJPerson.h"
#import "NSObject+Test.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dic = @{@"name":@"西西里的美丽传说",
                          @"sex":@"女性",
                          @"nickName":@"ALEX",
                          @"age":@"24",
                          @"weight":@"65.751987666777",
                          @"height":@"173.2453",
                          @"isMarried":@"false",
                          @"girlsType":@"cute",
                          @"ass":@"bigBottom",
                          @"birthDay":@"19920202",
                          @"testId":@"XXXXXXXXXXXXXX",
                          @"hobits":@{
                                  @"piano":@"good",
                                  @"writing":@"exllent",
                                  @"professional":@"pick-up-artist"
                          },
                          @"studentsArray":@[
                                  @{
                                      @"image":@"student_image.png",
                                      @"url":@"https://www.baidu.com",
                                      @"name":@"Mickey",
                                  },
                                  @{
                                      @"image":@"pretty_hot.png",
                                      @"url":@"https://www.google.com",
                                      @"name":@"Jefrrey",
                                  },
                          ]
    };
    MJPerson *personModel =  [MJPerson new];

//    [MJPerson mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
//        return @{@"name" : @"studentsArray[1].name",
//                 @"hobits":@"hobits.professional"
//        };
//    }];
//
//    [MJPerson mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
//           return @{@"sbArray":@"studentsArray"};
//       }];
//    [MJPerson mj_setupIgnoredCodingPropertyNames:^NSArray *{
//        return @[@"characters"];
//    }];
    
//    [MJPerson mj_setupReplacedKeyFromPropertyName121:^id(NSString *propertyName) {
//        if ([propertyName isEqualToString:@"sbArray"]) {
//                    return @"studentsArray";
//        }
//        return nil;
//    }];
    
    
//    personModel = [MJPerson mj_objectWithKeyValues:dic];//通过字典来创建一个模型
    

    personModel = [personModel mj_setKeyValues:dic];//将字典的键值对转成模型属性
    NSLog(@"-----");


//    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/bag.data"];
    // Encoding
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:personModel requiringSecureCoding:YES error:nil];
//
//
//    // Decoding
//    MJPerson *decodedBag = [NSKeyedUnarchiver unarchivedObjectOfClass:[MJPerson class] fromData:data error:nil];

    
    //    [self decimalTest];
//    [self test];
}


- (void)test{
    [NSObject testMethod];
    
    [MJPerson testMethod];
}
- (void)decimalTest{
    double d1 = 999999;
    double d2 = 0.01;
    double d3 = d1 * d2;
    
    NSDecimalNumber *de1 = [[NSDecimalNumber alloc] initWithDouble:d1];
    NSDecimalNumber *de2 = [[NSDecimalNumber alloc] initWithDouble:d2];
    NSDecimalNumber *de3 = [de1 decimalNumberByMultiplyingBy:de2];

    
}


@end
