//
//  ZTreeNodeTestss.m
//
//  Created by Ayal Spitz on 2/3/13.
//  Copyright (c) 2013 Ayal Spitz. All rights reserved.
//

#import "ZTreeNodeTests.h"
#import "ZTreeNode.h"

#import "NSIndexPath+Utilities.h"
#import "NSArray+Utilities.h"
#import <Foundation/NSException.h>

@implementation ZTreeNodeTests

- (void)setUp{
    [super setUp];
    
    self.root = [ZTreeNode treeNodeWithObject:@"node 1"];
    self.child1 = [self.root addObject:@"node 1.1"];
    self.child2 = [self.root addObject:@"node 1.2"];
    self.child3 = [self.root addObject:@"node 1.3"];
    self.child21 = [self.child2 addObject:@"node 1.2.1"];
}

- (void)tearDown{
    self.root = nil;
    self.child1 = nil;
    self.child2 = nil;
    self.child3 = nil;
    self.child21 = nil;
    
    [super tearDown];
}


- (void)testInit{
    ZTreeNode *treeNode = [[ZTreeNode alloc]init];
    STAssertEqualObjects(treeNode.object, nil, @"'treeNode.object' should be nil");
}

- (void)testInitWithObject{
    ZTreeNode *treeNode = [[ZTreeNode alloc]initWithObject:@"node1"];
    STAssertEquals(treeNode.object, @"node1", @"'treeNode.object' should be equal to 'node1'");
}

- (void)testZTreeNodeWithObject{
    ZTreeNode *treeNode = [ZTreeNode treeNodeWithObject:@"node1"];
    STAssertEquals(treeNode.object, @"node1", @"'treeNode.object' should be equal to 'node1'");
}


- (void)testWithCoder{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.root];
    ZTreeNode *root = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    STAssertTrue([self.root isEqualToTreeNode:root withObjectComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *string1 = obj1;
        NSString *string2 = obj2;
        return [string1 compare:string2];
    }], @"the two treeNodes should be the same since one is a copy of the other");
}

- (void)testWtihData{
    NSData *data = [self.root toData];
    ZTreeNode *root = [ZTreeNode treeNodeWithData:data];
    
    STAssertTrue([self.root isEqualToTreeNode:root withObjectComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *string1 = obj1;
        NSString *string2 = obj2;
        return [string1 compare:string2];
    }], @"the two treeNodes should be the same since one is a copy of the other");
}

- (void)testCopyWithZone{
    ZTreeNode *root = [self.root copy];
    STAssertEqualObjects(self.root.object, root.object, @"the two treeNodes should be pointing to the same object since one is a copy of the other");
    STAssertTrue([self.root.children count] != [root.children count], @"the two treeNodes should not have the same number of children since one is a shallow copy of the other");
    STAssertFalse(self.root.parent != root.parent, @"the two treeNodes should not have the same parent since one is a shallow copy of the other");
    STAssertNil(root.parent, @"the copy should have a nil parent since it's a shallow copy of the other");
}


- (void)testIsRoot{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    STAssertTrue(root.isRoot, @"'root' should be the root");
    
    [root addObject:@"node 1.1"];
    STAssertFalse(root.isLeaf, @"'root' should not be a leaf since it has children");
    
    STAssertTrue(self.root.isRoot, @"'root' should be the root");
    STAssertFalse(self.child1.isRoot, @"'child1' should not be the root");
    STAssertFalse(self.child2.isRoot, @"'child2' should not be the root");
    STAssertFalse(self.child21.isRoot, @"'child21' should not be the root");
}

- (void)testIsLeaf{
    STAssertFalse(self.root.isLeaf, @"'root' should not be a leaf since it has children");
    STAssertTrue(self.child1.isLeaf, @"'child1' should be a leaf");
    STAssertFalse(self.child2.isLeaf, @"'child2' should not be a leaf since it has a child");
    STAssertTrue(self.child21.isLeaf, @"'child21' should be a leaf");
}

- (void)testRoot{
    STAssertEqualObjects(self.root, self.root.root, @"'root' should be the same object as 'root.root'");
    STAssertEqualObjects(self.root, self.child1.root, @"'root' should be the same object as 'child1.root'");
    STAssertEqualObjects(self.root, self.child2.root, @"'root' should be the same object as 'child2.root'");
    STAssertEqualObjects(self.root, self.child21.root, @"'root' should be the same object as 'child21.root'");
}

