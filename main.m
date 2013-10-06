
#import "MobileStackController.h"

int main(int argc, char **argv)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	int ret = UIApplicationMain(argc, argv, [MobileStackController class]);
	
	[pool release];
	return ret;
}
