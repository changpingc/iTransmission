//
//  ITPreferencePanelViewController.m
//  iTransmission
//
//  Created by Mike Chen on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITPreferencePanelViewController.h"


@implementation ITPreferencePanelViewController

@synthesize tableView = _tableView;
@synthesize tableSections = _tableSections;

- (id)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableSections == nil) {
        [self callSetupTableContent];
        return 0;
    }
    assert(self.tableSections);
    id sectionContent = [self.tableSections objectAtIndex:section];
    if ([sectionContent isKindOfClass:[NSArray class]]) {
        return [sectionContent count];
    }
    else {
        return [[sectionContent objectForKey:@"rows"] count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableSections == nil) {
        [self callSetupTableContent];
        return 0;
    }
    assert(self.tableSections);
    return [self.tableSections count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(self.tableSections);
    
    UITableViewCell *cell = [[self.tableSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

- (void)setTableContentReloadNeeded
{
    [self performSelector:@selector(callSetupTableContent) withObject:nil afterDelay:0.0f];
}

- (void)callSetupTableContent
{
    self.tableSections = nil;
    [self setupTableContent];
    assert(self.tableSections);
    for (id rows in self.tableSections) {
        if ([rows isKindOfClass:[NSArray class]]) {
        }
        else if ([rows isKindOfClass:[NSDictionary class]]) {
            if (! [[(NSDictionary*)rows objectForKey:@"cells"] isKindOfClass:[NSArray class]]) {
                NSLog(@"Section %d is NSDictionary typed but has its rows typed wrong.\n", [self.tableSections indexOfObject:rows]);
                self.tableSections = nil;
                break;
            }
        }
        else {
            NSLog(@"Section %d is not NSArray or NSDictionary typed.\n", [self.tableSections indexOfObject:rows]);
            self.tableSections = nil;
            break;
        }
    }
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.0f];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)setupTableContent
{
}

@end
