@import Foundation;


#import <sharedutils.h>
#import "symbolication.h"
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>



%ctor {

	void *sandyHandle = dlopen("/var/jb/usr/lib/libsandy.dylib", RTLD_LAZY);
          if (sandyHandle) {

              int (*__dyn_libSandy_applyProfile)(const char *profileName) = (int (*)(const char *))dlsym(sandyHandle, "libSandy_applyProfile");
              if (__dyn_libSandy_applyProfile) {
			     __dyn_libSandy_applyProfile("libnotifications");
				 __dyn_libSandy_applyProfile("xpcToolStrap");
              }
		    }
}