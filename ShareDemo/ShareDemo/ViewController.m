//
//  ViewController.m
//  ShareDemo
//
//  Created by Alan on 2020/10/29.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"===============没有打断点");
    
    
   
    [self performSelector:@selector(changeColor) withObject:nil afterDelay:3];
    
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 60, 40)];
    button.backgroundColor = [UIColor yellowColor];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
}


- (void)buttonClicked
{
    NSLog(@"==============点击了按钮");
    
}



- (void)changeColor
{
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
