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

/* Code cribbed from Leopard's NSEnumerator.h to prevent warnings */

@interface NSArray (FastEnum)

typedef struct {
    unsigned long state;
    id *itemsPtr;
    unsigned long *mutationsPtr;
    unsigned long extra[5];
} NSFastEnumerationState;

- (int)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(int)len;
@end

/* End cribbed code =) */


@interface UIView (Color)
+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
@end

@interface StackContentView : UIView
@end

@interface StackButton : UIThreePartButton
{
	id _representedObject;
}
-(void)setRepresentedObject:(id)obj;
-(id)representedObject;
@end

@interface MobileStack : UIApplication {
	UIWindow *blackoutWindow;

	NSMutableArray *buttonArray;
	NSMutableArray *buttonStoreArray;

	UIWindow *window;
	UIView *contentView;
	StackContentView *roundrectView;

	StackButton *toggleStackButton;

	StackButton *firstImageView;
	StackButton *secondImageView;
	StackButton *thirdImageView;
		
	UIAlphaAnimation *fadeAnimation;

}

-(void)openApp:(id)sender;

@end