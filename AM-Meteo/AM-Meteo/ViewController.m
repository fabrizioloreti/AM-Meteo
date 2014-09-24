//
//  ViewController.m
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 21/06/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import "ViewController.h"
#import "MeteoRow.h"
#import "MeteoRowCell.h"
#import "UIImageView+WebCache.h"
#import "Favorites.h"
#import "FavoritesDAO.h"
#import "UIImage+animatedGIF.h"
#import "VENVersionTracker.h"
#import "UIAlertView+BlockExtensions.h"

@interface ViewController ()

@end

@implementation ViewController


static UITableView* autocompleteTableView;
static NSMutableArray* autocompleteCitta;
static NSMutableArray *pastCitta;

static NSMutableArray* meteoArr;

static NSString* urlCitta;

static NSMutableArray* citta;
static NSMutableArray* cittaURL;

static NSMutableDictionary *citta_urlConn;

static FavoritesDAO* favDAO;
static UITableView* preferitiTableView;
static NSMutableArray* preferitiArr;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self versionTracker];
    
    citta = [[NSMutableArray alloc] init];
    cittaURL = [[NSMutableArray alloc] init];
    citta_urlConn = [[NSMutableDictionary alloc] init];
    
    meteoArr = [[NSMutableArray alloc] init];
    
    favDAO = [[FavoritesDAO alloc] init];
    
    
    _conn = [[Connection alloc] init];
    [_conn setDelegate:self];
    
    _spinner = [[MonkeyActivityIndicator alloc] initMonkeyActivityIndicatorForView:self.view];
    
    //-----------------------------
    // PREFERITI
    //-----------------------------
    preferitiTableView = [[UITableView alloc] initWithFrame:
                          CGRectMake(0, 105, self.view.frame.size.width, 0) style:UITableViewStylePlain];
    preferitiTableView.delegate = self;
    preferitiTableView.dataSource = self;
    
    preferitiTableView.backgroundColor = [UIColor clearColor];
    preferitiTableView.tag = 2;
    
    preferitiTableView.scrollEnabled = YES;
    preferitiTableView.hidden = NO;
    
    preferitiTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:preferitiTableView];
    
    preferitiArr = [self leggiPreferiti];
    if(preferitiArr != nil)
        [preferitiTableView reloadData];
    
    if(preferitiArr == nil || [preferitiArr count] == 0)
    {
        _btnMostraPreferiti.hidden = YES;
    }
    
    //-------------------------------
    // PRECARICO LA LISTA DELLE CITTA
    //-------------------------------
    [self readCitta];
    
    pastCitta = citta; //[[NSMutableArray alloc] initWithObjects:@"Roma", @"Foligno", @"Firenze", @"Fabriano", @"Forli", @"Milano", nil];
    autocompleteCitta = [[NSMutableArray alloc] init];
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:
                             CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height - 105) style:UITableViewStylePlain];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    
    autocompleteTableView.backgroundColor = [UIColor clearColor];
    autocompleteTableView.tag = 0;
    
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    
    autocompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:autocompleteTableView];
    
    //-------------------------------
    // CARICO DATI WIDGET
    //-------------------------------
    [self configureWidget];
}

