//
//  S2RExtension.m
//  iOS Tests
//
//  Created by Nikolay on 2/13/20.
//

#import <XCTest/XCTest.h>
#import "BaseTestClass.h"
#import <LevelDB+s2r.h>
#import <LDBWritebatch+s2r.h>

@interface S2RExtension: BaseTestClass

@end


@interface Position: NSObject
@property (nonatomic, assign) int64_t hash;
@property (nonatomic, strong) NSString *value;
@end

@implementation Position
@synthesize hash;
@synthesize value;
@end

@implementation S2RExtension

- (NSArray<Position*> *)positions {
    NSMutableArray<Position*> *result = [[NSMutableArray alloc] init];
    
    for (uint64_t i = 0; i < 100; i++) {
        Position *position = [Position new];
        
        position.hash = i;
        position.value = @"some long value. maybe dropbox or something";
        
        [result addObject:position];
    }

    for (uint64_t i = 0; i < 100; i++) {
        Position *position = [Position new];
        
        position.hash = i + 1000;
        position.value = [NSString stringWithFormat:@"some long value. maybe dropbox or something %llu", i];
        
        [result addObject:position];
    }

    for (uint64_t i = 0; i < 100; i++) {
        Position *position = [Position new];
        
        position.hash = i + 2000;
        position.value = [NSString stringWithFormat:@"%llu", i + 1000];
        
        [result addObject:position];
    }

    for (uint64_t i = 0; i < 100; i++) {
        Position *position = [Position new];
        
        position.hash = i + 3000;
        position.value = [NSString stringWithFormat:@"%llu", i + 1000];
        
        [result addObject:position];
    }

    for (uint64_t i = 0; i < 100; i++) {
        Position *position = [Position new];
        
        position.hash = i + 4000;
        position.value = [NSString stringWithFormat:@"%llu.%llu.", i + 1000, i + 10];
        
        [result addObject:position];
    }

    return  result;
}

- (void)testSpeed1 {
    NSArray<Position*> *positions = [self positions];
    
    [self measureBlock:^{
        for (Position *position in positions) {
            [db setString:position.value forKey:position.hash];
        }
    }];
}

- (void)testSpeed3 {
    NSArray<Position*> *positions = [self positions];
    
    [self measureBlock:^{
        LDBWritebatch *dispatch = [LDBWritebatch new];
        
        for (Position *position in positions) {
            [dispatch setString:position.value forKey:position.hash];
        }
        
        [db applyWritebatch:dispatch];
    }];
}

- (void)testSpeed2 {
    NSArray<Position*> *positions = [self positions];
    
    [self measureBlock:^{
        for (Position *position in positions) {
            NSString *key = [NSString stringWithFormat:@"%llu", position.hash];
            [db setObject:position.value forKey:key];
        }
    }];
}

- (void)testInt64KeysStringValues {
    [db setString:@"first" forKey:1];
    [db setString:@"some other" forKey:0xAABBCCDDEEFF0011];
    [db setString:@"negative-1" forKey:-1];
    [db setString:@"minimum" forKey:INT_LEAST64_MIN];
    [db setString:@"maximum" forKey:INT_LEAST64_MAX];
    
    __block NSInteger counter = 0;
    
    [db enumerateInt64KeysAndStringsUsingBlock:^(int64_t key, NSString *value) {
        switch (key) {
            case 1:
                XCTAssertEqualObjects(value, @"first");
                break;
            case 0xAABBCCDDEEFF0011:
                XCTAssertEqualObjects(value, @"some other");
                break;
            case -1:
                XCTAssertEqualObjects(value, @"negative-1");
                break;
            case INT_LEAST64_MIN:
                XCTAssertEqualObjects(value, @"minimum");
                break;
            case INT_LEAST64_MAX:
                XCTAssertEqualObjects(value, @"maximum");
                break;
            default:
                break;
        }
        
        NSLog(@"key = %llX. value = '%@'", key, value);
        counter++;
    }];
    
    XCTAssertEqual(counter, 5);
}

- (void)testBatchForInt64KeysStringValues {
    LDBWritebatch *batch = [LDBWritebatch new];
    
    [batch setString:@"first" forKey:1];
    [batch setString:@"some other" forKey:0xAABBCCDDEEFF0011];
    [batch setString:@"negative-1" forKey:-1];
    [batch setString:@"minimum" forKey:INT_LEAST64_MIN];
    [batch setString:@"maximum" forKey:INT_LEAST64_MAX];

    [db applyWritebatch:batch];
    
    __block NSInteger counter = 0;
    
    [db enumerateInt64KeysAndStringsUsingBlock:^(int64_t key, NSString *value) {
        switch (key) {
            case 1:
                XCTAssertEqualObjects(value, @"first");
                break;
            case 0xAABBCCDDEEFF0011:
                XCTAssertEqualObjects(value, @"some other");
                break;
            case -1:
                XCTAssertEqualObjects(value, @"negative-1");
                break;
            case INT_LEAST64_MIN:
                XCTAssertEqualObjects(value, @"minimum");
                break;
            case INT_LEAST64_MAX:
                XCTAssertEqualObjects(value, @"maximum");
                break;
            default:
                break;
        }
        
        NSLog(@"key = %llX. value = '%@'", key, value);
        counter++;
    }];
    
    XCTAssertEqual(counter, 5);
}

- (void)testRemovingForInt64KeysStringValues {
    [db setString:@"first" forKey:0x12C97F];
    [db setString:@"some other" forKey:0xAABB];
    [db setString:@"negative-1" forKey:-1];
    [db setString:@"minimum" forKey:INT_LEAST64_MIN];
    [db setString:@"maximum" forKey:INT_LEAST64_MAX];
    
    [db removeStringForKey:-1];
    [db removeStringForKey:INT_LEAST64_MAX];
    [db removeStringForKey:111];
    
    __block NSInteger counter = 0;
    
    [db enumerateInt64KeysAndStringsUsingBlock:^(int64_t key, NSString *value) {
        switch (key) {
            case 1231231:
                XCTAssertEqualObjects(value, @"first");
                break;
            case 0xAABB:
                XCTAssertEqualObjects(value, @"some other");
                break;
            case INT_LEAST64_MIN:
                XCTAssertEqualObjects(value, @"minimum");
                break;
            default:
                break;
        }
        
        NSLog(@"key = %llX. value = '%@'", key, value);
        counter++;
    }];
    
    XCTAssertEqual(counter, 3);
}

@end
