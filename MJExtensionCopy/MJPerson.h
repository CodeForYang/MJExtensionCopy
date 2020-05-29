//
//  MJPerson.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/21.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class MJStudent;
@interface MJPerson : NSObject
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *sex;
//@property (nonatomic)char *nickName;
@property (nonatomic,strong)NSString *girlsType;
@property (nonatomic,strong)NSString *birthDay;
@property (nonatomic,strong)NSString *testNMB;
@property (nonatomic,strong)NSString *hobits;
@property (nonatomic,assign)CGFloat weight;
@property (nonatomic,assign)double height;

@property (nonatomic,assign)BOOL isMarried;
@property (nonatomic,assign)int64_t age;
@property (nonatomic,strong)NSArray <MJStudent *>*sbArray;

@property (nonatomic,strong)NSArray <MJStudent *>*studentsArray;

@end

NS_ASSUME_NONNULL_END
