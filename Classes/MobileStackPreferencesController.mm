//
//  MobileStackPreferencesController.m
//  MobileStack
//
//  Created by Steven Troughton-Smith on 03/10/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

#import "MobileStackPreferencesController.h"
#import "MobileStack.h"

static MobileStackPreferencesController *_sharedInstance = nil;

@implementation MobileStackPreferencesController

@synthesize window;

+ (MobileStackPreferencesController *) sharedInstance
{
	if (_sharedInstance == nil) 
	{		
		_sharedInstance = [[MobileStackPreferencesController alloc] init];
		[_sharedInstance setup];
	}
	return _sharedInstance;
}

-(void)setup
{
	window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] retain];
	
	UITableView *_preferencesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f ,20.0+48.0f, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height-28) style:UITableViewStyleGrouped];
	UINavigationBar *_preferencesHeader = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 20.0f, [UIScreen mainScreen].applicationFrame.size.width, 48.0f)];
	preferencesTable = _preferencesTable;
	
	UINavigationItem *_rootItem = [[UINavigationItem alloc] initWithTitle:@"Settings"];
	UIBarButtonItem *_preferencesCloseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePreferencesWindow:)];
	[_rootItem setLeftBarButtonItem:_preferencesCloseButton animated:NO];
	
	_preferencesHeader.items = [NSArray arrayWithObject:_rootItem];
	
	[window addSubview:_preferencesTable];
	[window addSubview:_preferencesHeader];
	
	[self _initCells];
	
	_preferencesTable.dataSource = self;
	_preferencesTable.delegate = self;
	

}


-(void)hidePreferencesWindow:(id)sender
{
	
	[UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.5];
	self.window.alpha = 0.0;
	self.window.transform = CGAffineTransformMakeScale(1.3, 1.3);
	[UIView commitAnimations];
	
	[self.window performSelector:@selector(orderOut:) withObject:self afterDelay:0.7];
}

-(void)showPreferencesWindow:(id)sender
{
	self.window.alpha = 0.0;

	[self.window makeKeyAndVisible];
	
	self.window.transform = CGAffineTransformMakeScale(1.3, 1.3);
	
	[UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.5];
	self.window.alpha = 1.0;
	self.window.transform = CGAffineTransformMakeScale(1.0, 1.0);
	[[MobileStack sharedInstance] closeStack:sender];
	[UIView commitAnimations];
	
}


#pragma mark StackPreferences

-(void)_setPrefsCurvedValue:(UISwitch *)sender
{
	NSDictionary *stackPrefs = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.plist" stringByExpandingTildeInPath]];
	if (!stackPrefs)
		stackPrefs = [NSMutableDictionary dictionary];
	
	//if (sender.on)
//		{
//			//if (_settingsGridSwitch.on)
////
////			[_settingsGridSwitch setOn:NO animated:YES];
////			[stackPrefs setValue:[NSNumber numberWithBool:!sender.on] forKey:@"ForceGridView"];
//		}
	
	
	[stackPrefs setValue:[NSNumber numberWithBool:sender.on] forKey:@"UseCurvedStack"];
	
	[stackPrefs writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.plist" stringByExpandingTildeInPath] atomically:NO];
	
}

-(void)_setPrefsGridValue:(UISwitch *)sender
{
	NSDictionary *stackPrefs = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.plist" stringByExpandingTildeInPath]];
	if (!stackPrefs)
		stackPrefs = [NSMutableDictionary dictionary];
	
	//
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:0.3];
//	[preferencesTable reloadData];
//	[UIView commitAnimations];
	
	if (((UISwitch *)_gridCell.accessoryView).on)
	{
		NSIndexPath *_i = [preferencesTable indexPathForCell:_curveCell];
		if (_i)
		[preferencesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:_i] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		[preferencesTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[stackPrefs setValue:[NSNumber numberWithBool:sender.on] forKey:@"ForceGridView"];
	
	[stackPrefs writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.plist" stringByExpandingTildeInPath] atomically:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;	
}

-(void)_initCells
{
	
	NSDictionary *stackPrefs = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.plist" stringByExpandingTildeInPath]];
	if (!stackPrefs)
		stackPrefs = [NSMutableDictionary dictionary];
	
	/* Grid Option Cell */
	_gridCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"_grid_"] retain];
	
	_gridCell.accessoryView = [[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] retain];
	_gridCell.selectionStyle = UITableViewCellSelectionStyleNone;	
	_gridCell.text = @"Always Show in Grid";
		
	((UISwitch *)_gridCell.accessoryView).on = [[stackPrefs valueForKey:@"ForceGridView"] boolValue];
	[((UISwitch *)_gridCell.accessoryView) addTarget:self action:@selector(_setPrefsGridValue:) forControlEvents:UIControlEventValueChanged];
	
	/* Curved Option Cell */
	_curveCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"_curve_"] retain];
	
	_curveCell.accessoryView = [[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] retain];
	_curveCell.selectionStyle = UITableViewCellSelectionStyleNone;	
	_curveCell.text = @"Use Curved Stack";
	((UISwitch *)_curveCell.accessoryView).on = [[stackPrefs valueForKey:@"UseCurvedStack"] boolValue];
	
	
	[((UISwitch *)_curveCell.accessoryView) addTarget:self action:@selector(_setPrefsCurvedValue:) forControlEvents:UIControlEventValueChanged];
	
	
	/* Display Style Cells */
	
	_singleDisplayCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"_single_"] retain];
	_cascadeDisplayCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"_cascade_"] retain];
	
	_singleDisplayCell.accessoryType = UITableViewCellAccessoryNone;
	_singleDisplayCell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	_singleDisplayCell.text = @"Single Icon";
	_singleDisplayCell.image = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_preferences_single.png"];
	
	_cascadeDisplayCell.accessoryType = UITableViewCellAccessoryCheckmark;
	_cascadeDisplayCell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	_cascadeDisplayCell.text = @"Cascaded Icons";
	
	_cascadeDisplayCell.image = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_preferences_cascade.png"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	switch (indexPath.section)
	{
		case 0:
		{
			switch (indexPath.row)
			{		
				case 0:
				{
					return [_gridCell retain];
					break;
				}
				case 1:
				{
					return [_curveCell retain];	
					break;
				}
				default:
					return nil;
					break;
			}
			break;
		}
		case 1:
		{
			switch (indexPath.row)
			{
				case 0:
				{
					return [_singleDisplayCell retain];
					break;
				}
				case 1:
				{
					return [_cascadeDisplayCell retain];
					break;
				}				
				default:
					return nil;
					break;
			}	
			break;
		}
			
		default:
			return nil;
			break;
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	switch (section)
	{
		case 0:
		{
			if (((UISwitch *)_gridCell.accessoryView).on)
				return 1;
			else
				return 2;
			break;
		}
		case 1:
			return 2;
			break;

		default:
			return 0;
			break;
	}
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	switch (indexPath.section)
	{
		case 0:
			return 64.0;
			break;
		case 1:
			return [tableView rowHeight];
			break;
		case 2:
			return 90.0;
			break;
			
		default:
			return [tableView rowHeight];
	}
}


@end
