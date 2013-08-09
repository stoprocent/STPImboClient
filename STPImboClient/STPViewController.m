//
//  STPViewController.m
//  STPImboClient
//
//  Created by Marek Serafin on 8/8/13.
//  Copyright (c) 2013 Schibsted Tech Polska. All rights reserved.
//

#import "STPViewController.h"
#import "STPImbo.h"

@interface STPViewController ()

@end

@implementation STPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Imbo stuff
    [[STPImbo client] setPublicKey:@"PUBLIC_KEY"];
    [[STPImbo client] setPrivateKey:@"PRIVATE_KEY"];
    [[STPImbo client] setServersList:@[@"http://server01",
                                       @"http://server02",
                                       @"http://server03",
                                       @"http://server04"]];
    
    [[[STPImbo client] imageWithID:@"IMAGE_ID"] ]
    NSURL *url = [[[[[[[[STPImbo client] imageWithID:@"IMAGE_ID"] resize:CGSizeMake(2000, 0)] crop:CGRectMake(120,12,640, 960)] compress:100] desaturate] jpg] url];

    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
