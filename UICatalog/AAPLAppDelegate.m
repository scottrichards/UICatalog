/*
        File: AAPLAppDelegate.m
    Abstract: The application-specific delegate class.
     Version: 2.12
    
    Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
    Inc. ("Apple") in consideration of your agreement to the following
    terms, and your use, installation, modification or redistribution of
    this Apple software constitutes acceptance of these terms.  If you do
    not agree with these terms, please do not use, install, modify or
    redistribute this Apple software.
    
    In consideration of your agreement to abide by the following terms, and
    subject to these terms, Apple grants you a personal, non-exclusive
    license, under Apple's copyrights in this original Apple software (the
    "Apple Software"), to use, reproduce, modify and redistribute the Apple
    Software, with or without modifications, in source and/or binary forms;
    provided that if you redistribute the Apple Software in its entirety and
    without modifications, you must retain this notice and the following
    text and disclaimers in all such redistributions of the Apple Software.
    Neither the name, trademarks, service marks or logos of Apple Inc. may
    be used to endorse or promote products derived from the Apple Software
    without specific prior written permission from Apple.  Except as
    expressly stated in this notice, no other rights or licenses, express or
    implied, are granted by Apple herein, including but not limited to any
    patent rights that may be infringed by your derivative works or by other
    works in which the Apple Software may be incorporated.
    
    The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
    MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
    THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
    OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
    
    IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
    MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
    AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
    STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
    
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    
*/

#import "AAPLAppDelegate.h"
#import "APNLib/APNLib.h"
#import <Parse/Parse.h>

@interface AAPLAppDelegate ()
@property (strong, nonatomic) UIAlertView *notificationAlert;
@property (strong, nonatomic) NSString *lastNotificationURL;
@end

@implementation AAPLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.apnLib = [[APNLib alloc] init];
    // ****************************************************************************
    // Fill in the following with your Parse appId and clientKey:

    [Parse setApplicationId:@"qIEmwggxC77ey7DUFwTAP4nx8TGSqs5mt3P0tuWR"
                  clientKey:@"HhwiTF8Zo6K0gOAnnnpHCbn2iUcj3n5Vx6skOGeA"];
    
    
    // Override point for customization after application launch.
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
 //   [self.apnLib initWithParseAppId:@"xOlRZtt64oZelB9I2pZuypXPdpKeB9UthAvEupvX" clientKey:@"PvOJjpf7s0tsanib5JyzHaOgglZjqTNLSX4TwkO8"];
    
    UILocalNotification *localNotification =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self handeLocalNotification:localNotification];
    }

    
    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
            [self handleRemoteNotification:dictionary];
		}
	}
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleRemoteNotification:userInfo];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo {
    NSString *urlString = [userInfo objectForKey:@"url"];
    NSDictionary *apsDictionary = [userInfo objectForKey:@"aps"];
    NSString *alertString = [apsDictionary objectForKey:@"alert"];
    NSLog(@"alert: %@, url: %@",alertString,urlString);
    self.lastNotificationURL = urlString;
    [self displayAlert:alertString url:urlString];
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self handeLocalNotification:notification];
}

- (void)handeLocalNotification:(UILocalNotification *)notification
{
    NSString *message = notification.alertBody;
    NSString *url;
    if (notification.userInfo) {
        url = [notification.userInfo objectForKey:@"url"];
    }
    self.lastNotificationURL = url;
    [self displayAlert:message url:url];
}

- (void)displayAlert:(NSString *)message url:(NSString *)url
{
    if (self.notificationAlert) {
        self.notificationAlert.message = message;
    } else {
        self.notificationAlert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"View", nil];
        
        [self.notificationAlert show];
    }
}

-(void)openURL:(NSString *)urlParameters
{
    NSString *urlString = [NSString stringWithFormat:@"http://uicatalog.parseapp.com%@",urlParameters];
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"Open URL");
        [self openURL:self.lastNotificationURL];
    } else {
        NSLog(@"Do Nothing");
    }
    self.notificationAlert = nil;
}

@end
