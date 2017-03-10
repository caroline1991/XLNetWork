//
//  ViewController.m
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/2/8.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import "ViewController.h"
#import "XLRequestTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startRequest:(id)sender {
    
    XLRequestTest * request =[[XLRequestTest alloc] init];
    request.name = @"xulin";
    request.age = @"12";
    [request startWithCompletionBlockWithSuccess:^(NSString *responseJsonString, XLResponseSuperObj *responseSupObj) {
        NSLog(@"%@",responseJsonString);
    } failure:^(NSError *error, XLResponseSuperObj *responseSupObj) {
        NSLog(@"%@",error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
