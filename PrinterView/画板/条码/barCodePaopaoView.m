//
//  barCodePaopaoView.m
//  PrinterView
//
//  Created by  Nick on 2018/10/19.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import "barCodePaopaoView.h"

@interface barCodePaopaoView ()

@end

@implementation barCodePaopaoView

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)barcodeAction:(id)sender {
    
    if (_cb)
    {
        _cb(1);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)qrcodeAction:(id)sender {
    
    if (_cb)
    {
        _cb(2);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)pdf417Action:(id)sender
{
    
    if (_cb)
    {
        _cb(3);
    }
 
     [self dismissViewControllerAnimated:YES completion:nil];

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