- (void)viewDidAppear:(BOOL)animated
{
    // aggiungere immagine di loading 
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString: @"http://www.meteoam.it/Storage/SatMobile/ani_rgb_ita.gif"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            
            if(image != nil)
                [_imgSatellite setImage:image];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    _meteoTable.hidden = YES;
    preferitiTableView.hidden = YES;
    autocompleteTableView.hidden = NO;
    _btnAggiungiPreferiti.hidden = YES;
    
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring
                 stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    //NSLog(@"%@", substring);
    substring = [substring uppercaseString];
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    [autocompleteCitta removeAllObjects];
    for(NSString *curString in pastCitta) {
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            [autocompleteCitta addObject:curString];
        }
    }
    [autocompleteTableView reloadData];
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    if(tableView.tag == 0)
        return autocompleteCitta.count;
    else if(tableView.tag == 1)
        return [meteoArr count];
    else if(tableView.tag == 2)
        return preferitiArr.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if(tableView.tag == 0)
    {
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
        }
    
        cell.textLabel.text = [autocompleteCitta objectAtIndex:indexPath.row];
        //NSLog(@"%@", cell.textLabel.text);
        
        if(indexPath.row % 2 == 0)
            cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5f];
        else
            cell.backgroundColor = [UIColor colorWithRed:176.0/255.0 green:214.0/255.0 blue:235.0/255.0 alpha:0.5f];
        
        return cell;
    }
    else if(tableView.tag == 1)
    {
        static NSString *meteoCell = @"MeteoRowCell";
        MeteoRowCell *cellMeteo = [tableView dequeueReusableCellWithIdentifier:meteoCell];
        if(!cellMeteo)
        {
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MeteoRowView" owner: self options: nil];
            for(id currentObject in objects)
            {
                if([currentObject isKindOfClass: [UITableViewCell class]])
                {
                    cellMeteo = (MeteoRowCell *)  currentObject;
                    break;
                }
                
            }
        }
        
        if(indexPath.row % 2 == 0)
            cellMeteo.backgroundColor = [UIColor whiteColor];
        
        
        MeteoRow *obj = [meteoArr objectAtIndex: indexPath.row];
        
        if(obj.titleDay != nil)
        {
            static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
            }
            
            cell.textLabel.text = obj.titleDay;
            //cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:141.0/255.0 blue:27.0/255.0 alpha:0.84];
            cell.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:95.0/255.0 blue:156.0/255.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
            
            return cell;
        }
        
        
        cellMeteo.lblDateTime.text = [NSString stringWithFormat:@"%@",obj.time];
        cellMeteo.lblTemp.text = [NSString stringWithFormat:@"%@ C°", obj.temp];
        cellMeteo.lblTempPerc.text = [NSString stringWithFormat:@"(%@ C°)", obj.tempPerc];
        cellMeteo.lblWindDir.text = [NSString stringWithFormat:@"%@", obj.windDir ?: @"-"];
        
        [cellMeteo.imgWeather setImageWithURL:[NSURL URLWithString: obj.imgWeather]
                    placeholderImage:nil];
        
        [cellMeteo.imgWind setImageWithURL:[NSURL URLWithString: obj.imgWind]
                        placeholderImage:nil];
        
        return cellMeteo;
    }
    else if(tableView.tag == 2)
    {
        static NSString *AutoCompleteRowIdentifier = @"preferitiRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
        }
        
        cell.textLabel.text = ((Favorites*)[preferitiArr objectAtIndex:indexPath.row]).citta;
        
        if(indexPath.row % 2 == 0)
            cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5f];
        else
            cell.backgroundColor = [UIColor colorWithRed:176.0/255.0 green:214.0/255.0 blue:235.0/255.0 alpha:0.5f];
        
        return cell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView.tag == 0)
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        _txtCitta.text = selectedCell.textLabel.text;
        _lblCitta.text = selectedCell.textLabel.text;
    
        autocompleteTableView.hidden = YES;
    }
    else if(tableView.tag == 2)
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        _txtCitta.text = selectedCell.textLabel.text;
        _lblCitta.text = selectedCell.textLabel.text;
        
        autocompleteTableView.hidden = YES;
        
        [self mostraPreferiti:self];
        [self cerca:self];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 0 || tableView.tag == 2)
        return 59;
    else
        return  53;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[cell setBackgroundColor:[UIColor clearColor]];
}

