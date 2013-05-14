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

@interface ZTreeNodeViewController ()
@property (nonatomic, strong) ZTreeNode *treeNode;

@property (strong) UIBarButtonItem *addButton;
@property (strong) UIBarButtonItem *editButton;
@property (strong) UIBarButtonItem *doneButton;

@property (assign) BOOL ignoreObservation;
@property (assign, getter = isEditingTree) BOOL editTree;
@end

@implementation ZTreeNodeViewController

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEdit:)];
    self.addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addChild:)];
    self.editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editChildren:)];
}

- (void)viewDidLoad{
    [super viewDidLoad];

    if (self.treeNode == nil){
        self.treeNode = [ZTreeNode treeNodeWithObject:@"Root"];
    }
    
    self.title = self.treeNode.object;
    
    [self addObserver:self forKeyPath:@"self.treeNode.children" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.treeNode.isRoot){
        self.navigationItem.leftBarButtonItem = self.editButton;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
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
}

- (IBAction)editChildren:(id)sender{
    [self.tableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = self.doneButton;
}

- (IBAction)doneEditing:(id)sender{
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.addButton;
    self.navigationItem.leftBarButtonItem = self.editButton;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [self.treeNode removeChildAIndex:indexPath.row];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    id child = self.treeNode[fromIndexPath.row];
    
    self.ignoreObservation = YES;
    [self.treeNode removeChildAIndex:fromIndexPath.row];
    [self.treeNode insertChild:child atIndex:toIndexPath.row];
    self.ignoreObservation = NO;
}

#pragma mark - UITableViewDelegate Methods

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"DrillDown"]) {
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        ZTreeNodeViewController *zTreeNodeViewController = [segue destinationViewController];
        zTreeNodeViewController.treeNode = [self.treeNode childAtIndex:selectedRowIndex.row];
        [self.tableView deselectRowAtIndexPath:selectedRowIndex animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUInteger changeKind = [change[NSKeyValueChangeKindKey] intValue];
    NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexSet.firstIndex inSection:0];
    
    if (!self.ignoreObservation){
        if ([keyPath isEqualToString:@"self.treeNode.children"]){
            if (changeKind == NSKeyValueChangeInsertion){
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            } else if (changeKind == NSKeyValueChangeRemoval){
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
        }
    }
}

@end
