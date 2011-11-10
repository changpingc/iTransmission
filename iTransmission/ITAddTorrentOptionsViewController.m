//
//  ITAddTorrentOptionsViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITAddTorrentOptionsViewController.h"

@implementation ITAddTorrentOptionsViewController

@synthesize torrent = _torrent;

- (id)initWithPrebuiltTorrent:(ITTorrent*)torrent
{
    self = [super initWithNibName:@"ITAddTorrentOptionsViewController" bundle:nil];
    if (self) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title = @"Options";
        self.torrent = torrent;
    }
    return self;
}

- (void)cancel:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)done:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
