//
//  LevelDB+LevelDB_s2r.h
//  
//
//  Created by Nikolay on 2/13/20.
//

#import <Foundation/Foundation.h>
#import "LevelDB.h"

NS_ASSUME_NONNULL_BEGIN

typedef void     (^LevelDBInt64KeyStringValueBlock)   (int64_t key, NSString *value);


@interface LevelDB (LevelDB_s2r)

- (void)setString:(NSString *)aString forKey:(int64_t)aKey;
- (void)removeStringForKey:(int64_t)aKey;
- (void)enumerateInt64KeysAndStringsUsingBlock:(LevelDBInt64KeyStringValueBlock)aBlock;

@end

NS_ASSUME_NONNULL_END
