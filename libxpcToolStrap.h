
@import CoreFoundation;
@import Foundation;
#import <objc/runtime.h>  


@interface libxpcToolStrap : NSObject

@property void (^constHandler)(NSString *msgID,NSDictionary *userInfo);
@property void (^constReplyHandler)(NSString *msgID,NSDictionary *userInfo);


- (NSString *) defineUniqueName:(NSString *)uname;
- (void) postToClientWithMsgID:(NSString *)msgID uName:(NSString *)uname userInfo:(NSDictionary *)dict;
- (void) postToClientAndReceiveReplyWithMsgID:(NSString *)msgID uName:(NSString *)uname userInfo:(NSDictionary *)dict;
- (void) addTarget:(id)target selector:(SEL)sel forMsgID:(NSString *)msgID uName:(NSString *)uName;
- (void) startEventWithMessageIDs:(NSArray<NSString *> *)ids uName:(NSString *)uName;

+ (instancetype) shared;
@end
 



typedef enum {
	libnotificationde_MESSAGE_SHOW_MSG,
    libnotificationde_MESSAGE_HIDE_MSG,
} libnotificationde_MESSAGE_ID;

static NSDictionary *convertXPCDictionaryToNSDictionary(xpc_object_t xpcDict) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    xpc_dictionary_apply(xpcDict, ^bool(const char *key, xpc_object_t value) {
        @try {
            if (key == NULL || value == NULL) {
                // CLogLib(@"Skipping null key or value");
                return true;
            }

            NSString *nsKey = [NSString stringWithUTF8String:key];
            id nsValue = nil;
            
            xpc_type_t valueType = xpc_get_type(value);
            if (valueType == XPC_TYPE_STRING) {
                nsValue = [NSString stringWithUTF8String:xpc_string_get_string_ptr(value)];
            } else if (valueType == XPC_TYPE_INT64) {
                nsValue = [NSNumber numberWithLongLong:xpc_int64_get_value(value)];
            } else if (valueType == XPC_TYPE_BOOL) {
                nsValue = [NSNumber numberWithBool:xpc_bool_get_value(value)];
            } else if (valueType == XPC_TYPE_DOUBLE) {
                nsValue = [NSNumber numberWithDouble:xpc_double_get_value(value)];
            } else if (valueType == XPC_TYPE_ARRAY) {
            } else if (valueType == XPC_TYPE_DICTIONARY) {
                nsValue = convertXPCDictionaryToNSDictionary(value);
            } else {
                // CLogLib(@"Unsupported XPC type");
            }

            if (nsValue) {
                dict[nsKey] = nsValue;
            } else {
                // CLogLib(@"Null nsValue for key: %@", nsKey);
            }
        } @catch (NSException *exception) {
            // CLogLib(@"Exception converting key %s: %@", key, exception);
        }

        return true;
    });
    return [dict copy];
}

static xpc_object_t convertNSDictionaryToXPCDictionary(NSDictionary *dict) {
    xpc_object_t xpcDict = xpc_dictionary_create(NULL, NULL, 0);
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) {
            // CLogLib(@"Skipping non-string key: %@", key);
            return;
        }

        const char *cKey = [key UTF8String];
        
        if ([obj isKindOfClass:[NSString class]]) {
            xpc_dictionary_set_string(xpcDict, cKey, [obj UTF8String]);
        } else if ([obj isKindOfClass:[NSNumber class]]) {

            const char *objCType = [obj objCType];
            if (strcmp(objCType, @encode(BOOL)) == 0) {
                xpc_dictionary_set_bool(xpcDict, cKey, [obj boolValue]);
            } else if (strcmp(objCType, @encode(int)) == 0 ||
                       strcmp(objCType, @encode(long)) == 0 ||
                       strcmp(objCType, @encode(long long)) == 0 ||
                       strcmp(objCType, @encode(short)) == 0 ||
                       strcmp(objCType, @encode(char)) == 0) {
                xpc_dictionary_set_int64(xpcDict, cKey, [obj longLongValue]);
            } else if (strcmp(objCType, @encode(float)) == 0 ||
                       strcmp(objCType, @encode(double)) == 0) {
                xpc_dictionary_set_double(xpcDict, cKey, [obj doubleValue]);
            } else {
                // CLogLib(@"Unsupported NSNumber type for key: %@", key);
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            xpc_object_t nestedDict = convertNSDictionaryToXPCDictionary((NSDictionary *)obj);
            xpc_dictionary_set_value(xpcDict, cKey, nestedDict);

        } else {
            // CLogLib(@"Unsupported type for key: %@", key);
        }
    }];
    
    return xpcDict;
}
