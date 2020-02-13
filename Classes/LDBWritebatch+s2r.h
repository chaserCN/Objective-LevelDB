//
//  LDBWritebatch+s2r.h
//  
//
//  Created by Nikolay on 2/13/20.
//

#import <Foundation/Foundation.h>
#import "LDBWriteBatch.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDBWritebatch (LevelDB_s2r)
- (void)setString:(NSString *)aString forKey:(int64_t)aKey;
@end

NS_ASSUME_NONNULL_END
