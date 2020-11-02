//
//  NavViewController.m
//  Share
//
//  Created by Alan on 2020/11/2.
//

#import "NavViewController.h"
#import "ShareViewController.h"
@interface NavViewController ()

@end

@implementation NavViewController

- (instancetype)init
{
    ShareViewController *shareViewContrller = [[ShareViewController alloc] init];
    if (self = [super initWithRootViewController:shareViewContrller]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
