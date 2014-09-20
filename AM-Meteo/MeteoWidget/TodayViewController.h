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

@property (nonatomic, strong) IBOutlet UILabel* lblUpdateDate;
@property (nonatomic, strong) IBOutlet UILabel* lblCity;
@property (nonatomic, strong) IBOutlet UILabel* lblTime1;
@property (nonatomic, strong) IBOutlet UILabel* lblTime2;
@property (nonatomic, strong) IBOutlet UILabel* lblTime3;

@property (nonatomic, strong) IBOutlet UIImageView* lblWeatherImg1;
@property (nonatomic, strong) IBOutlet UIImageView* lblWeatherImg2;
@property (nonatomic, strong) IBOutlet UIImageView* lblWeatherImg3;
@end