- (void)testDepth{
    STAssertTrue(self.root.depth == 0, @"the root should have a depth of 0");
    STAssertTrue(self.child1.depth == 1, @"'child1' should have a depth of 1");
    STAssertTrue(self.child21.depth == 2, @"'child21' should have a depth of 2");
}

- (void)testIndex{
    STAssertTrue(self.root.index == 0, @"the root should have a index of 0");
    STAssertTrue(self.child1.index == 0, @"'child1' should have a index of 0");
    STAssertTrue(self.child2.index == 1, @"'child2' should have a index of 1");
    STAssertTrue(self.child21.index == 0, @"'child21' should have a index of 0");
}

- (void)testIndexPath{
    STAssertEqualObjects(self.root.indexPath, nil, @"the root should not have an indexPath since it's the root");
    STAssertEqualObjects(self.child1.indexPath, [NSIndexPath indexPathFromArray:@[@0]], @"'child1' should have an indexPath of [0]");
    STAssertEqualObjects(self.child2.indexPath, [NSIndexPath indexPathFromArray:@[@1]], @"'child2' should have an indexPath of [1]");
    NSIndexPath *indexPath = [NSIndexPath indexPathFromArray:@[@1, @0]];
    STAssertEqualObjects(self.child21.indexPath, indexPath, @"'child21' should have an indexPath of [1 0]");
}

- (void)testHasChildren{
    STAssertTrue(self.root.hasChildren, @"the root should have children");
    STAssertFalse(self.child1.hasChildren, @"'child1' should not have children");
    STAssertTrue(self.child2.hasChildren, @"'child2' should have children");
    STAssertFalse(self.child21.hasChildren, @"'child21' should not have children");
}

- (void)tesChildren{
    NSArray *children = nil;
    
    children = @[self.child1, self.child2, self.child3];
    STAssertTrue([self.root.children isEqualToArray:children], @"root should have 'child1', 'child2', and 'child3' as children");
    
    STAssertFalse([self.child1.children isNotEmpty], @"'child1' should have no children");
    
    children = @[self.child21];
    STAssertTrue([self.child2.children isEqualToArray:children], @"'child2' should have 'child21' as a child");
}

- (void)testFirstChild{
    STAssertEqualObjects(self.root.firstChild, self.child1, @"'child1' is the first child of root");
    STAssertEqualObjects(self.child2.firstChild, self.child21, @"'child21' is the first child of 'child2'");
    STAssertEqualObjects(self.child21.firstChild, nil, @"the first child of 'child21' should be nil since it doesn't have any children");
}

- (void)testLastChild{
    STAssertEqualObjects(self.root.lastChild, self.child3, @"'child3' is the last child of root");
    STAssertEqualObjects(self.child2.lastChild, self.child21, @"'child21' is the last child of 'child2'");
    STAssertEqualObjects(self.child21.lastChild, nil, @"the last child of 'child21' should be nil since it doesn't have any children");
}

- (void)testNextSibling{
    STAssertEqualObjects(self.root.nextSibling, nil, @"the next sibling of root should be nil, since it's the root");
    STAssertEqualObjects(self.child1.nextSibling, self.child2, @"the next sibling of 'child1' should be 'child2'");
    STAssertEqualObjects(self.child2.nextSibling, self.child3, @"the next sibling of 'child2' should be 'child3'");
    STAssertEqualObjects(self.child3.nextSibling, nil, @"the next sibling of 'child3' should be nil since there are no more siblings");
}

- (void)testAddChild{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    ZTreeNode *child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChild:child1];
    [root addChild:child2];
    [child2 addChild:child21];
    
    NSArray *allNodes = @[root, child1, child2, child21];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21]");
    
    [child2 addChild:nil];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21] since adding nil shouldn't have an impact on the tree");
}

- (void)testAddChildren{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    ZTreeNode *child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChildren:@[child1, child2]];
    [child2 addChild:child21];
    
    NSArray *allNodes = @[root, child1, child2, child21];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21]");
    
    [child2 addChildren:@[]];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21] since adding an empty array shouldn't have an impact on the tree");
    
    [child2 addChildren:nil];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21] since adding a nil shouldn't have an impact on the tree");
}

