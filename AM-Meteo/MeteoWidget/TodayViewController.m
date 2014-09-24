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

static NSMutableArray *cityArr;
static NSMutableArray* urlArr;
static int lastCity;

static NSString* defaultCity;
static NSString* defaultUrl;

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
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.sistematica.AM-Meteo"];
    cityArr = (NSMutableArray*)[defaults valueForKey:@"CityArray"];
    urlArr = (NSMutableArray*)[defaults valueForKey:@"UrlArray"];
    lastCity = 0;
    
    defaultCity = (NSString*)[defaults valueForKey:@"MyCity"];
    defaultUrl = (NSString*)[defaults valueForKey:@"MyCityUrl"];
    
    if(cityArr != nil && cityArr.count > 0)
    {
        defaultCity = (NSString*)[cityArr objectAtIndex:lastCity];
        defaultUrl = (NSString*)[urlArr objectAtIndex:lastCity];
        
        lastCity = 1;
    }
    
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

-(IBAction)changeCity:(id)sender
{
    NSLog(@"CHANGE!");
    
    if(cityArr != nil && cityArr.count > 0)
    {
        if(cityArr.count == lastCity)
            lastCity = 0;
        
        defaultCity = (NSString*)[cityArr objectAtIndex:lastCity];
        defaultUrl = (NSString*)[urlArr objectAtIndex:lastCity];
        
        [self getMeteoInfo];
        
        lastCity += 1;
    }
}

-(void) getMeteoInfo
{
    [_indicator setHidden:NO];
    
    [_btnCity setTitle:defaultCity forState:UIControlStateNormal];
    
    NSString* urlConn = defaultUrl;
    
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
                _imgWeather1.image = img;
                _lblTemp1.text = [NSString stringWithFormat:@"%@°", wEle.temp];
            }
            else if(i==1)
            {
                _lblTime2.text = wEle.time;
                _imgWeather2.image = img;
                _lblTemp2.text = [NSString stringWithFormat:@"%@°", wEle.temp];
            }
            else if(i==2)
            {
                _lblTime3.text = wEle.time;
                _imgWeather3.image = img;
                _lblTemp3.text = [NSString stringWithFormat:@"%@°", wEle.temp];
            }
            i++;
        }
    }
    else
        NSLog(@"RESULT NULL");
    
    
    [_indicator setHidden:YES];
}

@end
