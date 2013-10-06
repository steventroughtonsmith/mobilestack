//
//  MobileStackPreferencesController.h
//  MobileStack
//
//  Created by Steven Troughton-Smith on 03/10/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileStackPreferencesController : NSObject <UITableViewDataSource, UITableViewDelegate>
{
	UITableView *preferencesTable;
	UIWindow *window;
	
	UITableViewCell *_gridCell;
	UITableViewCell *_curveCell;
	UITableViewCell *_singleDisplayCell;
	UITableViewCell *_cascadeDisplayCell;
//
//	UISwitch *_settingsGridSwitch;
//	UISwitch *_settingsCurveSwitch;

}

+ (MobileStackPreferencesController *) sharedInstance;
-(void)setup;
-(void)_initCells;

@property (nonatomic,retain) UIWindow *window;

@end
