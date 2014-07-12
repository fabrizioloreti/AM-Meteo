//
//  MonkeyActivityIndicator.m
//  eMobile-Tester
//
//  Created by Fabrizio Loreti on 30/01/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import "MonkeyActivityIndicator.h"

static int direction = 0;
static float oriX;

static float startY = 75;

@implementation MonkeyActivityIndicator

-(id) initMonkeyActivityIndicatorForView:(UIView *)view
{
    _imageW = 50;
    _imageH = 50;
    
    _logoW = 100;
    _logoH = 150;
    
    _discW = 250;
    _discH = 150;
    
    // SPINNER
    
    _customActivityIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width/2 - _imageW/2, startY - _imageH/2, _imageW, _imageH)];
    
    UIImage *spinImage = [UIImage imageNamed:@"spinner.png"];
    
    oriX = _customActivityIndicator.frame.origin.x;
    
    [_customActivityIndicator setImage:spinImage];
    
    // LOGO AEREONAUTICA
    _logoIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width/2 - _logoW/2, startY + _imageH/2 + 25, _logoW, _logoH)];
    
    UIImage *logoImage = [UIImage imageNamed:@"aeronautica.png"];
    
    [_logoIndicator setImage:logoImage];
    
    // DISCLAIMER
    UILabel* lblDisc = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width/2 - _discW/2, _logoIndicator.frame.origin.y + _logoIndicator.frame.size.height + 10, _discW, _discH)];
    
    lblDisc.text = @"Informazioni elaborate dal Servizio Meteorologico dell’Aeronautica Militare e pubblicate sul sito www.meteoam.it";
    
    lblDisc.numberOfLines = 0;
    lblDisc.textAlignment = NSTextAlignmentCenter;
    
    lblDisc.textColor = [UIColor whiteColor];
    
    
    UIImageView* customIndicatorBackground = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    customIndicatorBackground.image = [UIImage imageNamed:@"indicatorBG"];
    
    _customActivityIndicatorView = [[UIView alloc] init];
    _customActivityIndicatorView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    [_customActivityIndicatorView addSubview:customIndicatorBackground];
    
    [_customActivityIndicatorView addSubview:_customActivityIndicator];
    
    [_customActivityIndicatorView addSubview:_logoIndicator];
    
    [_customActivityIndicatorView addSubview:lblDisc];
    
    return self;
}

-(id) initMonkeyActivityIndicatorForView:(UIView *)view withDivider: (int) divider
{
    _imageW = 50;
    _imageH = 50;
    
    _customActivityIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width/(2*divider) - _imageW/2, view.frame.size.height/2 - _imageH/2, _imageW, _imageH)];
    
    UIImage *spinImage = [UIImage imageNamed:@"logo_octo_spinner.png"];
    
    oriX = _customActivityIndicator.frame.origin.x;
    
    [_customActivityIndicator setImage:spinImage];
    
    UIImageView* customIndicatorBackground = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width/divider, view.frame.size.height)];
    customIndicatorBackground.image = [UIImage imageNamed:@"indicatorBG"];
    
    _customActivityIndicatorView = [[UIView alloc] init];
    _customActivityIndicatorView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width/divider, view.frame.size.height);
    [_customActivityIndicatorView addSubview:customIndicatorBackground];
    
    [_customActivityIndicatorView addSubview:_customActivityIndicator];
    
    return self;
}


-(void) showMonkeyForView:(UIView *)view animated:(BOOL)animated
{
    [view addSubview:_customActivityIndicatorView];
    
    if (animated) {
        /*
        [UIView beginAnimations:@"spin logo" context:NULL];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationRepeatCount:50];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:_customActivityIndicator
                                 cache:YES];
        
        [UIView commitAnimations];
         */
        
        if(direction == 0)
            direction = -1;
        
        [self spin];
    }
}

-(void) hideMonkeyForView:(UIView *)view animated:(BOOL)animated
{
    NSLog(@"hide");
    direction = 0;
    [_customActivityIndicatorView removeFromSuperview];
}

-(void) spin
{
    float width = _imageW;
    float x = oriX;
    
    if(direction == -1)
    {
        width = 0;
        x = oriX + _imageW/2;
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         _customActivityIndicator.frame = CGRectMake(x
                                                                     , _customActivityIndicator.frame.origin.y
                                                                     , width
                                                                     , _customActivityIndicator.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if(direction != 0)
                         {
                             direction = -1*direction;
                             [self spin];
                         }
                     }
     ];
}

@end
