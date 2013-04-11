//
//  ZTreeNode.h
//
//  Created by Ayal Spitz on 9/13/12.
//  Copyright (c) 2012 PatientKeeper, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZTreeNode;
typedef BOOL(^FilterBlock)(ZTreeNode *treeNode, BOOL *stop);
typedef void(^EnumerationBlock)(ZTreeNode *treeNode, BOOL *stop);
typedef void(^TraverseBlock)(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch);

@interface ZTreeNode : NSObject <NSCopying, NSCoding>{
    NSMutableArray *_children;
}

@property (nonatomic, weak) ZTreeNode *parent;
@property (nonatomic, strong) id<NSCoding> object;

- (id)initWithObject:(id)object;
+ (id)treeNodeWithObject:(id)object;

- (NSData *)toData;
+ (ZTreeNode *)treeNodeWithData:(NSData *)data;

- (BOOL)isRoot;
- (BOOL)isLeaf;

- (NSUInteger)depth;
- (NSUInteger)index;
- (NSIndexPath *)indexPath;

- (ZTreeNode *)root;

- (BOOL)hasChildren;
- (NSArray *)children;
- (id)firstChild;
- (id)nextSibling;

- (void)insertChild:(ZTreeNode *)child atIndex:(NSUInteger)index;
- (void)addChild:(ZTreeNode *)child;
- (void)addChildren:(NSArray *)childArray;
- (void)removeChild:(ZTreeNode *)child;
- (void)removeChildAIndex:(NSUInteger)index;
- (ZTreeNode *)childAtIndex:(NSUInteger)index;
- (ZTreeNode *)treeNodeAtIndexPath:(NSIndexPath *)indexPath;

- (ZTreeNode *)insertObject:(id)object atIndex:(NSUInteger)index;
- (ZTreeNode *)addObject:(id)object;
- (void)removeObject:(id)object;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;

- (NSArray *)flattenTree;
- (NSArray *)flattenTreeForObjects;

- (void)traverseTowardsRootUsingBlock:(EnumerationBlock)block;
- (void)traverseDepthFirstTowardsLeaveUsingBlock:(TraverseBlock)block;
- (void)traverseBreadthFirstTowardsLeaveUsingBlock:(TraverseBlock)block;

- (NSArray *)filterWithBlock:(FilterBlock)filterBlock;

- (ZTreeNode *)treeNodeForObject:(id)object;

- (BOOL)isEqualToZTreeNode:(ZTreeNode *)treeNode withObjectComparator:(NSComparator)comparator;

@end