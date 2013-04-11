//
//  NSArray+Utilities.h
//  ParseTest
//
//  Created by Ayal Spitz on 11/29/12.
//  Copyright (c) 2012 Ayal Spitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utilities)

- (BOOL)isNotEmpty;

- (id)firstObject;

- (NSArray *)subarrayFromIndex:(NSUInteger)index;
- (NSArray *)subarrayToIndex:(NSUInteger)index;

- (NSArray *)arrayByEnumeratingUsingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block;

- (NSArray *)reverse;

// ruby methods
- (id)first;
- (id)last;

- (void)each:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (NSArray *)map:(id (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
