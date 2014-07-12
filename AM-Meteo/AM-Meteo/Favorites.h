//
//  Favorites.h
//  iFS
//
//  Created by Fabrizio Loreti on 22/12/13.
//  Copyright (c) 2013 sistematica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Favorites : NSObject

@property (strong, nonatomic) NSString *citta;
@property (strong, nonatomic) NSString *citta_url;

- (id) initByStatement:(sqlite3_stmt*)sqlStatement;

@end
