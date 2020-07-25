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
typedef void     (^LevelDBStringKeyStringValueBlock)   (NSString *key, NSString *value);


@interface LevelDB (LevelDB_s2r)

- (void)setString:(NSString *)aString forKey:(int64_t)aKey;
- (void)setString:(NSString *)aString forStringKey:(NSString *)aKey;

- (void)removeStringForKey:(int64_t)aKey;
- (void)removeStringForStringKey:(NSString *)aKey;

- (nullable NSString *)stringForKey:(int64_t)aKey;
- (nullable NSString *)stringForStringKey:(NSString *)aKey;

- (void)enumerateInt64KeysAndStringsUsingBlock:(LevelDBInt64KeyStringValueBlock)aBlock;
- (void)enumerateStringKeysAndStringsUsingBlock:(LevelDBStringKeyStringValueBlock)aBlock;

@end

NS_ASSUME_NONNULL_END
