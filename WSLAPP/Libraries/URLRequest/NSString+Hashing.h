

#import <Foundation/Foundation.h>


@interface NSString (NSString_Hashing)

- (NSString *)MD5Hash;

+(NSString*)fileMD5:(NSString*)path;

+(NSString*)dataMD5:(NSData*)data;
@end
