//
//  NSObject+MJCoding.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/23.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MJCoding <NSObject>

@optional

/// 这个数组中的数据才会归档
+(NSArray *)mj_allowedCodingPropertyNames;

/// 这个数组中的属性将会被忽略: 不进行归档
+(NSArray *)mj_ignoredCodingPropertyNames;
@end

@interface NSObject (MJCoding)<MJCoding>

/// 解码
/// @param decoder 从文件中解析对象
- (void)mj_decode:(NSCoder *)decoder;

/// 编码
/// @param encoder 将对象写入文件
- (void)mj_encode:(NSCoder *)encoder;

@end

///归档实现
#define MJCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder{\
if(self = [super init]){\
[self mj_decode:decoder];\
}\
return self;\
}\
- (void)encodeWithCoder:(NSCoder *)encoder\
{\
[self mj_encode:encoder];\
}

#define MJExtensionCodingImplementation MJCodingImplementation
NS_ASSUME_NONNULL_END
