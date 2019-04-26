//
//  PDF418ViewController.m
//  Gprinter
//
//  Created by 孙锟 on 2018/3/1.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "PDF418ViewController.h"
#import "MyBarcodeView.h"
typedef enum
{
    
    EAN8,
    EAN13,
    UPCA,
    ITF,
    CODE39,
    CODE128,
    QRCode,
    PDF417
    
}
EnumModelType;

@interface PDF418ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomLayout;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation PDF418ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *returnTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myRerurnAction)];
    
    [self.view addGestureRecognizer:returnTap];
    
    self.navigationItem.title = @"PDF417";
    
    if (_isEditing)
    {
    
    _textField.text = _content;
    
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)myRerurnAction
{
    [self.view endEditing:YES];
    
}

#pragma mark - KeyBoard
- (void)keyboardWillShow:(NSNotification *)sender
{
    
    //获取键盘高度
    CGRect Keyboardrect = [[sender userInfo][@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        //self.view.frame =CGRectMake(0, - Keyboardrect.size.height+75, WIDTH, HEIGHT);
        
        self.buttomLayout.constant = Keyboardrect.size.height;
        
    }];
}

- (void)keyboardWillHidden:(id)sender
{
    // NSLog(@"键盘即将掉下");
    
    [UIView animateWithDuration:0.35 animations:^{
        
        //        self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        
        if (Device_Is_iPhoneX) {
            
            self.buttomLayout.constant = 34;
        }
        else
        {
            self.buttomLayout.constant = 0;
            
        }
        
        
        
    }];
}

- (IBAction)confirmAction:(id)sender {
    
    if (_textField.text.length)
    {
        
        
        MyBarcodeView *tempBarcodeView  = [[MyBarcodeView alloc]init];
        
        BOOL isPass = YES;
        
        @try
        {
            [tempBarcodeView toSetMyBarcodeViewWith:PDF417 andTittle:_textField.text];
            
            
        } @catch (NSException *exception) {
            
            NSLog(@"Nick's Exception =%@",exception);
            
            isPass = NO;
            
        } @finally {
            
            NSLog(@"End");
            
            if (isPass)
            {
                
                NSMutableDictionary  *newDic = [[NSMutableDictionary alloc]init];
                
                [newDic setValue:@(PDF417) forKey:@"Type"];
                
                [newDic setValue:_textField.text forKey:@"Content"];
                
                if (_cb) {
                    
                    _cb(newDic);
                }
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else
            {
                
                [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:[NSString stringWithFormat:@"%@为一个无效的EAN8码,无法正确识别!",_textField.text] andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                
            }
            
        };
        
        
        
    }
    else
    {
        
        NSLog(@"No data");
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return [self CanEditWithStr2:string];
    
}
-(BOOL)CanEditWithStr2:(NSString *)str
{
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890QWERTYUIOPLKJHGFDSAZXCVBNMqwertyuioplkjhgfdsazxcvbnm"];
    int i = 0;
    while (i < str.length) {
        NSString * string = [str substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    if ([str isEqualToString:@""]) {
        res = YES;
    }
    
    return res;
}

-(void)dealloc
{

    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
