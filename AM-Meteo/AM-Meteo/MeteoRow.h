//
//  MeteoRow.h
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 04/07/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeteoRow : NSObject

@property (nonatomic, strong) NSString* titleDay;
@property (nonatomic, strong) NSString* day;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* imgWeather;
@property (nonatomic, strong) NSString* temp;
@property (nonatomic, strong) NSString* tempPerc;
@property (nonatomic, strong) NSString* imgWind;
@property (nonatomic, strong) NSString* windDir;

@end
