//
//  MJFoundation.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/22.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJFoundation : NSObject
+ (BOOL)isClassFromFoundation:(Class)c;
+ (BOOL)isFromNSObjectProtocolProperty:(NSString *)propertyName;

@end
