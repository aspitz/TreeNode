//
//  ZTreeNodeTests.h
//
//  Created by Ayal Spitz on 2/3/13.
//  Copyright (c) 2013 Ayal Spitz. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>

@class ZTreeNode;
@interface ZTreeNodeTests : SenTestCase

@property (nonatomic, strong) ZTreeNode *root;
@property (nonatomic, strong) ZTreeNode *child1;
@property (nonatomic, strong) ZTreeNode *child2;
@property (nonatomic, strong) ZTreeNode *child21;
@property (nonatomic, strong) ZTreeNode *child3;

@end
