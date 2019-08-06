# libnotifications
App Notification Library for Jailbroken Devices

`Requires iOS10+`

This must be used in a process with privileges. You can set up a rocketbootstrap server in SpringBoard if you're using in a sandboxed process & run this code there. 

How to use in your tweak:

```objc

#include <dlfcn.h>

@interface CPNotification : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId;
@end

void *handle = dlopen("/usr/lib/libnotifications.dylib", RTLD_LAZY);
if (handle != NULL) {                                            
    [objc_getClass("CPNotification") showAlertWithTitle:@"Holy Smokes!"
                                                message:@"This is the message!"
                                               userInfo:@{@"" : @""}
                                             badgeCount:1
                                              soundName:@"can be nil.caff" //research UNNotificationSound
                                                  delay:1.00 //cannot be zero & cannot be < 60 if repeats is YES
                                                repeats:NO
                                               bundleId:@"com.cokepokes.iNutt"];                                     
	dlclose(handle);
}
	
```
