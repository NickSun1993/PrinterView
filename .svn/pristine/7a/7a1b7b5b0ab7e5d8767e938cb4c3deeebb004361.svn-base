//
//  BarcodeViewController.m
//  Gprinter
//
//  Created by  Nick on 2018/2/23.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "BarcodeViewController.h"
#import "BarcodeSelectPaopaoController.h"
#import "MyBarcodeView.h"
#import "Code39.h"
#import "ZXingObjC.h"

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

@interface BarcodeViewController ()<UITextFieldDelegate,UIPopoverPresentationControllerDelegate>
{

    NSInteger _selectIndex;
    
}

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomLayout;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation BarcodeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (Device_Is_iPhoneX) {

        self.buttomLayout.constant = 34;
    }
    else
    {
        self.buttomLayout.constant = 0;
        
    }
    
    self.navigationItem.title = @"条形码";
    if (_isEditing)
    {
        
        _textField.text = _content;
        
        _selectIndex = _codeType;
        
        [self toSetSelectButtonAndTextFieldWithType:_codeType];
        
    }
    else
    {
        [_selectButton setTitle:@"EAN8" forState:UIControlStateNormal];
        _selectIndex = EAN8;
        [_textField setKeyboardType:UIKeyboardTypeNumberPad];
        _textField.placeholder = @"(8位数字)";
        
    }
    

    
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *returnTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myRerurnAction)];
    
    [self.view addGestureRecognizer:returnTap];
    
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
        //        self.view.frame =CGRectMake(0, - Keyboardrect.size.height+75, WIDTH, HEIGHT);
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selectBarcodeKindAction:(id)sender
{

    BarcodeSelectPaopaoController  *paopaoCtl = [[BarcodeSelectPaopaoController alloc]init];
    
    
     paopaoCtl.modalPresentationStyle=UIModalPresentationPopover;
    
     paopaoCtl.preferredContentSize=CGSizeMake(120, 280);

     paopaoCtl.popoverPresentationController.permittedArrowDirections=  UIPopoverArrowDirectionDown;
    
    paopaoCtl.popoverPresentationController.sourceRect=_selectButton.bounds;
    
    
    //设置orange的位置是基于green的button的
    paopaoCtl.popoverPresentationController.sourceView=_selectButton;
    
    //    adjustCtl.source
    
    paopaoCtl.popoverPresentationController.delegate = self;
    
    paopaoCtl.cb = ^(NSInteger index) {
        
        _selectIndex = index;
        _textField.text = @"";
        
        [self toSetSelectButtonAndTextFieldWithType:index];
        
        [self myRerurnAction];
     
 
    };
    
    [self presentViewController:paopaoCtl animated:YES completion:nil];

}

-(void)toSetSelectButtonAndTextFieldWithType:(NSInteger)index
{
    switch (index)
    {
        
    case EAN8:
        {
            
            [_selectButton setTitle:@"EAN8" forState:UIControlStateNormal];
            [_textField setKeyboardType:UIKeyboardTypeNumberPad];
            _textField.placeholder = @"(8位数字)";
            
            
        }
        break;
    case EAN13:
        {
            
            [_selectButton setTitle:@"EAN13" forState:UIControlStateNormal];
            [_textField setKeyboardType:UIKeyboardTypeNumberPad];
            _textField.placeholder = @"(13位数字)";
            
            
        }
        break;
    case UPCA:
        {
            
            [_selectButton setTitle:@"UPCA" forState:UIControlStateNormal];
            [_textField setKeyboardType:UIKeyboardTypeNumberPad];
            _textField.placeholder = @"(11位数字)";
            
            
        }
        break;
    case ITF:
        {
            [_selectButton setTitle:@"ITF" forState:UIControlStateNormal];
            [_textField setKeyboardType:UIKeyboardTypeNumberPad];
            _textField.placeholder = @"";
        }
        break;
        
    case CODE39:
        {
            [_selectButton setTitle:@"CODE39" forState:UIControlStateNormal];
            [_textField setKeyboardType:UIKeyboardTypeNumberPad];
            _textField.placeholder = @"";
        }
        break;
        
    default:
        [_selectButton setTitle:@"CODE128" forState:UIControlStateNormal];
        [_textField setKeyboardType:UIKeyboardTypeDefault];
        _textField.placeholder = @"";
        
        break;
    }
}

