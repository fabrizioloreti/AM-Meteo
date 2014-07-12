//
//  Connection.h
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 03/07/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMMeteoConnDelegate
@required

- (void) meteoForCallback:(int) exit_status response: (NSMutableArray*) result updatedAt: (NSString*) update;

@end

@interface Connection : NSObject
{
    id<AMMeteoConnDelegate> delegate;
}

- (void) meteoFor: (NSString*) url;

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSURLConnection* theConnection;
@property (nonatomic, retain) NSMutableData* receivedData;

@end
