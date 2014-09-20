//
//  MeteoRow.m
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 04/07/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import "MeteoRow.h"

@implementation MeteoRow

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.titleDay = nil;
        self.day = nil;
        self.time = nil;
        self.imgWeather = nil;
        self.temp = nil;
        self.tempPerc = nil;
        self.imgWind = nil;
        self.windDir = nil;
    }
    
    return self;
}

@end
