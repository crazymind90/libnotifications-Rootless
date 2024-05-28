//
//  libnotifications.mm
//  libnotifications
//
//  Created by CokePokes on 8/2/19.
//  Copyright (c) 2019 ___ORGANIZATIONNAME___. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

 

#import <Foundation/Foundation.h>
#include <dlfcn.h>
#import "../libxpcToolStrap.h"

 

#define CPLog(fmt, ...) NSLog((@"\e[4#1mCPNotification\e[m \E[3#2m[Line %d]:\e[m " fmt), __LINE__, ##__VA_ARGS__);
#define CLog(format, ...) NSLog(@"CM90~[D] : " format, ##__VA_ARGS__)




static xpc_object_t libnotificationdeSendMessage(xpc_object_t message)
{

    xpc_connection_t connection = xpc_connection_create_mach_service("com.cokepokes.libnotificationde", 0, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);

    if (connection) {
        CLog(@"[+] Successfully connected to com.cokepokes.libnotificationde as : [PRIVILEGED]");
    } else {
        CLog(@"[-] Something went wrong while connecting to com.cokepokes.libnotificationde as : [PRIVILEGED]");
        return NULL;
    }


    xpc_connection_set_event_handler(connection, ^(xpc_object_t object){
        xpc_type_t type = xpc_get_type(object);
        if (type == XPC_TYPE_CONNECTION) {
            CLog(@"[=] Connection event received.");
        } else if (type == XPC_TYPE_ERROR) {
            CLog(@"[!] XPC server error: %s", xpc_dictionary_get_string(object, XPC_ERROR_KEY_DESCRIPTION));
            return;
        } else {
            CLog(@"[!] Unknown event type received.");
            return;
        }
    });


    xpc_connection_resume(connection);


    xpc_object_t reply = xpc_connection_send_message_with_reply_sync(connection, message);


    if (reply == NULL) {
        CLog(@"[-] Failed to send message to com.cokepokes.libnotificationde.");
        return NULL;
    } else {
        CLog(@"[+] Message successfully sent to com.cokepokes.libnotificationde.");
    }


    xpc_release(connection);

    return reply;
}


static NSDictionary *sendAndReceiveMessage(NSDictionary *userInfoDict, libnotificationde_MESSAGE_ID type){

	xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
	xpc_dictionary_set_int64(message, "id", type);
	xpc_object_t userInfo = convertNSDictionaryToXPCDictionary(userInfoDict);
	xpc_dictionary_set_value(message, "userInfo", userInfo);
	
	xpc_object_t reply = libnotificationdeSendMessage(message);
	if (reply) {
		xpc_type_t replyType = xpc_get_type(reply);
		if (replyType == XPC_TYPE_DICTIONARY) {
			xpc_object_t userInfo_reply = xpc_dictionary_get_value(reply, "userInfo");
			xpc_type_t userInfo_type = xpc_get_type(userInfo_reply);
			if (userInfo_type == XPC_TYPE_DICTIONARY) {
				return convertXPCDictionaryToNSDictionary(userInfo_reply);
			}
		}
	}

    return @{};
}


@interface CPNotification : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId;
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId uuid:(NSString*)uuid silent:(BOOL)silent;
+ (void)hideAlertWithBundleId:(NSString *)bundleId uuid:(NSString*)uuid;
@end

@implementation CPNotification

-(id)init {
	
    if ((self = [super init])) { 

 	 
    }
    return self;
}

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId {
    [CPNotification showAlertWithTitle:title
                               message:message
                              userInfo:userInfo
                            badgeCount:badgeCount
                             soundName:soundName
                                 delay:delay
                               repeats:repeats
                              bundleId:bundleId
                                  uuid:[[NSUUID UUID] UUIDString]
                                silent:NO];
}



+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId uuid:(NSString*)uuid silent:(BOOL)silent {
    
    NSMutableDictionary *constructedDic = [NSMutableDictionary dictionary];
    
    if (title)
        [constructedDic setObject:title forKey:@"title"];
    
    if (message)
        [constructedDic setObject:message forKey:@"message"];
    
    if (userInfo)
        [constructedDic setObject:userInfo forKey:@"userInfo"];
    
    if (badgeCount)
        [constructedDic setObject:[NSNumber numberWithInt:badgeCount] forKey:@"badgeCount"];

    if (soundName)
        [constructedDic setObject:soundName forKey:@"soundName"];
    
    if (delay)
        [constructedDic setObject:[NSNumber numberWithDouble:delay] forKey:@"delay"];
    
    if (repeats)
        [constructedDic setObject:[NSNumber numberWithBool:repeats] forKey:@"repeats"];
    
    if (bundleId)
        [constructedDic setObject:bundleId forKey:@"bundleId"];
    else
        return; //don't proceed. BundleId is required!
    
    if (uuid)
        [constructedDic setObject:uuid forKey:@"uuid"];

    [constructedDic setObject:@(silent) forKey:@"isSilent"];
    
    [constructedDic setObject:@(NO) forKey:@"isHideAlert"];
    
   

    void *sandyHandle = dlopen("/var/jb/usr/lib/libsandy.dylib", RTLD_LAZY);
          if (sandyHandle) {

              int (*__dyn_libSandy_applyProfile)(const char *profileName) = (int (*)(const char *))dlsym(sandyHandle, "libSandy_applyProfile");
              if (__dyn_libSandy_applyProfile) {
			     __dyn_libSandy_applyProfile("libnotifications");
				 __dyn_libSandy_applyProfile("xpcToolStrap");

                CLog(@"[sendAndReceiveMessage] ret : %@",constructedDic);
                sendAndReceiveMessage((NSDictionary*)constructedDic.copy,libnotificationde_MESSAGE_SHOW_MSG);
      }
    }

}


+ (void)hideAlertWithBundleId:(NSString *)bundleId uuid:(NSString*)uuid {
    NSMutableDictionary *constructedDic = [NSMutableDictionary dictionary];
    [constructedDic setObject:@(YES) forKey:@"isHideAlert"];
    
    if (uuid)
        [constructedDic setObject:uuid forKey:@"uuid"];
    else
        return;

    if (bundleId)
        [constructedDic setObject:bundleId forKey:@"bundleId"];
    else { 
        return;
    }
     
    
    sendAndReceiveMessage((NSDictionary*)constructedDic.copy,libnotificationde_MESSAGE_HIDE_MSG);
 

}

@end

