//
//  ContactsSectionViewController.m
//  Audiotebook_v1.0
//
//  Created by Robert Walport on 3/24/13.
//  Copyright (c) 2013 Hacks. All rights reserved.
//

#import "ContactsSectionViewController.h"
#import "CoreDataHelper.h"
#import "Contact.h"

@interface ContactsSectionViewController ()

@end

@implementation ContactsSectionViewController

@synthesize  managedObjectContext, pictureListData;

//  When the view reappears, read new data for table
- (void)viewWillAppear:(BOOL)animated
{
    //  Repopulate the array with new table data
    [self readDataForTable];
}

//  Grab data for table - this will be used whenever the list appears or reappears after an add/edit
- (void)readDataForTable
{
    //  Grab the data
    pictureListData = [CoreDataHelper getObjectsForEntity:@"Contact" withSortKey:@"name" andSortAscending:YES andContext:managedObjectContext];
    
    //  Force table refresh
    [self.tableView reloadData];
}

#pragma mark - Actions

//  Button to log out of app (dismiss the modal view!)
- (IBAction)logoutButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  Get a reference to our detail view
    ContactsEditViewController *pld = (ContactsEditViewController *)[segue destinationViewController];
    
    //  Pass the managed object context to the destination view controller
    pld.managedObjectContext = managedObjectContext;
    
    //  If we are editing a picture we need to pass some stuff, so check the segue title first
    if ([[segue identifier] isEqualToString:@"EditContact"])
    {
        //  Get the row we selected to view
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        //  Pass the picture object from the table that we want to view
        pld.currentPicture = [pictureListData objectAtIndex:selectedIndex];
    }
}

#pragma mark - Table view data source

//  Return the number of sections in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//  Return the number of rows in the section (the amount of items in our array)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pictureListData count];
}

//  Create / reuse a table cell and configure it for display
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the core data object we need to use to populate this table cell
    Contact *currentCell = [pictureListData objectAtIndex:indexPath.row];
    
    //  Fill in the cell contents
    cell.textLabel.text = [currentCell name];
    cell.detailTextLabel.text = [currentCell job];
    
    //  If a picture exists then use it
    if ([currentCell smallPicture])
    {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = [UIImage imageWithData:[currentCell smallPicture]];
    }
    
    return cell;
}

//  Swipe to delete has been used.  Remove the table item
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //  Get a reference to the table item in our data array
        Contact *itemToDelete = [self.pictureListData objectAtIndex:indexPath.row];
        
        //  Delete the item in Core Data
        [self.managedObjectContext deleteObject:itemToDelete];
        
        //  Remove the item from our array
        [pictureListData removeObjectAtIndex:indexPath.row];
        
        //  Commit the deletion in core data
        NSError *error;
        if (![self.managedObjectContext save:&error])
            NSLog(@"Failed to delete picture item with error: %@", [error domain]);
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
