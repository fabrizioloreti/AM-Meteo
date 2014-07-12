//
//  Favorites.m
//  iFS
//
//  Created by Fabrizio Loreti on 22/12/13.
//  Copyright (c) 2013 sistematica. All rights reserved.
//

#import "Favorites.h"

@implementation Favorites

@synthesize citta;
@synthesize citta_url;

-(id) init
{
    self = [super init];
    
    self.citta = nil;
    self.citta_url = nil;
    
    return  self;
}

-(id) initByStatement:(sqlite3_stmt *)sqlStatement
{
    self = [super init];
    
    self.citta = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement, 0)];
    self.citta_url = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement, 1)];
    
    return self;
}

@end
