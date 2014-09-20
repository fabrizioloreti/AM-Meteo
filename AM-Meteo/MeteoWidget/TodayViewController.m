//
//  TodayViewController.m
//  MeteoWidget
//
//  Created by Fabrizio Loreti on 19/09/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "WidgetEle.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

static Connection* conn;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    conn = [[Connection alloc] init];
    [conn setDelegate:self];
    
    self.preferredContentSize = CGSizeMake(320, 75);
    [self getMeteoInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
    [self getMeteoInfo];
}

-(void) getMeteoInfo
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.sistematica.AM-Meteo"];
    NSString *city = (NSString*)[defaults valueForKey:@"MyCity"];
    _lblCity.text = city;
    
    NSString* urlConn = (NSString*)[defaults valueForKey:@"MyCityUrl"];
    
    NSLog(@"CONNECTION TO %@", urlConn);
    
    [conn meteoFor:urlConn];
}

#pragma mark - AMMeteo Delegate

-(void) meteoForCallback:(int)exit_status response:(NSMutableArray *)result updatedAt:(NSString *)update
{
    update = [[update componentsSeparatedByString:@" "] objectAtIndex:1];
              
    _lblUpdateDate.text = update;
    
    if(result != nil)
    {
        int i=0;
        for (WidgetEle* wEle in result)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://www.meteoam.it/", wEle.imgString]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:data];
            
            if(i==0)
            {
                _lblTime1.text = wEle.time;
                _lblWeatherImg1.image = img;
            }
            else if(i==1)
            {
                _lblTime2.text = wEle.time;
                _lblWeatherImg2.image = img;
            }
            else if(i==2)
            {
                _lblTime3.text = wEle.time;
                _lblWeatherImg3.image = img;
            }
            i++;
        }
    }
    else
        NSLog(@"RESULT NULL");
}

@end
