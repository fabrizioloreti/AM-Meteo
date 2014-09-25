//
//  Connection.m
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 03/07/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import "Connection.h"
#import "WidgetEle.h"

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
    NSMutableArray* meteoTableArray = [[NSMutableArray alloc] init];
    
    unsigned long beginIndex = [html rangeOfString:@"<table id=\"previsioniOverlTable\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">"].location + @"<table id=\"previsioniOverlTable\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">".length;
    
    html = [html substringFromIndex: beginIndex];
    
    beginIndex = [html rangeOfString:@"</tr>"].location + @"</tr>".length;
    
    html = [html substringFromIndex: beginIndex];
    
    unsigned long endIndex = [html rangeOfString: @"</table>"].location;
    
    html = [html substringWithRange:NSMakeRange(0, endIndex)];
    
   
    NSArray *trList = [html componentsSeparatedByString:@"<tr>"];
    
    WidgetEle *wEle = nil;
    
    for(int i=1;i<[trList count];i++)
    {
        NSString* trEle = [trList objectAtIndex:i];
        wEle = [[WidgetEle alloc] init];
        
        if(wEle.time == nil)
        {
            NSRange beginRange = [trEle rangeOfString:@"<td class=\"previsioniRow\" align=\"center\">"];
            
            NSString* trTime = [trEle substringFromIndex:beginRange.location + @"<td class=\"previsioniRow\" align=\"center\">".length];
            
            unsigned int endIndex = [trTime rangeOfString: @"</td>"].location;
            
            trTime = [trTime substringWithRange:NSMakeRange(0, endIndex)];
            
            NSDate *date = [sdfHour dateFromString:trTime];
            
            long lDate = [date timeIntervalSince1970] + tzOffset;
            date = [date initWithTimeIntervalSince1970:lDate];
            
            wEle.time = [sdfHour stringFromDate:date];
        }
        
        if(wEle.imgString == nil)
        {
            NSRange beginRange = [trEle rangeOfString:@"<td  class=\"previsioniRow\" align=\"center\" bgcolor=\"#B0D6EB\"><img src=\""];
            
            NSString* trImage = [trEle substringFromIndex:beginRange.location + @"<td  class=\"previsioniRow\" align=\"center\" bgcolor=\"#B0D6EB\"><img src=\"".length];
            
            unsigned int endIndex = [trImage rangeOfString: @"\" title=\""].location;
            
            trImage = [trImage substringWithRange:NSMakeRange(0, endIndex)];
            
            wEle.imgString = trImage;
        }

        if(wEle.temp == nil)
        {
            NSRange beginRange = [trEle rangeOfString:@"<strong>"];
            
            NSString* trTemp = [trEle substringFromIndex:beginRange.location + @"<strong>".length];
            
            unsigned int endIndex = [trTemp rangeOfString: @"</strong>"].location;
            
            trTemp = [trTemp substringWithRange:NSMakeRange(0, endIndex)];
            
            wEle.temp = trTemp;
        }

        [meteoTableArray addObject:wEle];
        
        
        if(i == 3)
            break;
    }
    return meteoTableArray;
}


@end
