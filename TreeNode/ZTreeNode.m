//
//  ZTreeNode.m
//
//  Created by Ayal Spitz on 9/13/12.
//  Copyright (c) 2012 PatientKeeper, Inc. All rights reserved.
//

#import "ZTreeNode.h"
#import "NSArray+Utilities.h"

@implementation ZTreeNode

- (id)init{
    self = [super init];
    if (self) {
        [self setupWithObject:nil];
    }
    return self;
}

- (id)initWithObject:(id)object{
    self = [super init];
    if (self) {
        [self setupWithObject:object];
    }
    return self;
}

+ (id)treeNodeWithObject:(id)object{
    return [[ZTreeNode alloc]initWithObject:object];
}

- (void)setupWithObject:(id)object{
    self.object = object;
    _children = [NSMutableArray array];
    self.parent = nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder{
    ZTreeNode *node = [ZTreeNode treeNodeWithObject:[decoder decodeObjectForKey:@"Object"]];
    [node addChildren:[decoder decodeObjectForKey:@"Children"]];
    
    return node;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_children forKey:@"Children"];
    [encoder encodeObject:self.object forKey:@"Object"];
}

- (NSData *)toData{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"treeNode"];
    [archiver finishEncoding];
    
    return data;
}

+ (ZTreeNode *)treeNodeWithData:(NSData *)data{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    ZTreeNode *node = [unarchiver decodeObjectForKey:@"treeNode"];
    [unarchiver finishDecoding];
    
    return node;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    // create a new node with the same object
    ZTreeNode *node = [[[self class]allocWithZone:zone]initWithObject:self.object];
    // set the parent of the new node to the parent of this node
    node.parent = self.parent;
    // copy all the children of this node
    [node addChildren:[_children copy]];
    return node;
}

#pragma mark - Node type methods

- (BOOL)isRoot{
    return (self.parent == nil);
}

- (BOOL)isLeaf{
    return ([_children count] == 0);
}

#pragma mark - Root

- (ZTreeNode *)root{
    ZTreeNode *node = self;
    while (node != nil && !node.isRoot) {
        node = node.parent;
    }
    return node;
}

#pragma mark - Node location methods
- (NSUInteger)depth{
    if ([self isRoot]){
        return 0;
    } else {
        return [self.parent depth] + 1;
    }
}

- (NSUInteger)index{
    if ([self isRoot]){
        return 0;
    } else {
        return [self.parent.children indexOfObject:self];
    }
}

- (NSIndexPath *)indexPath{
    NSIndexPath *indexPath = nil;
    
    if (![self isRoot]){
        if ([self.parent isRoot]){
            indexPath = [NSIndexPath indexPathWithIndex:self.index];
        } else {
            indexPath = [self.parent.indexPath indexPathByAddingIndex:self.index];
        }
    }
    
    return indexPath;
}

#pragma mark - Node manipulation methods

- (BOOL)hasChildren{
    return (_children.count != 0);
}

- (NSArray *)children{
    return _children;
}

- (id)firstChild{
    ZTreeNode *child = nil;
    
    if ([_children isNotEmpty]){
        child = _children[0];
    }
    
    return child;
}

- (id)nextSibling{
    id sibling = nil;
    NSUInteger siblingIndex = [self index] + 1;
    if (siblingIndex < self.parent.children.count){
        sibling = self.parent.children[siblingIndex];
    }
    
    return sibling;
}

- (void)addChild:(ZTreeNode *)child{
    if (child != nil){
        [_children addObject:child];
        child.parent = self;
    }
}

- (void)addChildren:(NSArray *)childArray{
    for (ZTreeNode *child in childArray) {
        [self addChild:child];
    }
}

- (void)insertChild:(ZTreeNode *)child atIndex:(NSUInteger)index{
    if (child != nil){
        [_children insertObject:child atIndex:index];
        child.parent = self;
    }
}

- (void)removeChild:(ZTreeNode *)child{
    [_children removeObject:child];
    child.parent = nil;
}

- (void)removeChildAIndex:(NSUInteger)index{
    if (index < _children.count){
        [_children removeObjectAtIndex:index];
    }
}

- (ZTreeNode *)childAtIndex:(NSUInteger)index{
    ZTreeNode *node = nil;
    if (index < _children.count){
        node = [_children objectAtIndex:index];
    }
    return node;
}

- (ZTreeNode *)treeNodeAtIndexPath:(NSIndexPath *)indexPath{
    ZTreeNode *treeNode = self;
    
    if (indexPath != nil){
        for (NSUInteger i=0;i<indexPath.length;i++){
            NSUInteger index = [indexPath indexAtPosition:i];
            treeNode = [treeNode childAtIndex:index];
        }
    }
    
    return treeNode;
}

#pragma mark - Node/Object manipulation methods

- (ZTreeNode *)addObject:(id)object{
    ZTreeNode *treeNode = [[ZTreeNode alloc]initWithObject:object];
    [self addChild:treeNode];
    return treeNode;
}

- (ZTreeNode *)insertObject:(id)object atIndex:(NSUInteger)index{
    ZTreeNode *treeNode = [[ZTreeNode alloc]initWithObject:object];
    [self insertChild:treeNode atIndex:index];
    return treeNode;
}