- (IBAction)confirmAction:(id)sender
{
    

    switch (_selectIndex) {
        case EAN8:
        {

            if (_textField.text.length == 8)
            {
              
     
                MyBarcodeView *tempBarcodeView  = [[MyBarcodeView alloc]init];
               
                BOOL isPass = YES;
                
                @try {

                    [tempBarcodeView toSetMyBarcodeViewWith:_selectIndex andTittle:_textField.text];


                }
                @catch (NSException *exception)
                {

                    NSLog(@"Nick's Exception =%@",exception);
                   
                    isPass = NO;

                }
                @finally
                {

                    NSLog(@"End");
                    
                    if (isPass)
                    {
                    
                        NSMutableDictionary  *newDic = [[NSMutableDictionary alloc]init];
                        
                        [newDic setValue:@(_selectIndex) forKey:@"Type"];
                        
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
                
                NSLog(@"长度不够！");
                
            }
        
        }
            break;
        case EAN13:
        {

            if (_textField.text.length == 13) {
                
                // 生成条形码的image
                
                MyBarcodeView *tempBarcodeView  = [[MyBarcodeView alloc]init];
                
                BOOL isPass = YES;
                
                @try {
                    
                    [tempBarcodeView toSetMyBarcodeViewWith:_selectIndex andTittle:_textField.text];
                    
                    
                } @catch (NSException *exception) {
                    
                    NSLog(@"Nick's Exception =%@",exception);
                    
                    isPass = NO;
                    
                } @finally {
                    
                    NSLog(@"End");
                    
                    if (isPass)
                    {
                        
                        NSMutableDictionary  *newDic = [[NSMutableDictionary alloc]init];
                        
                        [newDic setValue:@(_selectIndex) forKey:@"Type"];
                        
                        [newDic setValue:_textField.text forKey:@"Content"];
                        
                        if (_cb) {
                            
                            _cb(newDic);
                        }
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                    else
                    {
                        
                        [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:[NSString stringWithFormat:@"%@为一个无效的EAN13码,无法正确识别!",_textField.text] andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                        
                    }
                    
                };
                
            }
            else
            {
                
                NSLog(@"长度不够！");
                
            }
        }
            break;
        case UPCA:
        {

            if (_textField.text.length == 11) {
                
                // 生成条形码的image
                
                MyBarcodeView *tempBarcodeView  = [[MyBarcodeView alloc]init];
                
                BOOL isPass = YES;
                
                @try {
                    
                    [tempBarcodeView toSetMyBarcodeViewWith:_selectIndex andTittle:_textField.text];
                    
                    
                } @catch (NSException *exception) {
                    
                    NSLog(@"Nick's Exception =%@",exception);
                    
                    isPass = NO;
                    
                } @finally {
                    
                    NSLog(@"End");
                    
                    if (isPass)
                    {
                        
                        NSMutableDictionary  *newDic = [[NSMutableDictionary alloc]init];
                        
                        [newDic setValue:@(_selectIndex) forKey:@"Type"];
                        
                        [newDic setValue:_textField.text forKey:@"Content"];
                        
                        if (_cb) {
                            
                            _cb(newDic);
                        }
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                    else
                    {
                        
                        [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:[NSString stringWithFormat:@"%@为一个无效的UPCA码,无法正确识别!",_textField.text] andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                        
                    }
                    
                };
            }
            else
            {

                NSLog(@"长度不够！");
                
            }
            
        }
            break;
        case ITF:
        {
            
            // 生成条形码的image
            
            MyBarcodeView *tempBarcodeView  = [[MyBarcodeView alloc]init];
            
            BOOL isPass = YES;
            
            @try {
                
                [tempBarcodeView toSetMyBarcodeViewWith:_selectIndex andTittle:_textField.text];
                
                
            } @catch (NSException *exception) {
                
                NSLog(@"Nick's Exception =%@",exception);
                
                isPass = NO;
                
            } @finally {
                
                NSLog(@"End");
                
                if (isPass)
                {
                    
                    NSMutableDictionary  *newDic = [[NSMutableDictionary alloc]init];
                    
                    [newDic setValue:@(_selectIndex) forKey:@"Type"];
                    
                    [newDic setValue:_textField.text forKey:@"Content"];
                    
                    if (_cb) {
                        
                        _cb(newDic);
                    }
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else
                {
                    
                    [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:[NSString stringWithFormat:@"%@为一个无效的ITF码,无法正确识别!",_textField.text] andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                    
                }
                
            };
        }
            break;
        case CODE39:
        {
            
            // 生成条形码的image
            
            MyBarcodeView *tempBarcodeView  = [[MyBarcodeView alloc]init];
            
            BOOL isPass = YES;
            
            @try {
                
                [tempBarcodeView toSetMyBarcodeViewWith:_selectIndex andTittle:_textField.text];
                
                
            } @catch (NSException *exception) {
                
                NSLog(@"Nick's Exception =%@",exception);
                
                isPass = NO;
                
            } @finally {
                
                NSLog(@"End");
                
                if (isPass)
                {
                    
                    NSMutableDictionary  *newDic = [[NSMutableDictionary alloc]init];
                    
                    [newDic setValue:@(_selectIndex) forKey:@"Type"];
                    
                    [newDic setValue:_textField.text forKey:@"Content"];
                    
                    if (_cb) {
                        
                        _cb(newDic);
                    }
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else
                {
                    
                    [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:[NSString stringWithFormat:@"%@为一个无效的CODE39码,无法正确识别!",_textField.text] andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                    
                }
                
            };
        }
            break;
        default:
        {
            
            // 生成条形码的image
            
            MyBarcodeView *tempBarcodeView  = [[MyBarcodeView alloc]init];
            
            BOOL isPass = YES;
            
            @try
            {
                
             [tempBarcodeView toSetMyBarcodeViewWith:_selectIndex andTittle:_textField.text];
                
            } @catch (NSException *exception) {
                
                NSLog(@"Nick's Exception =%@",exception);
                
                isPass = NO;
                
            } @finally {
                
                NSLog(@"End");
                
                if (isPass)
                {
                    
                    NSMutableDictionary  *newDic = [[NSMutableDictionary alloc]init];
                    
                    [newDic setValue:@(_selectIndex) forKey:@"Type"];
                    
                    [newDic setValue:_textField.text forKey:@"Content"];
                    
                    if (_cb) {
                        
                        _cb(newDic);
                    }
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else
                {
                    
                    [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:[NSString stringWithFormat:@"%@为一个无效的CODE128码,无法正确识别!",_textField.text] andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                    
                }
                
            };
        }
            break;
    }
    
    
    
}


-(CIImage *)generateBarCodeImage:(NSString *)source
{
    // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下使用第三方控件生成
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        // 注意生成条形码的编码方式
        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        // 设置生成的条形码的上，下，左，右的margins的值
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;

    }else{
        return nil;
    }
}

-(UIImage *) resizeCodeImage:(CIImage *)image withSize:(CGSize)size
{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        CGContextRelease(contentRef);
        CGImageRelease(imageRef);
        CGColorSpaceRelease(colorSpaceRef);
        UIImage * img = [UIImage imageWithCGImage:imageRefResized];
        CGImageRelease(imageRefResized);
        return img;
    }else{
        return nil;
    }
}




-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;//不适配(不区分ipad或iPhone)
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    switch (_selectIndex)
    {
        case EAN8:
        {
            BOOL isLength = YES;
            NSInteger existedLength = textField.text.length;
            NSInteger selectedLength = range.length;
            NSInteger replaceLength = string.length;
            if (existedLength - selectedLength + replaceLength > 8)
            {
                isLength =NO;
                
            }
        
            return [self CanEditWithStr:string]&&isLength;
            
        }
            break;
        case EAN13:
        {
            BOOL isLength = YES;
            NSInteger existedLength = textField.text.length;
            NSInteger selectedLength = range.length;
            NSInteger replaceLength = string.length;
            if (existedLength - selectedLength + replaceLength > 13)
            {
                isLength =NO;
                
            }
            
            return [self CanEditWithStr:string]&&isLength;
            
        }
            break;
        case UPCA:
        {
            BOOL isLength = YES;
            NSInteger existedLength = textField.text.length;
            NSInteger selectedLength = range.length;
            NSInteger replaceLength = string.length;
            if (existedLength - selectedLength + replaceLength > 11)
            {
                isLength =NO;
                
            }
            
            
            return [self CanEditWithStr:string]&&isLength;
        }
            break;
        case ITF:
        {
            
            return [self CanEditWithStr:string];
        }
            break;
        case CODE39:
        {
            
            return [self CanEditWithStr:string];
        }
            break;
            
        default:
        {
            
            return [self CanEditWithStr2:string];
            
        }
            break;
    }
    
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
-(BOOL)CanEditWithStr:(NSString *)str
{
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
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
    
    if ([str isEqualToString:@""])
    {
    
        res = YES;
    }
    
    return res;
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
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
