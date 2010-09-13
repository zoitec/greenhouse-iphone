    //
//  EventSessionsByDayViewController.m
//  Greenhouse
//
//  Created by Roy Clarkson on 7/30/10.
//  Copyright 2010 VMware. All rights reserved.
//

#import "EventSessionsByDayViewController.h"


@interface EventSessionsByDayViewController()

@property (nonatomic, retain) EventSessionController *eventSessionController;
@property (nonatomic, retain) NSArray *arrayTimes;
@property (nonatomic, retain) NSDate *currentEventDate;

@end


@implementation EventSessionsByDayViewController

@synthesize eventSessionController;
@synthesize arrayTimes;
@synthesize currentEventDate;
@synthesize eventDate;

- (EventSession *)eventSessionForIndexPath:(NSIndexPath *)indexPath
{
	EventSession *session = nil;
	
	@try 
	{
		NSArray *array = (NSArray *)[self.arraySessions objectAtIndex:indexPath.section];
		session = (EventSession *)[array objectAtIndex:indexPath.row];
	}
	@catch (NSException * e) 
	{
		DLog(@"%@", [e reason]);
		session = nil;
	}
	@finally 
	{
		return session;
	}
}


#pragma mark -
#pragma mark EventSessionControllerDelegate methods

- (void)fetchSessionsByDateDidFinishWithResults:(NSArray *)sessions andTimes:(NSArray *)times
{
	eventSessionController.delegate = nil;
	self.eventSessionController = nil;
	
	[self performSelector:@selector(dataSourceDidFinishLoadingNewData) withObject:nil afterDelay:0.0f];
	
	self.arraySessions = sessions;
	self.arrayTimes = times;
	
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (arrayTimes)
	{
		return [arrayTimes count];
	}
	else 
	{
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.arraySessions)
	{
		NSArray *array = (NSArray *)[self.arraySessions objectAtIndex:section];
		return [array count];
	}
	else 
	{
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *s = nil;
	
	if (arrayTimes)
	{
		NSDate *sessionTime = (NSDate *)[arrayTimes objectAtIndex:section];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"h:mm a"];
		NSString *dateString = [dateFormatter stringFromDate:sessionTime];
		[dateFormatter release];
		s = dateString;		
	}
	
	return s;
}


#pragma mark -
#pragma mark PullRefreshTableViewController methods

- (void)refreshView
{
	// set the title of the view to the schedule day
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE"];
	NSString *dateString = [dateFormatter stringFromDate:eventDate];
	[dateFormatter release];
	self.title = dateString;
	
	if (![self.currentEvent.eventId isEqualToString:self.event.eventId] ||
		[currentEventDate compare:eventDate] != NSOrderedSame)
	{
		self.arraySessions = nil;
		self.arrayTimes = nil;
		[self.tableView reloadData];
	}
	
	self.currentEvent = self.event;
	self.currentEventDate = eventDate;
}

- (BOOL)shouldReloadData
{
	return (self.arraySessions == nil || arrayTimes == nil || self.lastRefreshExpired);
}

- (void)reloadTableViewDataSource
{
	self.eventSessionController = [EventSessionController eventSessionController];
	eventSessionController.delegate = self;
	
	[eventSessionController fetchSessionsByEventId:self.event.eventId withDate:eventDate];
}


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
	self.lastRefreshKey = @"EventSessionsByDayViewController_LastRefresh";
	
    [super viewDidLoad];
	
	self.title = @"Schedule";
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	
	self.eventSessionController = nil;
	self.arrayTimes = nil;
	self.currentEventDate = nil;
	self.eventDate = nil;
}


#pragma mark -
#pragma mark NSObject methods

- (void)dealloc 
{
	[eventSessionController release];
	[arrayTimes release];
	[currentEventDate release];
	[eventDate release];
	
    [super dealloc];
}


@end
