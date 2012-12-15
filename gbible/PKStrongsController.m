//
//  PKStrongsController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKStrongsController.h"
#import "PKStrongs.h"
#import "PKSettings.h"
#import "PKAppDelegate.h"
#import "ZUUIRevealController.h"
#import "PKSearchViewController.h"
#import "PKRootViewController.h"

#import "GLTapLabel.h"

@interface PKStrongsController ()

@end

@implementation PKStrongsController
    @synthesize theSearchTerm;
    @synthesize theSearchResults;
    @synthesize theSearchBar;
    @synthesize byKeyOnly;
    @synthesize clickToDismiss;
    @synthesize noResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Strong's Lookup"];
        self.theSearchTerm = [[PKSettings instance] lastStrongsLookup];
        self.byKeyOnly = NO;
    }
    return self;
}

-(void)doSearchForTerm:(NSString *)theTerm  
{
    [self doSearchForTerm:theTerm byKeyOnly:self.byKeyOnly];
}

-(void)doSearchForTerm:(NSString *)theTerm byKeyOnly:(BOOL)keyOnly
{
    self.byKeyOnly = byKeyOnly;
    [((PKRootViewController *)self.parentViewController.parentViewController ) showWaitingIndicator];
    PKWait(
        theSearchResults = nil;
        theSearchTerm = theTerm;
        
        if ([theTerm isEqualToString:@""])
        {
            theSearchResults = nil;
        }
        else
        {
            theSearchResults = [PKStrongs keysThatMatch:theTerm byKeyOnly:keyOnly];
        }
        [self.tableView reloadData];
        
        theSearchBar.text = theTerm;
        
        ((PKSettings *)[PKSettings instance]).lastStrongsLookup = theTerm;

        UITabBarController *tbc = (UITabBarController *)self.parentViewController.parentViewController;
        tbc.selectedIndex = 2;
        self.byKeyOnly = NO;
         if ([theSearchResults count] == 0)
            {
                noResults.text = @"No results. Please try again.";
            }
            else 
            {
                noResults.text = @"";
            }
    );
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [TestFlight passCheckpoint:@"SEARCH_STRONGS"];
    
    // add search bar
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    theSearchBar.delegate = self;
    theSearchBar.placeholder = @"Strong's # or search term";
    theSearchBar.showsCancelButton = NO;
    theSearchBar.tintColor = [PKSettings PKBaseUIColor];

    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(didReceiveRightSwipe:)];
    UISwipeGestureRecognizer *swipeLeft =[[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(didReceiveLeftSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
    [swipeRight setNumberOfTouchesRequired:1];
    [swipeLeft  setNumberOfTouchesRequired:1];
    [self.tableView addGestureRecognizer:swipeRight];
    [self.tableView addGestureRecognizer:swipeLeft];

    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(didReceiveLongPress:)];
    longPress.minimumPressDuration = 0.5;
    longPress.numberOfTapsRequired = 0;
    longPress.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:longPress];

  
    self.tableView.tableHeaderView = theSearchBar;
    
    // add navbar items
    UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                        initWithImage:[UIImage imageNamed:@"Listb.png"] 
                                        style:UIBarButtonItemStylePlain 
                                        target:self.parentViewController.parentViewController.parentViewController
                                        action:@selector(revealToggle:)];

    if ([changeReference respondsToSelector:@selector(setTintColor:)])
    {
        changeReference.tintColor = [PKSettings PKBaseUIColor];
    }
    changeReference.accessibilityLabel = @"Go to passage";
    self.navigationItem.leftBarButtonItem = changeReference;

    CGRect theRect = CGRectMake(0, self.tableView.center.y + 40, self.tableView.bounds.size.width, 60);
    noResults = [[UILabel alloc] initWithFrame:theRect];
    noResults.textColor = [PKSettings PKTextColor];
    noResults.font = [UIFont fontWithName:@"Zapfino" size:15];
    noResults.textAlignment = UITextAlignmentCenter;
    noResults.backgroundColor = [UIColor clearColor];
    noResults.shadowColor = [UIColor whiteColor];
    noResults.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    noResults.numberOfLines = 0;
    [self.view addSubview:noResults];
        
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [PKSettings PKPageColor];

