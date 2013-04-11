//
//  NSArray+Utilities.m
//  ParseTest
//
//  Created by Ayal Spitz on 11/29/12.
//  Copyright (c) 2012 Ayal Spitz. All rights reserved.
//

#import "NSArray+Utilities.h"

@implementation NSArray (Utilities)

#pragma mark - empty

- (BOOL)isNotEmpty{
    return (self.count != 0);
}

#pragma mark - access methods 

- (id)firstObject{
    id obj = nil;
    
    if ([self isNotEmpty]){
        obj = self[0];
    }
    
    return obj;
}

#pragma mark - subarray methods

- (NSArray *)subarrayFromIndex:(NSUInteger)index{
    return [self subarrayWithRange:NSMakeRange(index,self.count - index)];
}

- (NSArray *)subarrayToIndex:(NSUInteger)index{
    return [self subarrayWithRange:NSMakeRange(0, index)];
}

#pragma mark - map method

- (NSArray *)arrayByEnumeratingUsingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:block(obj, idx, stop)];
    }];
    
    return array;
}

#pragma mark - ruby methods

- (id)first{
    return self.firstObject;
}

- (id)last{
    return self.lastObject;
}

- (void)each:(void (^)(id obj, NSUInteger idx, BOOL *stop))block{
    [self enumerateObjectsUsingBlock:block];
}

- (NSArray *)map:(id (^)(id obj, NSUInteger idx, BOOL *stop))block{
    return [self arrayByEnumeratingUsingBlock:block];
}

- (NSArray *)reverse{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in [self reverseObjectEnumerator]){
        [array addObject:obj];
    }
    return array;
}

@end
