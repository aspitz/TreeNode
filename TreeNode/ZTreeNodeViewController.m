//
//  ZViewController.m
//  ZTreeNode
//
//  Created by Ayal Spitz on 4/11/13.
//  Copyright (c) 2013 Ayal Spitz. All rights reserved.
//

#import "ZTreeNodeViewController.h"
#import "ZTreeNode.h"
#import "NSIndexPath+Utilities.h"

@implementation ZTreeNodeViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    if (self.treeNode == nil){
        self.treeNode = [ZTreeNode treeNodeWithObject:@"Root"];
    }
    
    self.title = self.treeNode.object;
}

#pragma mark -
- (IBAction)addChild:(id)sender{
    NSUInteger rowCount = [self.treeNode.children count];
    NSIndexPath *treeIndexPath = [self.treeNode indexPath];
    if (treeIndexPath == nil){
        treeIndexPath = [NSIndexPath indexPathWithIndex:rowCount];
    } else {
        treeIndexPath = [treeIndexPath indexPathByAddingIndex:rowCount];
    }
    NSString *nodeName = [NSString stringWithFormat:@"Node: [%@]", [treeIndexPath string]];
    [self.treeNode addObject:nodeName];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowCount inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.treeNode.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *kCellIdentifier = @"CELL";
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    cell.textLabel.text = [self.treeNode childAtIndex:indexPath.row].object;
    
    return cell;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"DrillDown"]) {
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        ZTreeNodeViewController *zTreeNodeViewController = [segue destinationViewController];
        zTreeNodeViewController.treeNode = [self.treeNode childAtIndex:selectedRowIndex.row];
        [self.tableView deselectRowAtIndexPath:selectedRowIndex animated:YES];
    }
}

@end
