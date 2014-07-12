//
//  AppDelegate.h
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 21/06/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <sqlite3.h>


extern sqlite3 *db;
extern NSString *dbFile;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

@end
