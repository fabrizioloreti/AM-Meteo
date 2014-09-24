//
//  TodayViewController.h
//  MeteoWidget
//
//  Created by Fabrizio Loreti on 19/09/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connection.h"

@interface TodayViewController : UIViewController <AMMeteoConnDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, strong) IBOutlet UILabel* lblUpdateDate;

@property (nonatomic, strong) IBOutlet UIButton* btnCity;

@property (nonatomic, strong) IBOutlet UILabel* lblTime1;
@property (nonatomic, strong) IBOutlet UILabel* lblTime2;
@property (nonatomic, strong) IBOutlet UILabel* lblTime3;


@property (nonatomic, strong) IBOutlet UILabel* lblTemp1;
@property (nonatomic, strong) IBOutlet UILabel* lblTemp2;
@property (nonatomic, strong) IBOutlet UILabel* lblTemp3;

@property (nonatomic, strong) IBOutlet UIImageView* imgWeather1;
@property (nonatomic, strong) IBOutlet UIImageView* imgWeather2;
@property (nonatomic, strong) IBOutlet UIImageView* imgWeather3;

-(IBAction)changeCity:(id)sender;

@end
