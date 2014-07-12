//
//  ViewController.h
//  AM-Meteo
//
//  Created by Fabrizio Loreti on 21/06/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connection.h"
#import "MonkeyActivityIndicator.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AMMeteoConnDelegate>

@property (nonatomic, strong) IBOutlet UITextField* txtCitta;
@property (nonatomic, strong) IBOutlet UILabel* lblCitta;
@property (nonatomic, strong) IBOutlet UIButton* btnCerca;
@property (nonatomic, strong) IBOutlet UIButton* btnAggiungiPreferiti;
@property (nonatomic, strong) IBOutlet UIButton* btnMostraPreferiti;
@property (nonatomic, strong) IBOutlet UIButton* btnBack;

@property (nonatomic, strong) IBOutlet UIView* viewCerca;

@property (nonatomic, strong) IBOutlet UILabel* lblUltimoAggiornamento;

@property (nonatomic, strong) IBOutlet UITableView* meteoTable;

@property (nonatomic, strong) IBOutlet UIImageView* imgSatellite;

@property (nonatomic, strong) Connection* conn;
@property (nonatomic, strong) MonkeyActivityIndicator* spinner;

-(IBAction)cerca:(id)sender;

-(IBAction)aggiungiPreferiti:(id)sender;
-(IBAction)mostraPreferiti:(id)sender;

-(IBAction)goBack:(id)sender;

@end
