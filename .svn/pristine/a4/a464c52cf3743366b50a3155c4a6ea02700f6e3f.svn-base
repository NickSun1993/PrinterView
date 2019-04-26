//
//  EditTextViewController.m
//  Gprinter
//
//  Created by 孙锟 on 2018/2/21.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "EditTextViewController.h"
#import "SelectFontViewController.h"

@interface EditTextViewController ()<UITextFieldDelegate>
{
    
    BOOL _isHeavy;
    NSString *_currentString;
    NSInteger _currentFontSize;
    UILabel *_myLabel;
    
}

@property (weak, nonatomic) IBOutlet UITextField *myTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myDownviewLayout;

@property (weak, nonatomic) IBOutlet UIButton *heavyButton;

@end

@implementation EditTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NAVIGATIONBACKBUTTON;
    
    if (Device_Is_iPhoneX)
    {
        self.myDownviewLayout.constant = 34;
        _myLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, iPhoneX_Top_Height+8, 100, 35)];
        _myLabel.numberOfLines = 0;
        [self.view addSubview:_myLabel];
    }
    else
    {
        self.myDownviewLayout.constant = 0;
        _myLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, iPhone_Top_Height+8, 100, 35)];
        _myLabel.numberOfLines = 0;
        [self.view addSubview:_myLabel];
    }
    
    
    self.navigationItem.title = @"添加文字";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *returnTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myRerurnAction)];
    
    [self.view addGestureRecognizer:returnTap];
    
    [_myTextField addTarget:self action:@selector(myInputAction:) forControlEvents:UIControlEventEditingChanged];
    
    
    if (_isEdit)
    {
        
        _currentFontSize = [_editLabelInfoDic[@"fontSize"] integerValue];
        
        _currentString = _editLabelInfoDic[@"fontName"];
        
        _myLabel.text = _editLabelInfoDic[@"text"];
        
        _myTextField.text = _editLabelInfoDic[@"text"];
        
        _isHeavy = [_currentString hasSuffix:@"-Bold"];
        
        if (_isHeavy) {
            
            [_heavyButton setTitle:@"正常" forState:UIControlStateNormal];
        }
        else
        {
            [_heavyButton setTitle:@"加粗" forState:UIControlStateNormal];
            
        }
        
        
        [self setMyLabelFont];
        
    }
    else
    {
        _isHeavy = NO;
        
        _currentFontSize = 17;
        
        _currentString = @".SFUIText";
        
    }

    
    
}



//动态计算高宽

-(CGSize)getMyLabelSize:(NSString *)inputString
{
    CGSize strSize=CGSizeMake(WIDTH-16,500);
    //需跟lable字体大小一直，否则会显示不全等问题
    NSDictionary *attr = @{NSFontAttributeName:[UIFont fontWithName:_currentString size:_currentFontSize]};
    
    CGSize titleSize=[inputString boundingRectWithSize:strSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    return titleSize;
    
}
-(void)myInputAction:(UITextField *)textfield
{
    _myLabel.text = textfield.text;
    if (textfield.text.length) {
        
        _myLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _myLabel.layer.borderWidth = 1.2f;
        _myLabel.layer.cornerRadius = 2;
    }
    else
    {
        
        _myLabel.layer.borderColor = [UIColor clearColor].CGColor;
        _myLabel.layer.borderWidth = 0;
        _myLabel.layer.cornerRadius = 0;
    }
    
    CGSize myLabelSize = [self getMyLabelSize:textfield.text];
    
    if (Device_Is_iPhoneX) {
        
        _myLabel.frame = CGRectMake(8, 8+iPhoneX_Top_Height, myLabelSize.width, myLabelSize.height);
    }
    else
    {
        
        _myLabel.frame = CGRectMake(8, 8+iPhone_Top_Height, myLabelSize.width, myLabelSize.height);
    
    }

    
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

               self.myDownviewLayout.constant = Keyboardrect.size.height;
        
        
    }];
}

