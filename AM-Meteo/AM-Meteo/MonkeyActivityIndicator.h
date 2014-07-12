//
//  MonkeyActivityIndicator.h
//  eMobile-Tester
//
//  Created by Fabrizio Loreti on 30/01/14.
//  Copyright (c) 2014 fabrizio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MonkeyActivityIndicator : NSObject

@property(nonatomic) int imageW;
@property(nonatomic) int imageH;

@property(nonatomic) int logoW;
@property(nonatomic) int logoH;

@property(nonatomic) int discW;
@property(nonatomic) int discH;

// my activity indicator
@property(nonatomic, retain) UIView* customActivityIndicatorView;
@property(nonatomic, retain) UIImageView* customActivityIndicator;

@property(nonatomic, retain) UIImageView* logoIndicator;

-(id) initMonkeyActivityIndicatorForView:(UIView*) view;
-(id) initMonkeyActivityIndicatorForView:(UIView *)view withDivider: (int) divider;
-(void) showMonkeyForView:(UIView*) view animated:(BOOL) animated;
-(void) hideMonkeyForView:(UIView*) view animated:(BOOL) animated;

@end