// PER RIMUOVERE LE RIGHE DALLA TABELLA
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 2)
        return YES;
    else
        return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 2)
    {
        NSUInteger row = [indexPath row];
        NSUInteger count = [preferitiArr count];
        
        if (row < count)
            return UITableViewCellEditingStyleDelete;
        else
            return UITableViewCellEditingStyleNone;
    }
    else
        return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 2)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            //remove the deleted object from your data source.
            //If your data source is an NSMutableArray, do this
            
            NSString* cittaToRemove = ((Favorites*)[preferitiArr objectAtIndex:indexPath.row]).citta;
            
            BOOL deleted = [favDAO deleteFavorites:cittaToRemove];
            
            if(deleted == YES)
            {
                [preferitiArr removeObjectAtIndex:indexPath.row];
                [preferitiTableView reloadData]; // tell table to refresh now
                
                if(preferitiArr == nil || [preferitiArr count] == 0)
                    _btnMostraPreferiti.hidden = YES;
                
                [[[UIAlertView alloc] initWithTitle:@"Info" message:@"Preferito rimosso" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Attenzione!" message:@"Impossibile rimuove il preferito" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 2)
        [tableView reloadData];
}

-(void) readCitta
{
    NSString* filePath = @"localita";
    NSString* fileRoot = [[NSBundle mainBundle]
                          pathForResource:filePath ofType:@"txt"];
    
    // read everything from text
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileRoot
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    for (int i=0; i<[allLinedStrings count]; i++)
    {
        NSString* currentPointString = [allLinedStrings objectAtIndex:i];
        // choose whatever input identity you have decided. in this case ;
        NSArray* singleStrs = [currentPointString componentsSeparatedByString:@","];
        
        [citta addObject:[singleStrs objectAtIndex:2]];
        [cittaURL addObject:[singleStrs objectAtIndex:1]];
        
        // aggiungere ad hashmap
        [citta_urlConn setObject:[singleStrs objectAtIndex:1] forKey:[singleStrs objectAtIndex:2]];
    }
}

-(IBAction)aggiungiPreferiti:(id)sender
{
    // TODO
    BOOL inserted = [favDAO insertFavorites:_txtCitta.text withUrl:[citta_urlConn objectForKey:_txtCitta.text]];
    
    if(inserted == NO)
    {
        [[[UIAlertView alloc] initWithTitle:@"Attenzione!" message:@"Non è stato aggiunto il preferito alla lista" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        preferitiArr = [self leggiPreferiti];
        if(preferitiArr != nil && [preferitiArr count] > 0)
        {
            [preferitiTableView reloadData];
        }
        
        
        [[[UIAlertView alloc] initWithTitle:@"Info" message:@"Preferito aggiunto" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(IBAction)mostraPreferiti:(id)sender
{
    if(preferitiTableView.frame.size.height == 0)
    {
        [UIView animateWithDuration:0.8f
                     animations:^{
                         preferitiTableView.frame = CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height - 105);
                     } completion:^(BOOL finished) {
                         
                     }];
    }
    else
    {
        [UIView animateWithDuration:0.8f
                         animations:^{
                             preferitiTableView.frame = CGRectMake(0, 105, self.view.frame.size.width, 0);
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

-(NSMutableArray*) leggiPreferiti
{
    NSMutableArray* preferiti = [favDAO getFavorites:nil];
    
    if(preferiti != nil)
    {
        for(int i=0;i<[preferiti count];i++)
        {
            Favorites* fav = (Favorites*) [preferiti objectAtIndex:i];
            
            NSLog(@"%@ %@", fav.citta, fav.citta_url);
        }
    }
    else
        NSLog(@"[AM-Meteo] - nessun preferito salvato");
    
    return preferiti;
}

-(IBAction)cerca:(id)sender
{
    if(_txtCitta.text == nil || [_txtCitta.text isEqualToString:@""] == YES)
    {
        @try {
            UITableViewCell *selectedCell = [autocompleteTableView cellForRowAtIndexPath:0];
            if(selectedCell != nil)
            {
                _txtCitta.text = selectedCell.textLabel.text;
                _lblCitta.text = selectedCell.textLabel.text;
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Attenzione!" message:@"Nessuna città selezionata" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
        }
        @catch (NSException *exception) {
            [[[UIAlertView alloc] initWithTitle:@"Attenzione!" message:@"Nessuna città selezionata" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        
    }
    
    NSString* urlConn = [citta_urlConn objectForKey:_txtCitta.text];
    
    NSLog(@"CONNECTION TO %@", urlConn);
    
    [_spinner showMonkeyForView:self.view animated:YES];
    
    [_conn meteoFor:urlConn];
}

-(IBAction)goBack:(id)sender
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         _viewCerca.frame = CGRectMake(_viewCerca.frame.origin.x, _viewCerca.frame.origin.y, _viewCerca.frame.size.width, _viewCerca.frame.size.height - 20);
                         
                         preferitiTableView.hidden = NO;
                         _btnMostraPreferiti.hidden = NO;
                         
                         _lblUltimoAggiornamento.hidden = YES;
                         _meteoTable.hidden = YES;
                         autocompleteTableView.hidden = YES;
                         _btnBack.hidden = YES;
                         if(preferitiArr != nil && [preferitiArr count] > 0)
                             _btnAggiungiPreferiti.hidden = YES;
                         
                         _txtCitta.hidden = NO;
                         _btnCerca.hidden = NO;
                         _lblCitta.hidden = YES;
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

/*
 Informazioni elaborate dal
 Servizio Meteorologico de
 ll’Aeronautica Militare e
 pubblicate sul sito
 www.meteoam.it
 */

#pragma mark - AMMeteo Delegate

-(void) meteoForCallback:(int)exit_status response:(NSMutableArray *)result updatedAt:(NSString *)update
{
    if(result != nil)
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             _viewCerca.frame = CGRectMake(_viewCerca.frame.origin.x, _viewCerca.frame.origin.y, _viewCerca.frame.size.width, _viewCerca.frame.size.height + 20);
                         }
                         completion:^(BOOL finished){
                             autocompleteTableView.hidden = YES;
                             preferitiTableView.hidden = YES;
                             _btnMostraPreferiti.hidden = YES;
                             _btnCerca.hidden = YES;
                             _meteoTable.hidden = NO;
                             _btnBack.hidden = NO;
                             _lblUltimoAggiornamento.hidden = NO;
                             
                             _txtCitta.hidden = YES;
                             _lblCitta.hidden = NO;
                             
                             _btnAggiungiPreferiti.hidden = NO;
                             
                             NSLog(@"RESULT SIZE %lu", (unsigned long)[result count]);
                             
                             if(result.count > 0)
                             {
                                 [result removeObjectAtIndex:0];
                                 
                                 meteoArr = result;
                                 
                                 _lblUltimoAggiornamento.text = [NSString stringWithFormat:@"Ultimo aggiornamento %@", update];
                                 
                                 [_meteoTable reloadData];
                             }
                         }];
        
    }
    [_spinner hideMonkeyForView:self.view animated:YES];
}

#pragma mark - version tracker
-(void) versionTracker
{
    [VENVersionTracker beginTrackingVersionForChannel:@"m_production"
                                       serviceBaseUrl:@"https://iphoneapptest.grupposistematica.it/m"
                                         timeInterval:1800
                                          withHandler:^(VENVersionTrackerState state, VENVersion *version) {
                                              
                                              dispatch_sync(dispatch_get_main_queue(), ^{
                                                  switch (state) {
                                                      case VENVersionTrackerStateDeprecated:
                                                      {
                                                          NSLog(@"Deprecated TRACKER STATE");
                                                          UIAlertView *info=[[UIAlertView alloc] initWithTitle:@"Update Available" message:@"A newer version of the app is available and must be installed due to an important update" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
                                                          [info show];
                                                          [version install];
                                                      }
                                                          break;
                                                          
                                                      case VENVersionTrackerStateOutdated:
                                                      {
                                                          // Offer the user the option to update
                                                          [[[UIAlertView alloc] initWithTitle:@"Update Available" message:@"A newer version of the app is available. Update Now?" completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                                                              switch (buttonIndex) {
                                                                  case 0:
                                                                      break;
                                                                  case 1:
                                                                  {
                                                                      [version install];
                                                                      break;
                                                                  }
                                                              }
                                                          } cancelButtonTitle:@"Not Now" otherButtonTitles:@"Update", nil]  show];
                                                      }
                                                          break;
                                                          
                                                      case VENVersionTrackerStateUnknown:
                                                          NSLog(@"Unknown TRACKER STATE");
                                                          break;
                                                      case VENVersionTrackerStateOK:
                                                          NSLog(@"Ok TRACKER STATE");
                                                          break;
                                                  }
                                              });
                                          }];
}

#pragma mark - Widget

/**
 *
 * PREVEDERE CONFIGURAZIONE CITTà PER WIDGET
 *
 */
-(void) configureWidget
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.sistematica.AM-Meteo"];

    NSMutableArray* favArr = [favDAO getFavorites:nil];
    
    NSMutableArray* citta = [[NSMutableArray alloc] init];
    NSMutableArray* url = [[NSMutableArray alloc] init];
    
    for(Favorites* fav in favArr)
    {
        [citta addObject:fav.citta];
        [url addObject:fav.citta_url];
    }
    
    [sharedDefaults setValue:@"Foligno" forKey:@"MyCity"];
    [sharedDefaults setValue:@"?q=ta/previsione/344/FOLIGNO" forKey:@"MyCityUrl"];
    
    [sharedDefaults setValue:citta forKey:@"CityArray"];
    [sharedDefaults setObject:url forKey:@"UrlArray"];
    
    [sharedDefaults synchronize];   // (!!) This is crucial.
}

@end
