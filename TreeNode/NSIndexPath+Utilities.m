//
//  NSIndexPath+Utilities.m
//  Outliner
//
//  Created by Ayal Spitz on 2/4/13.
//  Copyright (c) 2013 Ayal Spitz. All rights reserved.
//

#import "NSIndexPath+Utilities.h"

@implementation NSIndexPath (Utilities)

+ (NSIndexPath *)indexPathFromArray:(NSArray *)pathArray{
    NSUInteger cArray[pathArray.count];

    for (NSUInteger idx=0;idx<pathArray.count;idx++){
        cArray[idx] = [[pathArray objectAtIndex:idx] unsignedIntegerValue];
    }
    
    return [NSIndexPath indexPathWithIndexes:cArray length:pathArray.count];
}

- (NSArray *)toArray{
    NSUInteger indexPathLength = self.length;
    NSUInteger cArray[indexPathLength];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:indexPathLength];
    
    [self getIndexes:cArray];
    for (NSUInteger idx=0;idx<indexPathLength;idx++){
        [array addObject:[NSNumber numberWithInteger:cArray[idx]]];
    }
    
    return array;
}

- (NSString *)string{
    NSArray *array = [self toArray];
    return [array componentsJoinedByString:@" "];
}

@end