//    [self doSearchForTerm:self.theSearchTerm];
    theSearchBar.text = self.theSearchTerm;
}
-(void) updateAppearanceForTheme
{
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [PKSettings PKPageColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // reload the search? TODO
    [self updateAppearanceForTheme];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    theSearchResults = nil;
    theSearchTerm = nil;

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation  
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self calculateShadows];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(void)calculateShadows
{
    CGFloat topOpacity = 0.0f;
    CGFloat theContentOffset = (self.tableView.contentOffset.y);
    if (theContentOffset > 15)
    {
        theContentOffset = 15;
    }
    topOpacity = (theContentOffset/15)*0.5;
    
    [((PKRootViewController *)self.parentViewController.parentViewController ) showTopShadowWithOpacity:topOpacity];

    CGFloat bottomOpacity = 0.0f;
    
    theContentOffset = self.tableView.contentSize.height - self.tableView.contentOffset.y -
                       self.tableView.bounds.size.height;
    if (theContentOffset > 15)
    {
        theContentOffset = 15;
    }
    bottomOpacity = (theContentOffset/15)*0.5;
    
    [((PKRootViewController *)self.parentViewController.parentViewController ) showBottomShadowWithOpacity:bottomOpacity];
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self calculateShadows];
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self calculateShadows];
}
#pragma mark
#pragma mark Table View Data Source Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (theSearchResults != nil)
    {
        return [theSearchResults count];
    }
    else 
    {
        return 0;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];

    NSArray *theResult = [PKStrongs entryForKey:[theSearchResults objectAtIndex:row]];
    
    CGSize theSize;
    CGFloat theHeight = 0;
    CGFloat theCellWidth = (self.tableView.bounds.size.width-30);
