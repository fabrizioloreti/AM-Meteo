//
//  AppDelegate.m
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 21/06/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

extern sqlite3 *db = nil;
extern NSString *dbFile = @"amMeteo.sqlite";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    /*self.viewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
     self.window.rootViewController = self.viewController;*/
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSString *home = @"MainView";
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].scale == 2.0f)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960)
            {
                NSLog(@"iPhone 4, 4s Retina Resolution");
            }
            if(result.height == 1136)
            {
                NSLog(@"iPhone 5 Resolution");
                home = @"MainView_5";
            }
            if(result.height == 1334)
            {
                NSLog(@"iPhone 6 Resolution");
                home = @"MainView_6";
            }
        }
        else
        {
            NSLog(@"iPhone Standard Resolution");
        }
    }
    else
    {
        if ([UIScreen mainScreen].scale == 2.0f) {
            NSLog(@"iPad Retina Resolution");
        } else{
            NSLog(@"iPad Standard Resolution");
        }
    }
    
    UINavigationController* navCon = [[UINavigationController alloc]init];
    [navCon setNavigationBarHidden:YES];
    _viewController = [[ViewController alloc] initWithNibName:home bundle:nil] ;
    
    [ navCon pushViewController: _viewController animated:NO];
    self.window.rootViewController = navCon;
    
    // WHITE STATUS BAR
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self createEditableCopyOfDatabaseIfNeeded];
    [self openDB];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) createEditableCopyOfDatabaseIfNeeded
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbFile];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
        return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbFile];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"[AM-Meteo] - Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (void) openDB
{
    char *emsg;
    BOOL fileExist;
    
    //Get list of directories in Document path
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Define new path for database
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:dbFile];
    
    fileExist = [[NSFileManager alloc] fileExistsAtPath:documentPath];
    
    if(fileExist)
    {
        NSLog(@"[AM-Meteo] - DB File Exists: %@", documentPath);
        
        if(!(sqlite3_open([documentPath UTF8String], &db) == SQLITE_OK))
        {
            NSLog(@"[AM-Meteo] - An error has occured.");
        }
        else
        {
            //---------------------------
            // TABELLA PROFILO
            //---------------------------
            const char *profileTable = "create table if not exists t_favorites(citta string, citta_url string);";
            
            NSLog(@"[AM-Meteo] - Creating %@ table (or nothing if already exists)", @"t_favorites");
            
            if(sqlite3_exec(db, profileTable, NULL, NULL, &emsg) != SQLITE_OK)
            {
                NSLog(@"[AM-Meteo] - There is a problem with statement");
            }
            
            @try
            {
                sqlite3_close(db);
            }
            @catch (NSException *exception)
            {
                
            }
        }
    }
    else
    {
        NSLog(@"File not exists");
    }
}

@end