- (void)keyboardWillHidden:(id)sender
{
    // NSLog(@"键盘即将掉下");

    [UIView animateWithDuration:0.35 animations:^{
        
        // self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        
        if (Device_Is_iPhoneX) {
            
            self.myDownviewLayout.constant = 34;
        }
        else
        {
            self.myDownviewLayout.constant = 0;
            
        }
        
        
        
    }];
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fontButtonAction:(id)sender {
    
    SelectFontViewController *fontsCtl= [[SelectFontViewController alloc]init];
    
    fontsCtl.cb = ^(NSString *fontName) {
      
        if (_isHeavy)
        {
            _currentString = [fontName stringByAppendingString:@"-Bold"];
            
        }
        else
        {
           
            _currentString = fontName;
        }
        
        [self setMyLabelFont];
    };
    
    [self.navigationController pushViewController:fontsCtl animated:YES];
    
    
    
}


- (IBAction)fontSizeAction:(id)sender
{
    UIAlertController *AlertCtl = [UIAlertController alertControllerWithTitle:@"字体大小" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [AlertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.text = [NSString stringWithFormat:@"%zd",_currentFontSize];
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 1007;
        
        
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = [AlertCtl.textFields firstObject];
        
        _currentFontSize = [textField.text integerValue];
        
        [self setMyLabelFont];
        
        

    }];
    
    [AlertCtl addAction:confirmAction];
    
    [self presentViewController:AlertCtl animated:YES completion:nil];
    
}
- (IBAction)heavyAction:(id)sender
{
    
    _isHeavy = !_isHeavy;
    
    if (_isHeavy) {
        
        [_heavyButton setTitle:@"正常" forState:UIControlStateNormal];
    }
    else
    {
        [_heavyButton setTitle:@"加粗" forState:UIControlStateNormal];
        
    }
    
    
    _currentString = [self HeavyOrNotFontFormLabel:_currentString];
    
    [self setMyLabelFont];

}
- (IBAction)confirmAction:(id)sender
{

    if (_myTextField.text.length)
    {
        NSDictionary *labelInfo = [[NSDictionary alloc]initWithObjects:@[_myTextField.text,_currentString,@(_currentFontSize)] forKeys:@[@"text",@"fontName",@"fontSize"]];
        
        NSLog(@"Label Info = %@",labelInfo);
        
        if (_cb) {
            
            _cb(labelInfo);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
    
        _myTextField.placeholder = @"输入为空！";
    
    }
    
 
    
}

-(void)setMyLabelFont
{
    

//    _currentString = [self HeavyOrNotFontFormLabel:]
    
    _myLabel.font = [UIFont fontWithName:_currentString size:_currentFontSize];
    
    CGSize myLabelSize = [self getMyLabelSize:_myTextField.text];
    
    if (Device_Is_iPhoneX)
    {
        _myLabel.frame = CGRectMake(8, 8+iPhoneX_Top_Height, myLabelSize.width, myLabelSize.height);
    
    }
    else
    {
        _myLabel.frame = CGRectMake(8, 8+iPhone_Top_Height, myLabelSize.width, myLabelSize.height);
        
    }
    
    
    
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag == 1007)
    {
        
        return [self CanEditWithStr:string];
        
    }
    return YES;
    
}
-(BOOL)CanEditWithStr:(NSString *)str
{
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    int i = 0;
    while (i < str.length) {
        NSString * string = [str substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0)
        {
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


- (NSString *)HeavyOrNotFontFormLabel:(NSString *)inputFontName
{
    
    NSString *fontname = inputFontName;
    
    
    NSLog(@"%@",fontname);
    
    // 判断现有字体  以 -Bold 结尾（已经加粗字体）
    if ([fontname hasSuffix:@"-Bold"])
    {
        
        // 去掉加粗
        fontname = [fontname stringByReplacingOccurrencesOfString:@"-Bold" withString:@""];
        NSLog(@"去掉加粗字体成功 %@",fontname);
    }
    else
    {
        // 加粗
        
        fontname = [fontname stringByAppendingString:@"-Bold"];
        
        
        NSLog(@"加粗字体成功 %@",fontname);
        
    }
    
    return fontname;

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
