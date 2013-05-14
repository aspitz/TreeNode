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

- (IBAction)addChild:(id)sender;

- (IBAction)editChildren:(id)sender;
- (IBAction)doneEditing:(id)sender;

@end
