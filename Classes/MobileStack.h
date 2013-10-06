#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MobileStackButton.h"
#import "SGridView.h"
#import "MobileStackPreferencesController.h"

#import "StackWindow.h"

//#define NSLog //

#import "MobileStackGlobal.h"

@interface MobileStack : NSObject <UIApplicationDelegate>
{	
	NSMutableDictionary *stackPrefs;
	
	StackWindow *stackWindow;
	
	MobileStackPreferencesController *preferencesController;

//	UIButton *_settingsButton;
	
	CGFloat stackPosition;

	UIView *contentView;
			
	NSMutableArray *buttonArray;
	NSMutableArray *buttonStoreArray;
	
	SGridView *roundrectView;
	MobileStackButton *toggleStackButton;
	UIImageView *poofImageView;
}

+ (MobileStack *) sharedInstance;

-(CGFloat)stackPosition;
-(CGRect)_stackDragRect;

-(CGRect)stackRect;

- (void)openApp:(id)sender;
- (void)showStack:(id) event;
- (void)openStack:(id) sender; 
- (void)closeStack:(id) sender;
- (void)addItemToStack:(NSString *)identifier;
- (void)removeItemFromStack:(id)sender;

@property (nonatomic, retain) StackWindow *stackWindow;
@property (nonatomic, retain) UIView *contentView;


@end