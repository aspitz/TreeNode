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

@end
