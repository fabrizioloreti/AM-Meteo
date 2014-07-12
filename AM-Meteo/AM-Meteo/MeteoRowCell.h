//
//  MeteoRowCell.h
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 04/07/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeteoRowCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* lblDateTime;
@property (nonatomic, strong) IBOutlet UIImageView* imgWeather;
@property (nonatomic, strong) IBOutlet UILabel* lblTemp;
@property (nonatomic, strong) IBOutlet UILabel* lblTempPerc;
@property (nonatomic, strong) IBOutlet UIImageView* imgWind;
@property (nonatomic, strong) IBOutlet UILabel* lblWindDir;

@end