//    CGFloat theColumnWidth = (theCellWidth) / 2;
    CGSize maxSize = CGSizeMake(theCellWidth, 300);

    theHeight += 10; // the top margin
    theHeight += 20; // the top labels

    theSize = [[theResult objectAtIndex:1] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    theHeight += theSize.height + 10;

    theSize = [[theResult objectAtIndex:3] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    theHeight += theSize.height + 10;

    theSize = [[theResult objectAtIndex:4] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    theHeight += theSize.height + 10;

    theHeight += 10;
    
    return theHeight;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strongsCellID = @"PKStrongsCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strongsCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:strongsCellID];
    }
    // need to remove the cell's subviews, if they exist...
    for (UIView *view in cell.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger row = [indexPath row];
    
    CGFloat theCellWidth = (self.tableView.bounds.size.width-30);
    CGFloat theColumnWidth = (theCellWidth) / 2;
    
    // now create the new subviews
    UILabel *theStrongsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, theColumnWidth, 20)];
    theStrongsLabel.text = [theSearchResults objectAtIndex:row];
    theStrongsLabel.textColor = [PKSettings PKStrongsColor];
    theStrongsLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
    theStrongsLabel.backgroundColor = [UIColor clearColor];
    
    NSArray *theResult = [PKStrongs entryForKey:[theSearchResults objectAtIndex:row]];
    
    UILabel *theLemmaLabel = [[UILabel alloc] initWithFrame:CGRectMake(theColumnWidth+20, 10, theColumnWidth, 20)];
    theLemmaLabel.text = [theResult objectAtIndex:2];
    theLemmaLabel.textAlignment = UITextAlignmentRight;
    theLemmaLabel.textColor = [PKSettings PKTextColor];
    theLemmaLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
    theLemmaLabel.backgroundColor = [UIColor clearColor];
    
    CGSize maxSize = CGSizeMake (theCellWidth, 300);
    
    CGSize theSize = [[theResult objectAtIndex:1] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    GLTapLabel *theDerivationLabel = [[GLTapLabel alloc] initWithFrame:CGRectMake(10, 40, theCellWidth, theSize.height)];
    theDerivationLabel.text = [theResult objectAtIndex:1];
    theDerivationLabel.textColor = [PKSettings PKTextColor];
    theDerivationLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    theDerivationLabel.lineBreakMode = UILineBreakModeWordWrap;
    theDerivationLabel.numberOfLines = 0;
    theDerivationLabel.backgroundColor = [UIColor clearColor];
    theDerivationLabel.delegate = self;
    theDerivationLabel.userInteractionEnabled = YES;
  
    
    CGSize theKJVSize = [[theResult objectAtIndex:3] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    GLTapLabel *theKJVLabel = [[GLTapLabel alloc] initWithFrame:CGRectMake(10, 50 + theSize.height,
                                                                     theCellWidth, theKJVSize.height)];
    theKJVLabel.text = [theResult objectAtIndex:3];
    theKJVLabel.textColor = [PKSettings PKTextColor];
    theKJVLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    theKJVLabel.lineBreakMode = UILineBreakModeWordWrap;
    theKJVLabel.numberOfLines  = 0;
    theKJVLabel.backgroundColor = [UIColor clearColor];
    theKJVLabel.delegate = self;
    theKJVLabel.userInteractionEnabled = YES;
  
    CGSize theStrongsSize = [[theResult objectAtIndex:4] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    GLTapLabel *theStrongsDefLabel = [[GLTapLabel alloc] initWithFrame:CGRectMake(10, 50 + theSize.height + 10 + theKJVSize.height,
                                                                     theCellWidth, theStrongsSize.height)];
    theStrongsDefLabel.text = [theResult objectAtIndex:4];
    theStrongsDefLabel.textColor = [PKSettings PKTextColor];
    theStrongsDefLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    theStrongsDefLabel.lineBreakMode = UILineBreakModeWordWrap;
    theStrongsDefLabel.numberOfLines =0 ;
    theStrongsDefLabel.backgroundColor = [UIColor clearColor];
    theStrongsDefLabel.delegate = self;
    theStrongsDefLabel.userInteractionEnabled = YES;

    [cell addSubview:theStrongsLabel];
    [cell addSubview:theLemmaLabel];
    [cell addSubview:theDerivationLabel];
    [cell addSubview:theKJVLabel];
    [cell addSubview:theStrongsDefLabel];
    

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//return;
    NSUInteger row = [indexPath row];


    ZUUIRevealController *rc = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
    PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
    PKSearchViewController *svc = [[[rvc.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    
    [svc doSearchForTerm:[theSearchResults objectAtIndex:row] requireParsings:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Searching
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hideKeyboard];
    [self doSearchForTerm:searchBar.text];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CGRect theRect = self.tableView.frame;
    theRect.origin.y += 44;
    clickToDismiss = [[UIButton alloc] initWithFrame:theRect];
    clickToDismiss.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight;
    clickToDismiss.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [clickToDismiss addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchDown |
                                                                                   UIControlEventTouchDragInside
    ];
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:clickToDismiss];
}

//FIX ISSUE #50
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [clickToDismiss removeFromSuperview];
    clickToDismiss = nil;
    self.tableView.scrollEnabled = YES;
}

-(void) hideKeyboard
{
    [clickToDismiss removeFromSuperview];
    clickToDismiss = nil;
    [self becomeFirstResponder];
    self.tableView.scrollEnabled = YES;
}

-(void) didReceiveRightSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    if (p.x < 75)
    {
        // show the sidebar, if not visible
        ZUUIRevealController *rc = (ZUUIRevealController*) self.parentViewController.parentViewController.parentViewController;
        if ( [rc currentFrontViewPosition] == FrontViewPositionLeft )
        {
            [rc revealToggle:nil];
            return;
        }
    }
}

-(void) didReceiveLeftSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
//    CGPoint p = [gestureRecognizer locationInView:self.tableView];
//    if (p.x < 75)
//    {
        // hide the sidebar, if visible
        ZUUIRevealController *rc = (ZUUIRevealController*) self.parentViewController.parentViewController.parentViewController;
        if ( [rc currentFrontViewPosition] == FrontViewPositionRight )
        {
            [rc revealToggle:nil];
            return;
        }
//    }
}

-(void) didReceiveLongPress:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p]; // nil if no row
      
        if (indexPath != nil)
        {
            NSUInteger row = [indexPath row];
          
            NSMutableString *theText = [[theSearchResults objectAtIndex:row] mutableCopy];
            NSArray *theResult = [PKStrongs entryForKey:[theSearchResults objectAtIndex:row]];
          
            [theText appendFormat:@"\nLemma: %@\nDerivation: %@\nKJV Usage: %@\nDefinition: %@",
                [theResult objectAtIndex:2],
                [theResult objectAtIndex:1],
                [theResult objectAtIndex:3],
                [theResult objectAtIndex:4]
            ];

            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.string = theText;
          
            UIAlertView *anAlert = [[UIAlertView alloc]
                initWithTitle:@"Notice" message:@"Row copied to clipboard" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil ];
            [anAlert show];

        }
    }
}


#pragma mark -
#pragma mark GLTapLabel Delegate

-(void) label:(GLTapLabel *)label didSelectedHotWord:(NSString *)word
{
  // search for the selected word
  NSLog(@"Received word: %@", word);
  [self doSearchForTerm:word byKeyOnly:true];
}

@end
