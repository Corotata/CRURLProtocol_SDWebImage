//
//  ViewController.m
//  CRURLProtocol_SDWebImage
//
//  Created by Corotata on 16/12/17.
//  Copyright © 2016年 Corotata. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.taobao.com"]]];
}




@end
