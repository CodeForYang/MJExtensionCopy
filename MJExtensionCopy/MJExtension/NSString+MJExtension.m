//
//  NSString+MJExtension.m
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/27.
//  Copyright © 2020 10.12. All rights reserved.
//

#import "NSString+MJExtension.h"

@implementation NSString (MJExtension)
- (NSString *)mj_underlineFromCamel{
    if(self.length == 0) return self;
     
     NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i<self.length; i++) {
        NSString *cString = [NSString stringWithFormat:@"%c",[self characterAtIndex:i]];
        if ([cString isEqualToString:cString.uppercaseString]) {
            
            [string appendString:[NSString stringWithFormat:@"_%@",cString.lowercaseString]];
        }else{
            [string appendString:cString];
        }
    }
    
    return string;
}

- (NSString *)mj_camelFromUnderline{
    if(self.length == 0) return self;
     
    
    NSMutableString *string = [NSMutableString string];
    NSArray *stringArr = [self componentsSeparatedByString:@"_"];
    for (int i = 0; i<stringArr.count; i++) {
        NSString *tmpStr = stringArr[i];
        if(tmpStr.length == 0) continue;//过滤两个/多个连续的下划线
        NSString *firstChar = [NSString stringWithFormat:@"%c",[tmpStr characterAtIndex:0]].uppercaseString;
        NSString *appendStr = [tmpStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
        [string appendString:appendStr];
        
    }
    
    return string;
//    NSMutableString *string = [[NSMutableString alloc]initWithString:self];
//
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_" options:0 error:nil];
//    NSArray <NSTextCheckingResult *>*matches =  [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
//
//    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *replaceStr = @"";
//        NSRange range = NSMakeRange(obj.range.location+1, obj.range.length);//This_is_a_sentence_
//        if (self.length > range.location) {//length 1-9,location 0-8
//            replaceStr = [NSString stringWithFormat:@"%c",[self characterAtIndex:range.location]];
//            [string replaceCharactersInRange:range withString:replaceStr.uppercaseString];
//        }
//        //这里替换之后字符串变短了
//    }];
//
//
//    return [string stringByReplacingOccurrencesOfString:@"_" withString:@""];
}


- (NSString *)mj_firstCharLower{
    if(self.length == 0) return self;
     
     NSMutableString *string = [NSMutableString string];
     [string appendString:[NSString stringWithFormat:@"%c",[self characterAtIndex:0]].lowercaseString];
     if(self.length>=2) [string appendString:[self substringFromIndex:1]];
     return string;
}

- (NSString *)mj_firstCharUpper{
    if(self.length == 0) return self;
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c",[self characterAtIndex:0]].uppercaseString];
    if(self.length>=2) [string appendString:[self substringFromIndex:1]];
    return string;
}

- (BOOL)mj_isPureInt{
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}



- (NSURL *)mj_url{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return [NSURL URLWithString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"",NULL,kCFStringEncodingUTF8))];
#pragma clang diagnostic pop

}
@end
