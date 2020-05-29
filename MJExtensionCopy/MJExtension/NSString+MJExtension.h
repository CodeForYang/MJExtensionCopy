//
//  NSString+MJExtension.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/27.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtensionConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MJExtension)

/// 驼峰转下划线(loveYou->love_you)
- (NSString *)mj_underlineFromCamel;

/// 下划线转驼峰(love_you->loveYou)
- (NSString *)mj_camelFromUnderline;

/// 首字母大写
- (NSString *)mj_firstCharUpper;

/// 首字母大写
- (NSString *)mj_firstCharLower;

- (BOOL)mj_isPureInt;

- (NSURL *)mj_url;



@end

NS_ASSUME_NONNULL_END
