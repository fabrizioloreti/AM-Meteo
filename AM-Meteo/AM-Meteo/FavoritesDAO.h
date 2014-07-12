//
//  FavoritesDAO.h
//  iFS
//
//  Created by Fabrizio Loreti on 22/12/13.
//  Copyright (c) 2013 sistematica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "AppDelegate.h"

@interface FavoritesDAO : NSObject
{
    sqlite3 *db;
}

-(BOOL) insertFavorites:(NSString*) citta withUrl:(NSString*) citta_url;
-(BOOL) deleteFavorites:(NSString*) citta;
-(NSMutableArray*) getFavorites:(NSString *) where;

@end
