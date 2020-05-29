//
//  MJPropertyKey.h
//  MJExtensionCopy
//
//  Created by 10.12 on 2020/5/22.
//  Copyright © 2020 10.12. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    MJPropertyKeyTypeDictionary = 0,//字典的key
    MJPropertyKeyTypeArray//数组的key
    
}MJPropertyKeyType;
@interface MJPropertyKey : NSObject

/// key的名字
@property (nonatomic,strong)NSString *name;

/// key的种类,可能是@"10",可能是@"age"
@property (nonatomic,assign)MJPropertyKeyType type;

- (id)valueInObject:(id)object;
@end

NS_ASSUME_NONNULL_END