- (void)testInsertChildAtIndex{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    ZTreeNode *child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root insertChild:child2 atIndex:0];
    [root insertChild:child1 atIndex:0];
    [child2 insertChild:child21 atIndex:0];
    
    NSArray *allNodes = @[root, child1, child2, child21];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21]");
    
    [child2 insertChild:nil atIndex:0];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21] since inserting a nil node should have no impact");
    
    STAssertThrowsSpecificNamed([self.root insertChild:child21 atIndex:5], NSException, NSRangeException, @"Index should not be greate then the number of child nodes");
}

- (void)testRemoveChild{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    ZTreeNode *child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChildren:@[child1, child2]];
    [child2 addChild:child21];
    
    [root removeChild:child2];
    NSArray *allNodes = @[root, child1];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1]");
    
    [root removeChild:child2];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1] since removing a node that's not in the tree should not impact the tree");
    
    [root removeChild:nil];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1] since removing a nil should not impact the tree");
    
    root = [ZTreeNode treeNodeWithObject:@"node 1"];
    child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChildren:@[child1, child2]];
    [child2 addChild:child21];
    
    [root removeChild:child1];
    allNodes = @[root, child2, child21];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child2, child21]");
}

- (void)testRemoveChildAIndex{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    ZTreeNode *child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChildren:@[child1, child2]];
    [child2 addChild:child21];
    
    [root removeChildAIndex:1];
    NSArray *allNodes = @[root, child1];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1]");
    
    [root removeChildAIndex:1];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1] since removing a node that's not in the tree should not impact the tree");
    
    root = [ZTreeNode treeNodeWithObject:@"node 1"];
    child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChildren:@[child1, child2]];
    [child2 addChild:child21];
    
    [root removeChildAIndex:0];
    allNodes = @[root, child2, child21];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child2, child21]");
}

- (void)testRemoveChildren{
    STAssertNoThrow([self.root removeChildren:nil], @"nothing should happen if the user tries to remove a nil array of children");
    
    [self.root removeChildren:@[self.child1, self.child3]];
    STAssertTrue([self.root hasChildren], @"root should have a child since we removed all but one");
    STAssertTrue([[self.root children]count] == 1, @"root should have a child since we removed all but one");
    
    STAssertNil(self.child1.parent, @"'child1' should not have a parent anymore since we removed it from the parent");
    STAssertNil(self.child3.parent, @"'child3' should not have a parent anymore since we removed it from the parent");

    STAssertTrue(self.child2.parent == self.root, @"'child2' should have a parent, root");
}

- (void)testRemoveAllChildren{
    [self.root removeAllChildren];
    STAssertFalse([self.root hasChildren], @"root should not have any children since we just removed them all");
    
    STAssertNil(self.child1.parent, @"'child1' should not have a parent anymore since we removed it from the parent");
    STAssertNil(self.child2.parent, @"'child2' should not have a parent anymore since we removed it from the parent");
    STAssertNil(self.child3.parent, @"'child3' should not have a parent anymore since we removed it from the parent");
}

- (void)testChildAtIndex{
    STAssertEqualObjects([self.root childAtIndex:0], self.child1, @"The child at index 0 of root should be 'child1'");
    STAssertEqualObjects([self.root childAtIndex:1], self.child2, @"The child at index 1 of root should be 'child2'");
    STAssertEqualObjects([self.root childAtIndex:2], self.child3, @"The child at index 2 of root should be 'child3'");
    STAssertEqualObjects([self.root childAtIndex:3], nil, @"The child at index 3 of root should be since there are only three children");
    
    STAssertEqualObjects(self.root[0], self.child1, @"The child at index 0 of root should be 'child1'");
    STAssertEqualObjects(self.root[1], self.child2, @"The child at index 1 of root should be 'child2'");
    STAssertEqualObjects(self.root[2], self.child3, @"The child at index 2 of root should be 'child3'");
    STAssertEqualObjects(self.root[3], nil, @"The child at index 3 of root should be since there are only three children");
}

- (void)testSetChildAtIndex{
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1 *"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2 *"];
    ZTreeNode *child3 = [ZTreeNode treeNodeWithObject:@"node 1.3 *"];
    
    self.root[0] = child1;
    self.root[1] = child2;
    self.root[2] = child3;
    
    NSArray *allNodes = @[self.root, child1, child2, child3];
    NSArray *nodes = [self.root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child3]");
    
    STAssertThrowsSpecificNamed(self.root[5] = child2, NSException, NSRangeException, @"Setting a treeNode beyond the boundry of the children should throw a range exception");
}

