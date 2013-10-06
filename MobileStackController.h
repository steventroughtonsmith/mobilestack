#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UISectionList.h>
#import <UIKit/UISectionTable.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIAnimator.h>
#import <UIKit/UIFrameAnimation.h>
#import <UIKit/UIRotationAnimation.h>
#import <UIKit/UIAlphaAnimation.h>
#import <LayerKit/LayerKit.h>

#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <sys/sysctl.h>


typedef enum _UIVersionNumber {
	kiPodTouch = 1,
	kiPhone,
	kiPhone1_0_2,
	kUnsupported

} UIVersionNumber;

@interface UIView (Color)
+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
@end

@interface MobileStackController : UIApplication {

UIWindow *window;
UIView *contentView;

UIPreferencesTableCell *optionsGroup;
UIPreferencesTableCell *geometryCell;
UIPreferencesTableCell *forceGridViewCell;
UIPreferencesTableCell *entriesCell;
UISwitchControl *geometrySwitch;
UISwitchControl *forceGridViewSwitch;

UIPreferencesTableCell *installGroup;
UIPreferencesTableCell *installCell;
UIPreferencesTableCell *removeCell;
UIThreePartButton *installButton;
UIThreePartButton *removeButton;

UIPreferencesTableCell *terminateGroup;
UIPreferencesTableCell *terminateCell;
UIThreePartButton *terminateButton;

}
-(void)killStackProcess;
-(int)platform;
-(void)uninstallStack:(id)sender;
-(void)installStack:(id)sender;



@end