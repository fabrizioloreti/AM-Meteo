//
//  FavoritesDAO.m
//  iFS
//
//  Created by Fabrizio Loreti on 22/12/13.
//  Copyright (c) 2013 sistematica. All rights reserved.
//

#import "FavoritesDAO.h"
#import "Favorites.h"

@implementation FavoritesDAO

-(BOOL) insertFavorites:(NSString *)citta withUrl:(NSString *)citta_url
{
    NSMutableArray* checkCitta = [self getFavorites:[NSString stringWithFormat:@" where citta = '%@'", citta]];
    
    if(checkCitta != nil && [checkCitta count] > 0)
        return YES;
    
    
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent: dbFile];
    
    // Apre il database
    if(!(sqlite3_open([documentPath UTF8String], &db) == SQLITE_OK))
    {
        NSLog(@"[AM-Meteo] - An error has occured.");
        return NO;
    }
    else
    {
        NSString * insert = [[NSString alloc] initWithFormat:@"insert into t_favorites(citta, citta_url) values('%@', '%@');", citta, citta_url];
        
        NSLog(@"[AM-Meteo] - eseguendo: %@", insert);
        
        const char * sql = [insert UTF8String];
        
        sqlite3_stmt *sqlStatement;
        
        if(sqlite3_prepare_v2(db, sql, -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"[AM-Meteo] - Problem with prepare statement");
            insert = nil;
            return NO;
        }
        else
        {
            if(sqlite3_step(sqlStatement)==SQLITE_DONE)
            {
                sqlite3_finalize(sqlStatement);
                sqlite3_close(db);
            }
            
            insert = nil;
            return  YES;
        }
    }
}

-(BOOL) deleteFavorites:(NSString *)citta
{
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent: dbFile];
    
    // Apre il database
    if(!(sqlite3_open([documentPath UTF8String], &db) == SQLITE_OK))
    {
        NSLog(@"[AM-Meteo] - An error has occured.");
        return NO;
    }
    else
    {
        NSString * delete = [[NSString alloc] initWithFormat:@"delete from t_favorites where citta = '%@';", citta];
        
        NSLog(@"[AM-Meteo] - eseguendo: %@", delete);
        
        const char * sql = [delete UTF8String];
        
        sqlite3_stmt *sqlStatement;
        
        if(sqlite3_prepare_v2(db, sql, -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"[AM-Meteo] - Problem with prepare statement");
            delete = nil;
            return NO;
        }
        else
        {
            if(sqlite3_step(sqlStatement)==SQLITE_DONE)
            {
                sqlite3_finalize(sqlStatement);
                sqlite3_close(db);
            }
            
            delete = nil;
            return  YES;
        }
    }
}

-(NSMutableArray *) getFavorites:(NSString *)where
{
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent: dbFile];
    
    NSMutableArray *favoritesArr = [[NSMutableArray alloc] init];
    
    // Apre il database
    if(!(sqlite3_open([documentPath UTF8String], &db) == SQLITE_OK))
    {
        NSLog(@"[iFS] - An error has occured.");
        return NO;
    }
    else
    {
        NSString* select = @"select citta, citta_url from t_favorites ";
        
        if(where != nil)
            select = [select stringByAppendingString:where];
        
        select = [select stringByAppendingString:@";"];
        
        NSLog(@"[AM-Meteo] eseguendo: %@", select);
        
        const char * sql = [select UTF8String];
        
        sqlite3_stmt *sqlStatement;
        
        if(sqlite3_prepare_v2(db, sql, -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare statement");
            return nil;
        }
        else
        {
            // Scorre il result set
            while (sqlite3_step(sqlStatement)==SQLITE_ROW)
            {
                // Controlla che la prima colonna non sia null
                // se null passa alla successiva
                char * checkChar = (char*)sqlite3_column_text(sqlStatement, 0);
                
                if(checkChar != NULL)
                {
                    Favorites* fav = [[[Favorites alloc] init] initByStatement:sqlStatement];
                    
                    [favoritesArr addObject:fav];
                    
                    fav = nil;
                }
            }
            
            // Chiude statemente e db
            sqlite3_finalize(sqlStatement);
            sqlite3_close(db);
            
            select = nil;
        }
    }
    
    return favoritesArr;
}

@end