- (void)testZTreeNodeForIndexPath{
    NSIndexPath *indexPath = [NSIndexPath indexPathFromArray:@[@0]];
    STAssertEqualObjects([self.root treeNodeAtIndexPath:indexPath], self.child1, @"The child at indexPath [0] from root should be 'child1'");
    
    indexPath = [NSIndexPath indexPathFromArray:@[@1]];
    STAssertEqualObjects([self.root treeNodeAtIndexPath:indexPath], self.child2, @"The child at indexPath [1] from root should be 'child2'");
    
    indexPath = [NSIndexPath indexPathFromArray:@[@1, @0]];
    STAssertEqualObjects([self.root treeNodeAtIndexPath:indexPath], self.child21, @"The child at indexPath [1 0] from root should be 'child21'");
    
    indexPath = [NSIndexPath indexPathFromArray:@[@1, @0, @0]];
    STAssertEqualObjects([self.root treeNodeAtIndexPath:indexPath], nil, @"The child at indexPath [1 0 0] from root should be nil since such a child doesn't exist");
}

- (void)testAddObject{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [root addObject:@"node 1.1"];
    ZTreeNode *child2 = [root addObject:@"node 1.2"];
    ZTreeNode *child21 = [child2 addObject:@"node 1.2.1"];
    
    NSArray *allNodes = @[root, child1, child2, child21];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21]");
    
    ZTreeNode *child22 = [child2 addObject:nil];
    allNodes = @[root, child1, child2, child21, child22];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21, child22]");
}

- (void)testInsertObjectAtIndex{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child2 = [root insertObject:@"node 1.2" atIndex:0];
    ZTreeNode *child1 = [root insertObject:@"node 1.1" atIndex:0];
    ZTreeNode *child21 = [child2 insertObject:@"node 1.2.1" atIndex:0];
    
    NSArray *allNodes = @[root, child1, child2, child21];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21]");
    
    [child2 insertChild:nil atIndex:0];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21] since inserting a nil node should have no impact");
    
    STAssertThrowsSpecificNamed([self.root insertChild:child21 atIndex:5], NSException, NSRangeException, @"Index should not be greater then the number of child nodes and should throw a range exception");
}

- (void)testRemoveObject{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    ZTreeNode *child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChildren:@[child1, child2]];
    [child2 addChild:child21];
    
    [root removeObject:@"node 1.2"];
    NSArray *allNodes = @[root, child1];
    NSArray *nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1]");
    
    [root removeObject:@"node 1.2"];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1] since removing a node that's not in the tree should not impact the tree");
    
    [root removeObject:nil];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1] since removing a nil should not impact the tree");
    
    root = [ZTreeNode treeNodeWithObject:@"node 1"];
    child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    
    [root addChildren:@[child1, child2]];
    [child2 addChild:child21];
    
    [root removeObject:@"node 1.1"];
    allNodes = @[root, child2, child21];
    nodes = [root flattenTree];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child2, child21]");
}

- (void)testObjectAtIndex{
    STAssertEqualObjects([self.root objectAtIndex:0], self.child1.object, @"The object at index 0 of root should be 'node 1.1'");
    STAssertEqualObjects([self.root objectAtIndex:1], self.child2.object, @"The object at index 1 of root should be 'node 1.2'");
    STAssertEqualObjects([self.root objectAtIndex:2], self.child3.object, @"The object at index 2 of root should be 'node 1.3'");
    STAssertEqualObjects([self.root objectAtIndex:3], nil, @"The object at index 3 of root should be since there are only two children");
}

- (void)testObjectAtIndexPath{
    NSIndexPath *indexPath = [NSIndexPath indexPathFromArray:@[@0]];
    STAssertEqualObjects([self.root objectAtIndexPath:indexPath], self.child1.object, @"The object at indexPath [0] from root should be 'node 1.1'");
    
    indexPath = [NSIndexPath indexPathFromArray:@[@1]];
    STAssertEqualObjects([self.root objectAtIndexPath:indexPath], self.child2.object, @"The object at indexPath [1] from root should be 'node 1.2'");
    
    indexPath = [NSIndexPath indexPathFromArray:@[@1, @0]];
    STAssertEqualObjects([self.root objectAtIndexPath:indexPath], self.child21.object, @"The object at indexPath [1 0] from root should be 'node 1.2.1'");
    
    indexPath = [NSIndexPath indexPathFromArray:@[@1, @0, @0]];
    STAssertEqualObjects([self.root objectAtIndexPath:indexPath], nil, @"The object at indexPath [1 0 0] from root should be nil since such a child doesn't exist");
}

