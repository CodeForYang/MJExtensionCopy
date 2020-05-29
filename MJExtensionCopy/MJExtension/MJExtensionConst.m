//
//  MJExtensionConst.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/21.
//  Copyright © 2020 10.12. All rights reserved.
//
#ifndef __MJExtensionConst__M__
#define __MJExtensionConst__M__

#import <Foundation/Foundation.h>



 NSString *const MJPropertyTypeInt = @"i";
 NSString *const MJPropertyTypeShort = @"s";
 NSString *const MJPropertyTypeFloat = @"f";
 NSString *const MJPropertyTypeDouble = @"d";
 NSString *const MJPropertyTypeLong = @"l";
 NSString *const MJPropertyTypeLongLong = @"q";
 NSString *const MJPropertyTypeChar = @"c";//为什么这两个字符串一样??? char
 NSString *const MJPropertyTypeBool1 = @"c";//为什么这两个字符串一样??? boolean
 NSString *const MJPropertyTypeBool2 = @"b";
 NSString *const MJPropertyTypePointer = @"*";

 NSString *const MJPropertyTypeIvar = @"^{objc_ivar=}";
 NSString *const MJPropertyTypeMethod = @"^{objc_method=}";
 NSString *const MJPropertyTypeBlock = @"@?";
 NSString *const MJPropertyTypeClass = @"#";
 NSString *const MJPropertyTypeSEL = @":";
 NSString *const MJPropertyTypeId = @"@";
#endif
