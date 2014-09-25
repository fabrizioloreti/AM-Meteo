//
//  Connection.m
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 03/07/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import "Connection.h"
#import "TFHpple.h"
#import "MeteoRow.h"

@implementation Connection

@synthesize delegate;
@synthesize theConnection;
@synthesize receivedData;

static NSString* baseUrl;

static NSString* lastDay = nil;

static NSDateFormatter* sdf;
static NSDateFormatter* sdfOut;
static NSDateFormatter* sdfHour;

static long tzOffset;

-(void) meteoFor:(NSString *)url
{
    [self connectTo:[NSString stringWithFormat:@"%@%@", baseUrl, url] withParams:nil];
}

-(id) init
{
    self = [super init];
    
    sdf = [[NSDateFormatter alloc] init];
    [sdf setDateFormat:@"dd-MM-yyyy : HH:mm "];
    
    sdfOut = [[NSDateFormatter alloc] init];
    [sdfOut setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    sdfHour = [[NSDateFormatter alloc] init];
    [sdfHour setDateFormat:@"HH:mm"];
    
    tzOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    
    baseUrl = @"http://www.meteoam.it/";
    
    return self;
}

-(void) connectTo: (NSString*) url withParams: (NSString*) getParams
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(theConnection)
    {
        NSLog(@"[AM-METEO] - Got the connection");
        receivedData = [[NSMutableData data] init];
    }
    else
    {
        NSLog(@"[AM-METEO] - No connection");
        [[self delegate] meteoForCallback:-1 response:nil updatedAt:nil];
    }
}

- (void) connection: (NSURLConnection*) connection didReceiveData:(NSData *)data
{
    [receivedData appendData: data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //---------------------------
    // PLEASE WAIT..... CLOSE
    //---------------------------
    NSLog(@"[AM-METEO] - : %@ ", [[NSString alloc] initWithFormat:@"CONNECTION FAIL!"]);
    NSLog(@"[AM-METEO] - %@",[error localizedDescription]);
    
    [[self delegate] meteoForCallback:-1 response:nil updatedAt:nil];
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableArray* result;
    
    unsigned char byteBuffer[[receivedData length]];
    
    [receivedData getBytes: byteBuffer length:[receivedData length]];
    
    NSString* meteoPage = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    NSString* update = @"";
    
    result = [self parseHTML:meteoPage];
    
    @try {
        unsigned long beginIndex = [meteoPage rangeOfString:@"Aggiornamento pagina: "].location + @"Aggiornamento pagina: ".length;
        
        update = [meteoPage substringFromIndex: beginIndex];
        
        unsigned long endIndex = [update rangeOfString:@"UTC."].location;
        
        update = [update substringWithRange:NSMakeRange(0, endIndex)];
        
        NSDate *date = [sdf dateFromString:update];
        
        // aggiungere GMT
        //long dstOffset = [[NSTimeZone localTimeZone] daylightSavingTimeOffset];
        
        long lDate = [date timeIntervalSince1970] + tzOffset;
        date = [date initWithTimeIntervalSince1970:lDate];
        
        update = [sdfOut stringFromDate:date];
    }
    @catch (NSException *exception) {
        
    }
    
    [[self delegate] meteoForCallback:0 response:result updatedAt:update];
}


-(NSMutableArray*) parseHTML: (NSString*) html
{
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
    
    NSString *htmlXpathQueryString = @"//table[@id='previsioniOverlTable']/tr/td";
    NSArray *htmlNodes = [htmlParser searchWithXPathQuery:htmlXpathQueryString];
    
    NSMutableArray* meteoTableArray = [[NSMutableArray alloc] init];
    MeteoRow* meteoRow = [[MeteoRow alloc] init];
    
    int i = 0;
    for (TFHppleElement *element in htmlNodes)
    {
        if([[element firstChild] content] == nil)
        {
            TFHppleElement *img = [element firstChildWithTagName:@"img"];
            TFHppleElement *div = [element firstChildWithTagName:@"div"];
            TFHppleElement *strong = [element firstChildWithTagName:@"strong"];
            
            if([element objectForKey:@"colspan"] != nil)
                i++;
            
            if(img != nil)
            {
                NSString* title = [img objectForKey:@"title"];
                
                if(title != nil)
                {
                    // IMMAGINE METEO
                    NSString* imgWeather = [img objectForKey:@"src"];
                    meteoRow.imgWeather = [NSString stringWithFormat:@"%@%@", baseUrl, imgWeather];
                }
                else
                {
                    // IMMAGINE VENTO
                    NSString* imgWind = [img objectForKey:@"src"];
                    meteoRow.imgWind = [NSString stringWithFormat:@"%@/%@", baseUrl, imgWind];
                }
            }
            else if(div != nil)
            {
                // TEMP PERC
                NSString* tempPerc = [[div firstChild] content];
                meteoRow.tempPerc = tempPerc;
            }
            else if(strong != nil)
            {
                // TEMP
                NSString* temp = [[strong firstChild] content];
                meteoRow.temp = temp;
            }
        }
        else
        {
            if(i == 0)
            {
                // DAY
                meteoRow.day = [[element firstChild] content];
                
                if(lastDay == nil || [lastDay isEqualToString:meteoRow.day] == NO)
                {
                    lastDay = meteoRow.day;
                    
                    MeteoRow* titleRow = [[MeteoRow alloc] init];
                    titleRow.titleDay = meteoRow.day;
                    
                    [meteoTableArray addObject:titleRow];
                }
            }
            else if (i == 1)
            {
                // TIME
                NSDate *date = [sdfHour dateFromString:[[element firstChild] content]];
                
                long lDate = [date timeIntervalSince1970] + tzOffset;
                date = [date initWithTimeIntervalSince1970:lDate];
                
                meteoRow.time = [sdfHour stringFromDate:date];
            }
            else if (i == 6)
            {
                // WIND DIR
                
                NSArray *windArr = [element children];
                
                for (int j=0; j<[windArr count]; j++)
                {
                    TFHppleElement *ele = (TFHppleElement*) [windArr objectAtIndex:j];
                    NSString* eleTxt = [ele content];
                    
                    if([eleTxt hasPrefix:@"Intensità media"])
                    {
                        int beginIndex = [eleTxt rangeOfString:@"("].location + 1;
                        eleTxt = [eleTxt substringFromIndex: beginIndex];
                        int endIndex = [eleTxt rangeOfString:@")"].location;
                        eleTxt = [eleTxt substringWithRange:NSMakeRange(0, endIndex)];
                        
                        meteoRow.windDir = eleTxt;
                    }
                }
            }
        }
        
        i++;
        lastDay = meteoRow.day;
        
        if(i == 7)
        {
            //NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            
            [meteoTableArray addObject:meteoRow];
            
            meteoRow = [[MeteoRow alloc] init];
            
            i = 0;
        }
    }
    
    return meteoTableArray;
}


@end