- (void)testFlattenTree{
    NSArray *allNodes = @[self.root, self.child1, self.child2, self.child21, self.child3];
    NSArray *nodes = [self.root flattenTree];
    
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree should equal [root, child1, child2, child21]");
}

- (void)testFlattenTreeForObjects{
    NSArray *allNodes = @[@"node 1", @"node 1.1", @"node 1.2", @"node 1.2.1", @"node 1.3"];
    NSArray *nodes = [self.root flattenTreeForObjects];
    
    STAssertTrue([allNodes isEqualToArray:nodes], @"The flatten tree objects should equal [node 1, node 1.1, node 1.2, node 1.2.1, node 1.3]");
}

- (void)testTraverseDepthFirstTowardsLeaveUsingBlock{
    NSArray *allNodes = nil;
    __block NSMutableArray *nodes = nil;
    
    allNodes = @[self.root, self.child1, self.child2, self.child21, self.child3];
    nodes = [NSMutableArray array];
    [self.root traverseDepthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root, child1, child2, child21]");

    allNodes = @[self.child2, self.child21];
    nodes = [NSMutableArray array];
    [self.child2 traverseDepthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [child2, child21]");

    allNodes = @[self.root, self.child1];
    nodes = [NSMutableArray array];
    [self.root traverseDepthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        NSString *string = (NSString *)treeNode.object;
        *stop = [string hasPrefix:@"node 1.1"];
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root, child1] because 'stop' is set to true when object 'node 1.1'");

    allNodes = @[self.root];
    nodes = [NSMutableArray array];
    [self.root traverseDepthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        NSString *string = (NSString *)treeNode.object;
        *stopTraversingBranch = [string hasPrefix:@"node 1"];
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root] because 'stopTraversingBranch' is set to true when object 'node 1'");

    allNodes = @[self.root, self.child1, self.child2, self.child3];
    nodes = [NSMutableArray array];
    [self.root traverseDepthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        NSString *string = (NSString *)treeNode.object;
        *stopTraversingBranch = [string hasPrefix:@"node 1.2"];
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root, child1, child2, child3] because 'stopTraversingBranch' is set to true when object 'node 1.2'");
}

- (void)testTraverseBreadthFirstTowardsLeaveUsingBlock{
    NSArray *allNodes = nil;
    __block NSMutableArray *nodes = nil;
    
    allNodes = @[self.root, self.child1, self.child2, self.child3, self.child21];
    nodes = [NSMutableArray array];
    [self.root traverseBreadthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root, child1, child2, child21]");
    
    allNodes = @[self.child2, self.child21];
    nodes = [NSMutableArray array];
    [self.child2 traverseBreadthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [child2, child21]");
    
    allNodes = @[self.root, self.child1, self.child2];
    nodes = [NSMutableArray array];
    [self.root traverseBreadthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        NSString *string = (NSString *)treeNode.object;
        *stop = [string hasPrefix:@"node 1.2"];
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root, child1, child2] because 'stop' is set to true when object 'node 1.2'");

    allNodes = @[self.root];
    nodes = [NSMutableArray array];
    [self.root traverseBreadthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        NSString *string = (NSString *)treeNode.object;
        *stop = [string hasPrefix:@"node 1"];
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root] because 'stop' is set to true when object 'node 1'");

    allNodes = @[self.root];
    nodes = [NSMutableArray array];
    [self.root traverseBreadthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        NSString *string = (NSString *)treeNode.object;
        *stopTraversingBranch = [string hasPrefix:@"node 1"];
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root] because 'stopTraversingBranch' is set to true when object 'node 1'");
    
    allNodes = @[self.root, self.child1, self.child2, self.child3];
    nodes = [NSMutableArray array];
    [self.root traverseBreadthFirstTowardsLeaveUsingBlock:^(ZTreeNode *treeNode, BOOL *stop, BOOL *stopTraversingBranch) {
        NSString *string = (NSString *)treeNode.object;
        *stopTraversingBranch = [string hasPrefix:@"node 1.2"];
        [nodes addObject:treeNode];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The enumerated tree should equal [root, child1, child2, child3] because 'stopTraversingBranch' is set to true when object 'node 1.2'");
}

- (void)testFilterWithBlock{
    NSArray *allNodes = nil;
    NSArray *nodes = nil;
    
    allNodes = @[self.root, self.child1, self.child2, self.child21, self.child3];
    nodes = [self.root filterWithBlock:^BOOL(ZTreeNode *treeNode, BOOL *stop) {
        NSString *string = (NSString *)treeNode.object;
        return [string hasPrefix:@"node 1"];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The filtered tree should equal [root, child1, child2, child21, child3]");
    
    allNodes = @[self.child2, self.child21];
    nodes = [self.root filterWithBlock:^BOOL(ZTreeNode *treeNode, BOOL *stop) {
        NSString *string = (NSString *)treeNode.object;
        return [string hasPrefix:@"node 1.2"];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The filtered tree should equal [child2, child21]");
    
    allNodes = @[self.root, self.child1];
    nodes = [self.root filterWithBlock:^BOOL(ZTreeNode *treeNode, BOOL *stop) {
        NSString *string = (NSString *)treeNode.object;
        *stop = [string hasPrefix:@"node 1.1"];
        return [string hasPrefix:@"node 1"];
    }];
    STAssertTrue([allNodes isEqualToArray:nodes], @"The filtered tree should equal [root, child1] because 'stop' is set to true when object 'node 1.1'");
    
}

- (void)testZTreeNodeForObject{
    ZTreeNode *treeNode = nil;
    
    treeNode = [self.root treeNodeForObject:self.root.object];
    STAssertEqualObjects(self.root, treeNode, @"'root' should equal the search for treeNode ");
    treeNode = [self.root treeNodeForObject:self.child1.object];
    STAssertEqualObjects(self.child1, treeNode, @"'child1' should equal the search for treeNode ");
    treeNode = [self.root treeNodeForObject:self.child2.object];
    STAssertEqualObjects(self.child2, treeNode, @"'child2' should equal the search for treeNode ");
    treeNode = [self.root treeNodeForObject:self.child21.object];
    STAssertEqualObjects(self.child21, treeNode, @"'child21' should equal the search for treeNode ");
}

- (void)testIsEqualToZTreeNodeWithObjectComparator{
    ZTreeNode *root = [ZTreeNode treeNodeWithObject:@"node 1"];
    ZTreeNode *child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    ZTreeNode *child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    ZTreeNode *child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    ZTreeNode *child3 = [ZTreeNode treeNodeWithObject:@"node 1.3"];
    
    [root addChild:child1];
    [root addChild:child2];
    [root addChild:child3];
    [child2 addChild:child21];
    
    STAssertTrue([self.root isEqualToTreeNode:root withObjectComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *string1 = obj1;
        NSString *string2 = obj2;
        return [string1 compare:string2];
    }], @"The two treeNodes should be equal as they have the same structure and all their objects are equal");
    
    root = [ZTreeNode treeNodeWithObject:@"node 1"];
    child1 = [ZTreeNode treeNodeWithObject:@"node 1.1"];
    child2 = [ZTreeNode treeNodeWithObject:@"node 1.2"];
    child21 = [ZTreeNode treeNodeWithObject:@"node 1.2.1"];
    child3 = [ZTreeNode treeNodeWithObject:@"node 1.3"];
    
    [root addChild:child1];
    [root addChild:child2];
    [root addChild:child3];
    [child1 addChild:child21];
    
    STAssertFalse([self.root isEqualToTreeNode:root withObjectComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *string1 = obj1;
        NSString *string2 = obj2;
        return [string1 compare:string2];
    }], @"The two treeNodes should not be equal as they have the different structure and some of their objects are not equal");
}

- (void)testEnumerateParentsUsingBlock{
//    [self.child21 enumerateParentsUsingBlock:^(ZTreeNode *treeNode, BOOL *stop) {
//        NSLog(@"%@", treeNode.object);
//        NSString *str = (NSString *)treeNode.object;
//        *stop = [str isEqualToString:@"node 1.2.1"];
//    }];
}

@end
