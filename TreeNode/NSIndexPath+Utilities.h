//
//  NSIndexPath+Utilities.h
//  Outliner
//
//  Created by Ayal Spitz on 2/4/13.
//  Copyright (c) 2013 Ayal Spitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (Utilities)

+ (NSIndexPath *)indexPathFromArray:(NSArray *)pathArray;

- (NSArray *)toArray;
- (NSString *)string;

@end