- (void)removeObject:(id)object{
    ZTreeNode *removeZTreeNode = nil;
    
    for (ZTreeNode *treeNode in _children){
        if (treeNode.object == object){
            removeZTreeNode = treeNode;
            break;
        }
    }
    
    if (removeZTreeNode != nil){
        [self removeChild:removeZTreeNode];
    }
}

- (id)objectAtIndex:(NSUInteger)index{
    return [[self childAtIndex:index]object];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
    return [[self treeNodeAtIndexPath:indexPath]object];
}

#pragma mark - Subscript access methods

- (id)objectAtIndexedSubscript:(NSUInteger)index{
    return [self childAtIndex:index];
}

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index{
    ZTreeNode *treeNode = anObject;
    _children[index] = treeNode;
    treeNode.parent = self;
}

#pragma mark - Tree flattening methods

- (NSArray *)flattenTree{
    NSMutableArray *flattenedTreeArray = [NSMutableArray array];
    
    [self enumerateUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        [flattenedTreeArray addObject:treeNode];
    }];
    
    return flattenedTreeArray;
}

- (NSArray *)flattenTreeForObjects{
    NSMutableArray *flattenedTreeArray = [NSMutableArray array];
    
    [self enumerateUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        if (treeNode.object != nil){
            [flattenedTreeArray addObject:treeNode.object];
        }
    }];
    
    return flattenedTreeArray;
}

#pragma mark - Tree enumeration methods
- (void)traverseTowardsRootUsingBlock:(EnumerationBlock)block{
    ZTreeNode *node = self;
    BOOL stop = NO;
    
    do {
        block(node, &stop);
        node = node.parent;
    } while (!stop && (node != nil));
}

- (void)traverseDepthFirstTowardsLeaveUsingBlock:(TraverseBlock)block{
    ZTreeNode *node = self;
    BOOL stop = NO;
    BOOL stopTraversingBranch = NO;
    NSMutableArray *stack = [NSMutableArray array];
    
    block(node, &stop, &stopTraversingBranch);
    node = node.firstChild;    
    
    if (!stop && !stopTraversingBranch){
        do{
            if (node != nil){
                [stack addObject:node];
                block(node, &stop, &stopTraversingBranch);
                if (stopTraversingBranch){
                    stopTraversingBranch = NO;
                    node = nil;
                } else {
                    node = node.firstChild;
                }
            } else {
                node = [stack lastObject];
                [stack removeLastObject];
                node = node.nextSibling;
            }
        } while (!stop && ((node != nil) || !(stack.count == 0)));
    }
}

- (void)traverseBreadthFirstTowardsLeaveUsingBlock:(TraverseBlock)block{
    ZTreeNode *node = self;
    BOOL stop = NO;
    BOOL stopTraversingBranch = NO;
    NSMutableArray *queue = [NSMutableArray array];
    [queue addObject:self];
    
    do{
        node = queue[0];
        if (node != nil){
            [queue removeObjectAtIndex:0];
            block(node, &stop, &stopTraversingBranch);
            if (stopTraversingBranch){
                stopTraversingBranch = NO;
            } else {
                [queue addObjectsFromArray:node.children];
            }
        }
    } while (!stop && (queue.count != 0));
}


- (void)enumerateParentsUsingBlock:(EnumerationBlock)block{
    [self traverseTowardsRootUsingBlock:block];
}

- (void)enumerateUsingBlock:(TraverseBlock)block{
    [self traverseDepthFirstTowardsLeaveUsingBlock:block];
}

- (NSArray *)filterWithBlock:(FilterBlock)filterBlock{
    NSMutableArray *filteredTree = [NSMutableArray array];
    
    [self enumerateUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        if (filterBlock(treeNode, stop)){
            [filteredTree addObject:treeNode];
        }
    }];
    
    return filteredTree;
}

#pragma mark - Node finding methods

- (ZTreeNode *)treeNodeForObject:(id)object{
    if (self.object == object){
        return self;
    } else if (self.isLeaf){
        return nil;
    } else {
        ZTreeNode *treeNode = nil;
        for (ZTreeNode *child in _children){
            treeNode = [child treeNodeForObject:object];
            if (treeNode != nil){
                break;
            }
        }
        return treeNode;
    }
}

#pragma mark - Equality

- (BOOL)isEqualToZTreeNode:(ZTreeNode *)treeNode withObjectComparator:(NSComparator)comparator{
    // check to see if the objects of the two nodes are the same
    if (comparator(self.object, treeNode.object) != NSOrderedSame){
        return NO;
    }
    
    // check to see of the two nodes have the same number of children
    if (self.children.count != treeNode.children.count){
        return NO;
    }
    
    __block BOOL equal = YES;
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZTreeNode *child = obj;
        ZTreeNode *otherChild = treeNode[idx];
        
        equal = [child isEqualToZTreeNode:otherChild withObjectComparator:comparator];
        *stop = !equal;
    }];
    
    return equal;
}

#pragma mark - debugging methods

- (NSString *)description{
    NSString *className = NSStringFromClass([self class]);
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p> ", className, self];
    NSObject *obj = (NSObject *)self.object;
    NSString *objDescription = [obj description];
    if (objDescription == nil){ objDescription = @"nil"; }
    
    [description appendFormat:@"(%@)", objDescription];
    
    return description;
}

@end
