#include <signal.h>
#include <kvm.h>
#include <fcntl.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#import "MobileStack.h"

pid_t springboard_pid() {
	uint32_t	    i;
    size_t			length;
	int32_t			err, count;
    struct kinfo_proc	   *process_buffer;
    struct kinfo_proc      *kp;
    int				mib[ 3 ] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };
    pid_t           spring_pid;
    int             loop, argmax;

    spring_pid = -1;

	sysctl( mib, 3, NULL, &length, NULL, 0 );

    if (length == 0)
        return -1;
	
	process_buffer = (struct kinfo_proc *)malloc(length);

    for ( i = 0; i < 60; ++i ) {
        // in the event of inordinate system load, transient sysctl() failures are
        // possible.  retry for up to one minute if necessary.
        if ( ! ( err = sysctl( mib, 3, process_buffer, &length, NULL, 0 ) ) ) break;
        sleep( 1 );
    }	

    if (err) {
        free(process_buffer);
        return -1;
    }
        
    count = length / sizeof(struct kinfo_proc);

    kp = process_buffer;

#ifdef DEBUG
    fprintf(stderr,"PID scan: found %d visible procs\n", count);
#endif            

    for (loop = 0; (loop < count) && (spring_pid == -1); loop++) {
#ifdef DEBUG
        fprintf(stderr,"PID: checking process %d (%s)\n", kp->kp_proc.p_pid, kp->kp_proc.p_comm);
#endif              

        if (!strcasecmp(kp->kp_proc.p_comm,"SpringBoard")) {
            spring_pid = kp->kp_proc.p_pid;
        }
        kp++;
    }

    free(process_buffer);
    
    return spring_pid;
}

int main(int argc, char **argv)
{
tryagain:

//We want to wait until Springboard has run, before we should open up
     sleep(1);
     while (springboard_pid() == -1)
		sleep(2);
	 sleep(5);
	 if (springboard_pid() == -1) goto tryagain;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	return UIApplicationMain(argc, argv, [MobileStack class]);
}
