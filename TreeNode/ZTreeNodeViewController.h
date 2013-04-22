//
//  ZViewController.h
//  ZTreeNode
//
//  Created by Ayal Spitz on 4/11/13.
//  Copyright (c) 2013 Ayal Spitz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZTreeNode;

@interface ZTreeNodeViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ZTreeNode *treeNode;

- (IBAction)addChild:(id)sender;

@end
