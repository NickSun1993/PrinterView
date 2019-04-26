//
//  PrinterViewController.m
//  PrinterView
//
//  Created by  Nick on 2018/10/18.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import "PrinterViewController.h"
#import "WQCodeScanner.h"
#import "ZXingObjC.h"
#import "MyBarcodeView.h"
#import "PDF418ViewController.h"
#import "BarcodeViewController.h"
#import "QRCodeViewController.h"
#import "myLineView.h"
#import "myCircleView.h"
#import "myRectangleView.h"
#import "myOvalView.h"
#import "MyQRCodeView.h"
#import "EditTextViewController.h"
#import "barCodePaopaoView.h"
#import "shapePaopaoView.h"
#import "FormBoardViewController.h"
#import "WQCodeScanner.h"
#import "PreviewViewController.h"
#import "BlueToothListViewController.h"
#import "WWTBlueToothModule.h"
#import "GPPrintModule.h"

#define Remaing 10086

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

@interface PrinterViewController ()<UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    UIView *_currentEditView;

    BOOL _isScaleViewHidden;
    
}

@property (weak, nonatomic) IBOutlet UIView *myDowmView;

//画板所在的滑动区域
@property (weak, nonatomic) IBOutlet UIScrollView *myPrinterViewScrollView;

//当前
@property(nonatomic,strong)NSMutableDictionary *MyPrinterViewCurrentDic;

//存储当前画板上元素的数组
@property(nonatomic,strong)NSMutableArray *MyPrinterUnitArr;

//画板View
@property(nonatomic,strong)UIView *myPrinterView;

@property (weak, nonatomic) IBOutlet UIView *scaleView;

@property(nonatomic,strong)NSMutableArray *serviceArray;

@property (strong, nonatomic)   CBCharacteristic            *chatacter;  /**< 可写入数据的特性 */

@end

@implementation PrinterViewController

#pragma Mark - 懒加载
-(NSMutableArray *)MyPrinterUnitArr
{
    
    if (!_MyPrinterUnitArr) {
        
        _MyPrinterUnitArr = [[NSMutableArray alloc]init];
    }
    
    return _MyPrinterUnitArr;
}

-(UIView *)myPrinterView
{
    if (!_myPrinterView)
    {
        _myPrinterView = [[UIView alloc]init];
        _myPrinterView.clipsToBounds = YES;
        _myPrinterView.backgroundColor = [UIColor whiteColor];
    
    }
    
    return _myPrinterView;
    
}
-(NSMutableArray *)serviceArray
{
    
    if (!_serviceArray) {
        
        _serviceArray = [[NSMutableArray alloc]init];
    }
    
    return _serviceArray;
    
}

-(NSMutableDictionary *)MyPrinterViewCurrentDic
{
    
    if (!_MyPrinterViewCurrentDic) {
        
        _MyPrinterViewCurrentDic = [[NSMutableDictionary alloc]init];
        
    }
    
    return _MyPrinterViewCurrentDic;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    [self aboutUI];
    
    [self reSetMyPrinterSize];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark About UI
-(void)aboutUI
{
    self.navigationItem.title = @"画板";

    NAVIGATIONBACKBUTTON;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"连接打印机" style:UIBarButtonItemStylePlain target:self action:@selector(connectToThePrinterAction)];
    
    UIBarButtonItem *left01 = [[UIBarButtonItem alloc]initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(previewLabel)];
    
    UIBarButtonItem *left02 = [[UIBarButtonItem alloc]initWithTitle:@"打印" style:UIBarButtonItemStylePlain target:self action:@selector(printerAction)];
    
    self.navigationItem.leftBarButtonItems = @[left01,left02];

    _isScaleViewHidden = YES;

    _myDowmView.layer.borderWidth = 1;
    
    _myDowmView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.myPrinterViewScrollView.contentSize = CGSizeMake(WIDTH, self.myPrinterViewScrollView.frame.size.height);
    
    self.myPrinterViewScrollView.canCancelContentTouches=NO;
    
    self.MyPrinterViewCurrentDic = [SettingsSETObj GetSettingsDictionaryWithName:@"MyPrinterViewPList"];
    
    NSLog(@"View didLoad = %@",self.MyPrinterViewCurrentDic);
    
    self.myPrinterViewScrollView.contentSize = CGSizeMake(WIDTH, self.myPrinterViewScrollView.frame.size.height);
    
    [self.MyPrinterUnitArr addObjectsFromArray:self.MyPrinterViewCurrentDic[@"Unit"]];
    
    if (self.MyPrinterUnitArr.count )
    {
        
        NSLog(@"现场恢复ing");
        
        [self toRecoverBeforePrinterViewWithArray:self.MyPrinterUnitArr];
        
    }
    
}

-(void)printerAction
{
    NSLog(@"start ~");
    
    NSLog(@"before chatacter =%@",self.chatacter);
    
    WWTBlueToothModule * BLE = [WWTBlueToothModule ShareInstance];
    
    for (CBService *service in self.serviceArray )
    {
        
        for (CBCharacteristic *character in service.characteristics) {
            
            CBCharacteristicProperties properties = character.properties;
            
            if (properties & CBCharacteristicPropertyWrite)
            {
                //        if (self.chatacter == nil) {
                //            self.chatacter = character;
                //        }
                self.chatacter = character;
            }
            
        }
        
    }
    
    NSLog(@"after chatacter =%@",self.chatacter);
    

    UIImage *printerImage = [self PreViewMakeImageWithMyPrinterView];
    
    NSLog(@"image = %@",printerImage);
    
    //打印机可
    [printerImage bitmapDataWithWidth:320 Height:400 BitmapDataBlock:^(NSData *bitmapData, NSInteger xL, NSInteger xH, NSInteger yL, NSInteger yH) {
        
        
           [BLE WriteValue:[GPPrintModule GetPrintDataFromBitmapData:bitmapData xL:xL xH:xH yL:yL yH:yH] forCharacteristic:self.chatacter andType:CBCharacteristicWriteWithResponse];
        
        
    }];
    
//    [BLE GetConnectStatusBlock:^(WWTConnectStatus BTEConnectionStauts) {
//
//        if (BTEConnectionStauts)
//        {
//        }
//        else
//        {
//            [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"您还未连接到打印机！" andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
//
//        }
//
//    }];
    
}

-(NSMutableData *)testData
{
    NSMutableData * outPutData = [[NSMutableData alloc]init];
    NSString *RN = @"\r\n";
    NSString * SIZE = @"SIZE 40mm,50mm";
    NSString * GAP = @"GAP 0,0";
    NSString * BITMAP = @"BITMAP 0,0,40,393,0,";
//  NSString *Context = @"TEXT 10,20,\"2\",0,1,1,\"Nick's Test ! ! !\"";
//  NSString *TimeContext= @"TEXT 10,45,\"2\",0,1,1,\"2018-10-29\"";
//  NSString *BarCode = @"BARCODE 10,10,”39”,48,1,0,2,2,”ABCDEFGH”";
    NSString * CLS = @"CLS";
    NSString * PRINT = @"PRINT 1,1";
//  UIImage *printerImage = [self PreViewMakeImageWithMyPrinterView];
//  打印机可
//  NSData *printerImageBitmapData =[printerImage bitmapDataWithWidth:printerImage.size.width Height:printerImage.size.height];
    [outPutData appendData:[self get16DataWithString:CLS]];
    [outPutData appendData:[self get16DataWithString:RN]];
    [outPutData appendData:[self get16DataWithString:SIZE]];
    [outPutData appendData:[self get16DataWithString:RN]];
//  [outPutData appendData:[self get16DataWithString:Context]];
//  [outPutData appendData:[self get16DataWithString:RN]];
//  [outPutData appendData:[self get16DataWithString:TimeContext]];
//  [outPutData appendData:[self get16DataWithString:RN]];
    [outPutData appendData:[self get16DataWithString:BITMAP]];
//  [outPutData appendData:printerImageBitmapData];
    [outPutData appendData:[self get16DataWithString:RN]];
    [outPutData appendData:[self get16DataWithString:GAP]];
    [outPutData appendData:[self get16DataWithString:RN]];
    [outPutData appendData:[self get16DataWithString:PRINT]];
    [outPutData appendData:[self get16DataWithString:RN]];
    return outPutData;
    
}


-(NSData *)get16DataWithString:(NSString *)text
{
    //    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //    NSData *data = [text dataUsingEncoding:enc];
 
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
    
}


-(void)connectToThePrinterAction
{
    
    NSLog(@"connect to the printer action");
    
    BlueToothListViewController *bluetoothCtl = [[BlueToothListViewController alloc]init];


    bluetoothCtl.cb = ^(NSMutableArray *servicesArray)
    {
        NSLog(@"Connect Success");
        NSLog(@"servicesArray = %@",servicesArray);
        [self.serviceArray removeAllObjects];
        [self.serviceArray addObjectsFromArray:servicesArray];
        [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"成功连接到打印机" andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
        
    };
    
    [self.navigationController pushViewController:bluetoothCtl animated:YES];
    
}

-(void)previewLabel
{
    PreviewViewController *previewCtl = [[PreviewViewController alloc]init];
    [self.navigationController pushViewController:previewCtl animated:YES];
}

-(void)createPrinterImage
{
    if (self.myPrinterView.subviews.count)
    {
      
        UIImage *savedimage =  [self PreViewMakeImageWithMyPrinterView];
        NSLog(@"width = %f height = %f",savedimage.size.width,savedimage.size.height);
        UIImageWriteToSavedPhotosAlbum(savedimage, self, @selector(image:didFinishSaveingWithError:contextInfo:), nil);
    }
    else
    {
        [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"您还没有在画板上添加任何内容！" andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
    }

}

#pragma mark 调整标签尺寸
- (IBAction)adjustPrinterLabelSize:(id)sender
{
 
    NSLog(@"点击可以调整标签尺寸 o ！！");
    
}

//pragma Mark - 复原上次编辑的内容，重置画板，获取画板图片
//App进入后台时保存/退出画板编辑界面，保存当前画板的内容
-(void)saveChangesToPlistWhenAppToBacgroundOrEndEditing
{
    NSLog(@"ChangesToPlist");
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [path objectAtIndex:0];
    
    NSString *MyPrinterViewPath = [documentsPath stringByAppendingPathComponent:@"MyPrinterViewPList.plist"];
    
    NSMutableDictionary *MyPrinterViewCurrentDic = [[NSMutableDictionary alloc]init];

    [MyPrinterViewCurrentDic setObject:@"TSC" forKey:@"Type"];

    [MyPrinterViewCurrentDic setObject:[self ReturnCurrentUnitArray] forKey:@"Unit"];
    
    [MyPrinterViewCurrentDic writeToFile:MyPrinterViewPath atomically:YES];
    
    [self.MyPrinterViewCurrentDic removeAllObjects];
    
    [self.MyPrinterUnitArr removeAllObjects];
    
    [self.MyPrinterUnitArr addObjectsFromArray:[self ReturnCurrentUnitArray]];

    [self.MyPrinterViewCurrentDic addEntriesFromDictionary:MyPrinterViewCurrentDic];

}

//重置画板，清屏，删除当前画板所有内容
-(void)toResetMyCurrentPlist
{
    for (UIView *subViews in self.myPrinterView.subviews)
    {
        
        [subViews removeFromSuperview];
    }

    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [path objectAtIndex:0];
    
    NSString *MyPrinterViewPath = [documentsPath stringByAppendingPathComponent:@"MyPrinterViewPList.plist"];
    
    NSMutableDictionary *MyPrinterViewCurrentDic = [[NSMutableDictionary alloc]init];
    
    [MyPrinterViewCurrentDic setObject:[[NSMutableArray alloc]init] forKey:@"Unit"];
    
    [MyPrinterViewCurrentDic writeToFile:MyPrinterViewPath atomically:YES];
    
    [MyPrinterViewCurrentDic setObject:@"TSC" forKey:@"Type"];
   
    [self.MyPrinterUnitArr removeAllObjects];
    
    [self.MyPrinterViewCurrentDic removeAllObjects];
    
}

//外部调用的方法
-(UIImage *)PreViewMakeImageWithMyPrinterView
{
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 [UIScreen mainScreen].scale。
    for (UIView *view in self.myPrinterView.subviews) {
        
        view.layer.borderColor = [UIColor clearColor].CGColor;
        view.layer.borderWidth = 0;
        view.layer.cornerRadius = 0;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.myPrinterView.bounds.size, NO, 0.0);
    [self.myPrinterView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//  NSData *jpgData = UIImagePNGRepresentation(image);
//  UIImage *pngImage = [UIImage imageWithData:jpgData];
    return image;
}

//选取模板，将模板内容在画板呈现
-(void)RefreshPrinterViewWithNewPlist
{
    
    for (UIView *view in _myPrinterView.subviews)
    {
        [view removeFromSuperview];
    }
    [self reSetMyPrinterSize];
    
    [self.MyPrinterUnitArr removeAllObjects];
    
    [self.MyPrinterViewCurrentDic removeAllObjects];
    
    self.MyPrinterViewCurrentDic = [SettingsSETObj GetSettingsDictionaryWithName:@"MyPrinterViewPList"];
    
    [self.MyPrinterUnitArr addObjectsFromArray:self.MyPrinterViewCurrentDic[@"Unit"]];

    if (self.MyPrinterUnitArr.count )
    {
      [self toRecoverBeforePrinterViewWithArray:self.MyPrinterUnitArr];
        
    }

}

#pragma mark - 重置标签尺寸
-(void)reSetMyPrinterSize
{
    //40 mm x 50 mm
    NSInteger defaultWidth = WIDTH-16;

    self.myPrinterView.frame = CGRectMake(8, 8, defaultWidth,defaultWidth*1.25);

    self.myPrinterViewScrollView.contentSize = CGSizeMake(defaultWidth+16,defaultWidth*1.25+16);
    
    [self.myPrinterViewScrollView addSubview:self.myPrinterView];
    
}

#pragma mark-从文件创建MyPrinterView上面的内容

-(void)toRecoverBeforePrinterViewWithArray:(NSArray *)unitArray
{
    
    for (NSInteger i = 0; i < unitArray.count; i++)
    {
        
        NSDictionary *dic = unitArray[i];
        CGFloat x =[dic[@"x"] floatValue];
        CGFloat y =[dic[@"y"] floatValue];
        CGFloat width = [dic[@"viewWidth"] floatValue];
        CGFloat height = [dic[@"viewHeight"] floatValue];
        if (width==0) {
            
            width = x *[dic[@"x-multiplication"] floatValue];
        }
        
        if (height==0)
        {
            
            height = y *[dic[@"y-multiplication"] floatValue];
        }
        
        if ([dic[@"name"] isEqualToString:@"GRAPH"])
        {
            switch ([dic[@"code"] integerValue])
            {
                //线
                case 100:
                {
                    myLineView *lineView = [[myLineView alloc]init];
                    lineView.lineWidth = [dic[@"lineWidth"] integerValue];
                    lineView.tag =Remaing+ i;
                    [self.myPrinterView addSubview:lineView];
                    [self addGestureRecognizerToView:lineView];
                
                    if ([dic[@"degree"] floatValue] > 0)
                    {
                     
                        CGAffineTransform currentTransform = lineView.transform;
                        CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                        lineView.transform = newTransform;
                        
                    }
                    
                    lineView.frame  = CGRectMake(x, y, width, height);
                    
                }
                    break;
                case 101:
                {
                    myRectangleView *rectangleView = [[myRectangleView alloc]init];
                    rectangleView.lineWidth = [dic[@"lineWidth"] integerValue];
                    rectangleView.tag =Remaing+ i;
                    [self.myPrinterView addSubview:rectangleView];
                    [self addGestureRecognizerToView:rectangleView];
                    
                    if ([dic[@"degree"] floatValue] > 0)
                    {
                        CGAffineTransform currentTransform = rectangleView.transform;
                        CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                        rectangleView.transform = newTransform;
                    }
                    
                    [_myPrinterView sendSubviewToBack:rectangleView];
                    
                    rectangleView.frame  = CGRectMake(x, y, width, height);
                    
                }
                    break;
                    
                default:
                {
                    if (x==y)
                    {
                        myCircleView *circleView = [[myCircleView  alloc]init];
                        circleView.lineWidth = [dic[@"lineWidth"] integerValue];
                        circleView.tag = Remaing + i;
                        [self.myPrinterView addSubview:circleView];
                        [self addGestureRecognizerToView:circleView];
                        if ([dic[@"degree"] floatValue] > 0)
                        {
                            CGAffineTransform currentTransform = circleView.transform;
                            CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                            circleView.transform = newTransform;
                            
                        }
                        
                        circleView.frame  = CGRectMake(x, y, width, height);
                
                    }
                    else
                    {
                        myOvalView *ovalView = [[myOvalView  alloc]init];
                        
                        ovalView.lineWidth = [dic[@"lineWidth"] integerValue];
                        
                        ovalView.tag = Remaing + i;
                        
                        [self.myPrinterView addSubview:ovalView];
                       
                        [self addGestureRecognizerToView:ovalView];
                        
                        if ([dic[@"degree"] floatValue] > 0)
                        {
                            CGAffineTransform currentTransform = ovalView.transform;
                            
                            CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                         
                            ovalView.transform = newTransform;
                    
                        }
                        ovalView.frame  = CGRectMake(x, y, width, height);
                        
                    }
                    
                }
                    break;
            }
            
        }
        
        if ([dic[@"name"] isEqualToString:@"TEXT"])
        {
            
            UILabel *mylabel = [[UILabel alloc]init];
            
            mylabel.text = dic[@"content"];
            
            mylabel.font = [UIFont fontWithName:dic[@"fontType"]size:[dic[@"fontSize"] floatValue]];
        
            mylabel.textAlignment = NSTextAlignmentCenter;
            
            mylabel.tag = Remaing+i;

            [self.myPrinterView addSubview:mylabel];

            [self addGestureRecognizerToView:mylabel];

            if ([dic[@"degree"] floatValue] > 0)
            {
                
                CGAffineTransform currentTransform = mylabel.transform;
                
                CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                
                mylabel.transform = newTransform;
                
            }
            mylabel.frame = CGRectMake(x, y, width,height);
            
        }
        
        if ([dic[@"name"] isEqualToString:@"RESIMAGE"]||[dic[@"name"] isEqualToString:@"PICTURE"])
        {
            
            
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.image = [UIImage imageWithData:dic[@"imageData"]];
            imageView.tag= Remaing+i;
            
            [self.myPrinterView addSubview:imageView];
            
            [self addGestureRecognizerToView:imageView];
            
            if ([dic[@"degree"] floatValue] > 0)
            {
                CGAffineTransform currentTransform = imageView.transform;
                CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                imageView.transform = newTransform;
            
            }
            
            imageView.frame = CGRectMake(x, y, width, height);
        }
        
        if ([dic[@"name"] isEqualToString:@"BARCODE"])
        {
    
        MyBarcodeView *barCodeView = [[MyBarcodeView alloc]init];
            
        barCodeView.tag = Remaing + i;
        
        BOOL isPass = YES;
        
        @try {
            
                if ([dic[@"code-type"] isEqualToString:@"EAN8"])
                {
                    [barCodeView toSetMyBarcodeViewWith:EAN8 andTittle:dic[@"code"]];
                }
                
                if ([dic[@"code-type"] isEqualToString:@"EAN13"])
                {
                    
                    [barCodeView toSetMyBarcodeViewWith:EAN13 andTittle:dic[@"code"]];
                
                }
                
                if ([dic[@"code-type"] isEqualToString:@"UPCA"])
                {
                    
                    [barCodeView toSetMyBarcodeViewWith:UPCA andTittle:dic[@"code"]];
                    
                }
                if ([dic[@"code-type"] isEqualToString:@"ITF"])
                {
                    
                    [barCodeView toSetMyBarcodeViewWith:ITF andTittle:dic[@"code"]];
                    
                }
                if ([dic[@"code-type"] isEqualToString:@"CODE39"])
                {
                    
                    [barCodeView toSetMyBarcodeViewWith:CODE39 andTittle:dic[@"code"]];
                    
                }
                if ([dic[@"code-type"] isEqualToString:@"CODE128"])
                {
                    
                    [barCodeView toSetMyBarcodeViewWith:CODE128 andTittle:dic[@"code"]];
                    
                }
            
                if ([dic[@"code-type"] isEqualToString:@"PDF_417"])
                {
                    [barCodeView toSetMyBarcodeViewWith:PDF417 andTittle:dic[@"code"]];
                }
            
            [self.myPrinterView addSubview:barCodeView];
                
                
            }
    
        @catch (NSException *exception)
        {
            
            isPass = NO;
            NSLog(@"Nick's Exception =%@",exception);
        
        }
        @finally
            {
            
            if (isPass)
            {
                if ([dic[@"showContent"] isEqualToString:@"ture"])
                {
                    barCodeView.isShowLabel = YES;
                }
                else
                {
                    
                    barCodeView.isShowLabel = YES;
                    
                }
                
                [barCodeView toRetMyViewUI];
                
                [self addGestureRecognizerToView:barCodeView];
                
                if ([dic[@"degree"] floatValue] > 0)
                {
                    
                    CGAffineTransform currentTransform = barCodeView.transform;
                    
                    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                    
                    barCodeView.transform = newTransform;
                    
                }
            
                barCodeView.frame = CGRectMake(x, y, width, height);
                
            }
            else
            {
            
                [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:[NSString stringWithFormat:@"%@为一个无效的 %@码！无法正确识别。",dic[@"code"],dic[@"code-type"]] andCancelTitle:@"好的" andCancelActionBlock:^{
                    
                    [barCodeView removeFromSuperview];
                    
                    [self saveChangesToPlistWhenAppToBacgroundOrEndEditing];
                    
                } andOtherTitle:nil andActionBlock:nil];
                
            }
           
            NSLog(@"End");
            
        };
        
    
    }
        
        if ([dic[@"name"] isEqualToString:@"QRCODE"])
        {
            
            
            MyQRCodeView *qrcodeView = [[MyQRCodeView alloc]init];
            
            [qrcodeView setQrcodeNewContentString:dic[@"content"]];
            
            [self.myPrinterView addSubview:qrcodeView];
            
            qrcodeView.tag = Remaing + i;
            
            [self addGestureRecognizerToView:qrcodeView];
            
            if ([dic[@"degree"] floatValue] > 0)
            {
                CGAffineTransform currentTransform = qrcodeView.transform;
                CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, [dic[@"degree"] floatValue] *M_PI / 180.0);
                qrcodeView.transform = newTransform;
                
            }
            
            qrcodeView.frame = CGRectMake(x, y, width, height);
        }
        
    }
    
}

#pragma mark - 给元素添加手势，可拖动等
// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    view.userInteractionEnabled = YES;
    
    // // 旋转手势
    //  UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    //  [view addGestureRecognizer:rotationGestureRecognizer];
   
    _currentEditView = view;

    for (UIView *elseView in self.myPrinterView.subviews)
    {
        
        if (elseView == view)
        {
            
            view.layer.borderColor = [UIColor lightGrayColor].CGColor;
            view.layer.borderWidth = 1.2f;
        }
        else
        {
            elseView.layer.borderColor = [UIColor clearColor].CGColor;
            elseView.layer.borderWidth = 0;
        }
        
    }
    
    NSString *name = [NSString stringWithUTF8String:object_getClassName(view)];
    if ([name isEqualToString:@"UILabel"]||[name isEqualToString:@"MyQRCodeView"]||[name isEqualToString:@"MyBarcodeView"] ||[name isEqualToString:@"myLineView"]||[name isEqualToString:@"myCircleView"]||[name isEqualToString:@"myRectangleView"]||[name isEqualToString:@"myOvalView"])
    {
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [view addGestureRecognizer:doubleTap];
        
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    [view addGestureRecognizer:tapGestureRecognizer];
    
    if (![name isEqualToString:@"UILabel"]) {
        
        // 缩放手势
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        [view addGestureRecognizer:pinchGestureRecognizer];
        
    }

    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
    
    
    // 添加边缘手势
    UIScreenEdgePanGestureRecognizer *ges = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(EdgePanGesture:)];
    // 指定左边缘滑动
    ges.edges = UIRectEdgeLeft;
    
    [view addGestureRecognizer:ges];
    
}

-(void)EdgePanGesture:(UIScreenEdgePanGestureRecognizer*)edge
{
    
    NSLog(@"Edge !!!");
    
}


-(void)doubleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIView *view = tapGestureRecognizer.view;
    _currentEditView = view;
    NSString *name = [NSString stringWithUTF8String:object_getClassName(view)];
    if ([name isEqualToString:@"UILabel"])
    {
        
      UILabel *myLabel = (UILabel *)view;
        
      NSDictionary *editLabelInfoDic = [[NSDictionary alloc]initWithObjects:@[myLabel.text,myLabel.font.fontName,@(myLabel.font.pointSize)] forKeys:@[@"text",@"fontName",@"fontSize"]];

        EditTextViewController *textCtl = [[EditTextViewController alloc]init];
        
        textCtl.isEdit = YES;
        
        textCtl.editLabelInfoDic = editLabelInfoDic;
        
        textCtl.cb = ^(NSDictionary *labelInfo)
        {
            NSLog(@"labelInfo = %@",labelInfo);
            
            myLabel.bounds = CGRectMake(0, 0,[PrinterToolsObj getMyLabelFont:labelInfo[@"fontName"] andFontSize:[labelInfo[@"fontSize"] integerValue] andText:labelInfo[@"text"]].width, [PrinterToolsObj getMyLabelFont:labelInfo[@"fontName"] andFontSize:[labelInfo[@"fontSize"] integerValue] andText:labelInfo[@"text"]].height);
            
            myLabel.font = [UIFont fontWithName:labelInfo[@"fontName"] size:[labelInfo[@"fontSize"] integerValue]];
            
            myLabel.text = labelInfo[@"text"];
            

        
        };
        
        [self.navigationController pushViewController:textCtl animated:YES];
        
    }
    
    if ([name isEqualToString:@"MyQRCodeView"])
    {
        
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"输入代码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        MyQRCodeView *qrCode = (MyQRCodeView *)view;
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = qrCode.contentString;
            
        }];
    
        UIAlertAction *alertCacnel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertCtl addAction:alertCacnel];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            
                                            UITextField *textField = [alertCtl.textFields firstObject];
                                            
                                            if (textField.text.length) {
                                                
                                                [qrCode setQrcodeNewContentString:textField.text];
                                            }
                                            else
                                            {
                                                textField.placeholder = @"请输入内容.";
                                                [self presentViewController:alertCtl animated:YES completion:nil];
                                                
                                            }
                                            
                                        }];
        

        [alertCtl addAction:confirmAction];
        
        [self presentViewController:alertCtl animated:YES completion:nil];
    }
    
    if ([name isEqualToString:@"MyBarcodeView"]) {
        

        MyBarcodeView *barCode = (MyBarcodeView *)view;
        
        if (barCode.CodeType == PDF417) {
            
            NSLog(@"PDF417");
            PDF418ViewController *PDF417Ctl = [[PDF418ViewController alloc]init];
            PDF417Ctl.content = barCode.Content;
            PDF417Ctl.isEditing = YES;
            PDF417Ctl.cb = ^(NSMutableDictionary *dic) {
                
                NSInteger type = [dic[@"Type"] integerValue];
                
                NSString *content = dic[@"Content"];
                
               [barCode toSetMyBarcodeViewWith:type andTittle:content];
                
            };
            
            [self.navigationController pushViewController:PDF417Ctl animated:YES];
            
        }
        else
        {
            BarcodeViewController *barcodeCtl = [[BarcodeViewController alloc]init];
            barcodeCtl.isEditing = YES;
            barcodeCtl.content = barCode.Content;
            barcodeCtl.codeType = barCode.CodeType;
            
            NSLog(@"barCode.Content = %@ , barCode.CodeType= %zd",barCode.Content,barCode.CodeType);
            
            barcodeCtl.cb = ^(NSMutableDictionary *dic) {
                
                NSLog(@"Dic = %@",dic);
                
                NSInteger type = [dic[@"Type"] integerValue];
                
                NSString *content = dic[@"Content"];
                
                [barCode toSetMyBarcodeViewWith:type andTittle:content];
                
        
            };
            
            [self.navigationController pushViewController:barcodeCtl animated:YES];
            
            
        }
        
    }
    
    if ([name isEqualToString:@"myLineView"])
    {
        myLineView *LineView = (myLineView *)view;
        
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"线" message:@"请依次输入线的长度，与宽度，单位为像素。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%.0f",LineView.frame.size.width];
            
            textField.keyboardType = UIKeyboardTypeNumberPad;
        
        }];
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%zd",LineView.lineWidth];
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertCtl addAction:cancleAction];
        
        UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           UITextField *texfield1 = alertCtl.textFields[0];
                                           
                                           UITextField *textfield2 = alertCtl.textFields[1];
                                           
                                           if (texfield1.text.length==0 || textfield2.text == 0)
                                           {
                                               
                                               texfield1.placeholder = @"输入不能为空!";
                                               textfield2.placeholder = @"输入不能为空!";
                                               [self presentViewController:alertCtl animated:YES completion:nil];
                                
                                           }
                                           else
                                           {
                                               
                                               CGFloat x = LineView.frame.origin.x;
                                               CGFloat y = LineView.frame.origin.y;
                                               [LineView removeFromSuperview];
                                               myLineView *newLineView =[[myLineView alloc]initWithFrame:CGRectMake(x,y, [texfield1.text integerValue],30)];
                                               newLineView.lineWidth = [textfield2.text integerValue];
                                               [self.myPrinterView addSubview:newLineView];
                                               [self addGestureRecognizerToView:newLineView];
                                               newLineView.tag = Remaing + self.myPrinterView.subviews.count;

                                           }
                                       }];
        
        [alertCtl addAction:confirAction];
        
        [self presentViewController:alertCtl animated:YES completion:nil];
        
    }
    
    
    if ([name isEqualToString:@"myOvalView"])
    {
        
        myOvalView *OvalView = (myOvalView *)view;
        
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"椭圆" message:@"请依次输入椭圆的宽度，高度，线宽，单位为像素。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%.0f",OvalView.frame.size.width-10];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
        }];
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%.0f",OvalView.frame.size.height-10];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
        }];
        
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%zd",OvalView.lineWidth];
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertCtl addAction:cancleAction];
    
        UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           UITextField *texfield1 = alertCtl.textFields[0];
                                           
                                           UITextField *textfield2 = alertCtl.textFields[1];
                                           
                                           UITextField *textfield3 = alertCtl.textFields[2];
                                           
                                           if (texfield1.text.length==0 || textfield2.text == 0 || textfield3.text == 0) {
                                               
                                               texfield1.placeholder = @"输入不能为空!";
                                               textfield2.placeholder = @"输入不能为空!";
                                               textfield3.placeholder = @"输入不能为空!";
                                               [self presentViewController:alertCtl animated:YES completion:nil];
                                           }
                                           else
                                           {
                                               
                                               CGFloat x = OvalView.frame.origin.x;
                                               CGFloat y = OvalView.frame.origin.y;
                                               [OvalView removeFromSuperview];
                                               
                                               myOvalView *newOvalView = [[myOvalView alloc]initWithFrame:CGRectMake(x, y, [texfield1.text integerValue]+10, [textfield2.text integerValue]+10)];
                                               newOvalView.lineWidth = [textfield3.text integerValue];
                                               newOvalView.tag = Remaing + self.myPrinterView.subviews.count;
                                               [self.myPrinterView addSubview:newOvalView];
                                               [self addGestureRecognizerToView:newOvalView];
                                               
                                               
                                           }
                                           
                                       }];
        
        [alertCtl addAction:confirAction];
        
        __weak PrinterViewController *weakSelf = self;
        
        /*延迟执行时间2秒*/
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            
            [weakSelf presentViewController:alertCtl animated:YES completion:nil];
            
        });
        
    }
    
    
    if ([name isEqualToString:@"myRectangleView"])
    {
        
        
        myRectangleView *RectangleView = (myRectangleView *)view;
        
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"矩形" message:@"请依次输入矩形的长，宽，线宽，单位为像素。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%.0f",RectangleView.frame.size.width -16];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
        }];
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%.0f",RectangleView.frame.size.height -16];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
        }];
        
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%zd",RectangleView.lineWidth];
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertCtl addAction:cancleAction];
        
        UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           UITextField *texfield1 = alertCtl.textFields[0];
                                           
                                           UITextField *textfield2 = alertCtl.textFields[1];
                                           
                                           UITextField *textfield3 = alertCtl.textFields[2];
                                           
                                           if (texfield1.text.length==0 || textfield2.text == 0 || textfield3.text == 0) {
                                               
                                               texfield1.placeholder = @"输入不能为空!";
                                               textfield2.placeholder = @"输入不能为空!";
                                               textfield3.placeholder = @"输入不能为空!";
                                               [self presentViewController:alertCtl animated:YES completion:nil];
                                           }
                                           else
                                           {
                                     
                                               
                                               CGFloat x = RectangleView.frame.origin.x;
                                               
                                               CGFloat y = RectangleView.frame.origin.y;
                                               
                                               [RectangleView removeFromSuperview];
                                               
                                               myRectangleView *rectangleView = [[myRectangleView alloc]initWithFrame:CGRectMake(x, y, [texfield1.text integerValue]+16, [textfield2.text integerValue]+16)];
                                               rectangleView.lineWidth = [textfield3.text integerValue];
                                               
                                               [self.myPrinterView addSubview:rectangleView];
                                               
                                               rectangleView.tag = Remaing + self.myPrinterView.subviews.count;
                                               
                                               [self addGestureRecognizerToView:rectangleView];
                                               
                                               [_myPrinterView sendSubviewToBack:rectangleView];
                                               
                                           }
                    
                                       }];
        
        [alertCtl addAction:confirAction];
        
        [self presentViewController:alertCtl animated:YES completion:nil];
    
    }
    
    
    if ([name isEqualToString:@"myCircleView"])
    {
        
        myCircleView *CircleView = (myCircleView *)view;
        
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"圆" message:@"请依次输入圆的直径，线宽，单位为像素。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%.0f",CircleView.frame.size.width-8];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
        }];
        
    
        [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.text = [NSString stringWithFormat:@"%zd",CircleView.lineWidth];
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertCtl addAction:cancleAction];
        
        UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           UITextField *texfield1 = alertCtl.textFields[0];
                                           
                                           UITextField *textfield3 = alertCtl.textFields[1];
                                           
                                           if (texfield1.text.length==0 || textfield3.text == 0) {
                                               
                                               texfield1.placeholder = @"输入不能为空!";
                                               textfield3.placeholder = @"输入不能为空!";
                                               [self presentViewController:alertCtl animated:YES completion:nil];
                                           }
                                           else
                                           {
                        
                                               CGFloat x = CircleView.frame.origin.x;
                                
                                               CGFloat y = CircleView.frame.origin.y;
                            
                                               [CircleView removeFromSuperview];
                                               
                                               myCircleView *newCircleView =[[myCircleView alloc]initWithFrame:CGRectMake(x,y, [texfield1.text integerValue]+8,[texfield1.text integerValue]+8)];
                                               
                                               newCircleView.lineWidth = [textfield3.text integerValue];
                                               
                                               [self.myPrinterView addSubview:newCircleView];
                                            
                                               [self addGestureRecognizerToView:newCircleView];
                                               
                                               newCircleView.tag = Remaing + self.myPrinterView.subviews.count;
                                           }
                                           
                                       }];
        
        [alertCtl addAction:confirAction];

        [self presentViewController:alertCtl animated:YES completion:nil];
        
    }
}
//处理点击手势
-(void) tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIView *view = tapGestureRecognizer.view;
    _currentEditView = view;
    
    NSLog(@"_currentEditView =  %@ %zd",_currentEditView,_currentEditView.tag);
    
    for (UIView *elseView in self.myPrinterView.subviews)
    {
        
        if (elseView == view)
        {
            
            view.layer.borderColor = [UIColor lightGrayColor].CGColor;
            view.layer.borderWidth = 1.2f;
        }
        else
        {
            elseView.layer.borderColor = [UIColor clearColor].CGColor;
            elseView.layer.borderWidth = 0;
            
        }
    
    }
    
}
// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    _currentEditView = view;
    
    for (UIView *elseView in self.myPrinterView.subviews)
    {
        
        if (elseView == view)
        {
            view.layer.borderColor = [UIColor lightGrayColor].CGColor;
            view.layer.borderWidth = 1.2f;
        }
        else
        {
            elseView.layer.borderColor = [UIColor clearColor].CGColor;
            elseView.layer.borderWidth = 0;
        }
    }

    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    _currentEditView = view;
    
    for (UIView *elseView in self.myPrinterView.subviews) {
        
        if (elseView == view) {
            
            view.layer.borderColor = [UIColor lightGrayColor].CGColor;
            view.layer.borderWidth = 1.2f;
        }
        else
        {
            elseView.layer.borderColor = [UIColor clearColor].CGColor;
            elseView.layer.borderWidth = 0;
            
        }
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        
    }
    
}

#pragma mark- my Scale buttons Actions（放大，缩小）

- (IBAction)magnifyAction:(id)sender
{
    
    [UIView beginAnimations:nil context:nil];
    
    NSLog(@"_currentEditView =  %@",_currentEditView);
    
    
    NSString *name = [NSString stringWithUTF8String:object_getClassName(_currentEditView)];
    
    NSLog(@"name = %@",name);
    
    if ([name isEqualToString:@"UILabel"])
    {
        UILabel *label = (UILabel *)_currentEditView;
        
        UIFont *currentFont = label.font;
        
        CGFloat newFontSize = currentFont.pointSize;
        
        if (currentFont.pointSize <200) {
            
            newFontSize++;
            
        }

        [label setFont:[UIFont fontWithName:currentFont.fontName size:newFontSize]];
        
        label.bounds = CGRectMake(0, 0, [PrinterToolsObj getMyLabelFont:currentFont.fontName andFontSize:newFontSize andText:label.text].width, [PrinterToolsObj getMyLabelFont:currentFont.fontName andFontSize:newFontSize andText:label.text].height);
        
        
    }
    else
    {
        
        CGAffineTransform currentTrans = _currentEditView.transform;
        
        //    a,d表示放大缩小有关
        _currentEditView.transform = CGAffineTransformScale(currentTrans,1.3,1.3);
        
         [UIView commitAnimations];
        
    }
    
}

- (IBAction)shrinkAction:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    
    NSLog(@"_currentEditView =  %@",_currentEditView);
    
    NSString *name = [NSString stringWithUTF8String:object_getClassName(_currentEditView)];
    
    NSLog(@"name = %@",name);
    
    if ([name isEqualToString:@"UILabel"])
    {
        UILabel *label = (UILabel *)_currentEditView;
        
        UIFont *currentFont = label.font;
        
        CGFloat newFontSize = currentFont.pointSize;
        
        if (currentFont.pointSize > 4) {
            
            newFontSize--;
            
        }
        
        [label setFont:[UIFont fontWithName:currentFont.fontName size:newFontSize]];
        
        label.bounds = CGRectMake(0, 0, [PrinterToolsObj getMyLabelFont:currentFont.fontName andFontSize:newFontSize andText:label.text].width, [PrinterToolsObj getMyLabelFont:currentFont.fontName andFontSize:newFontSize andText:label.text].height);
        
        
    }
    else
    {
        
        CGAffineTransform currentTrans = _currentEditView.transform;
        
        //    a,d表示放大缩小有关
        _currentEditView.transform = CGAffineTransformScale(currentTrans,0.7,0.7);
        
        [UIView commitAnimations];
        
        
    }
    
    


}

#pragma mark - DownView Actions

//扫描
- (IBAction)scanAction:(id)sender
{
    WQCodeScanner *scanner = [[WQCodeScanner alloc] init];
    [self presentViewController:scanner animated:YES completion:nil];
    scanner.resultBlock = ^(NSDictionary *valueDic)
    {
        NSLog(@"valueDic = %@",valueDic);
        
        NSString *type = valueDic[@"Type"];
        
        NSInteger CodeTye = 11;
        
        if ([type containsString:@"QRCode"])
        {
            
            CodeTye = QRCode;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        
        if ([type containsString:@"EAN-8"]) {
            
            CodeTye = EAN8;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        
        if ([type containsString:@"EAN-13"]) {
            
            CodeTye = EAN13;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        
        if ([type containsString:@"UPCA"]) {
            
            CodeTye = UPCA;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        
        if ([type containsString:@"ITF"]) {
            
            CodeTye = ITF;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        if ([type containsString:@"Code39"]) {
            
            CodeTye = CODE39;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        
        if ([type containsString:@"Code128"]) {
            
            CodeTye = CODE128;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        
        
        if ([type containsString:@"PDF417"]) {
            
            CodeTye = PDF417;
            [self AddBarcodeOrQrcodeToPrinterViewWithType:CodeTye andContent:valueDic[@"Content"]];
            
        }
        
        
    };
    
    
    
}
//模板的保存、读取
- (IBAction)saveOrReadAction:(id)sender
{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"保存或者读取" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //模板的保存
     [self saveModelToCaches];
    
    }];
    
    UIAlertAction *readAction = [UIAlertAction actionWithTitle:@"读取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
     //模板的读取
     [self readModelFromCaches];
    
    }];

    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [actionSheet addAction:saveAction];
    
    [actionSheet addAction:readAction];
    
    [actionSheet addAction:cancleAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

//添加图片
- (IBAction)addPictureAction:(id)sender
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}
//缩放
- (IBAction)scaleAction:(id)sender
{

    _isScaleViewHidden = !_isScaleViewHidden;
    _scaleView.hidden = _isScaleViewHidden;
    
}

//图形
- (IBAction)addShapeAction:(UIButton *)sender {
    
    
    shapePaopaoView  *paopaoCtl = [[shapePaopaoView alloc]init];
    
    paopaoCtl.modalPresentationStyle=UIModalPresentationPopover;
    
    paopaoCtl.preferredContentSize=CGSizeMake(250, 55);
    
    paopaoCtl.popoverPresentationController.permittedArrowDirections=  UIPopoverArrowDirectionDown;
    
    paopaoCtl.popoverPresentationController.sourceRect=sender.bounds;
    
    paopaoCtl.popoverPresentationController.sourceView=sender;
    
    paopaoCtl.popoverPresentationController.delegate = self;
    
    paopaoCtl.cb = ^(NSInteger index)
    {
        
        NSLog(@"Index = %zd",index);
        
        switch (index) {
                
            //添加线
            case 1:
            {
                    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"线" message:@"请依次输入线的长度，与宽度，单位为像素。" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        
                        textField.text = @"100";
                        textField.keyboardType = UIKeyboardTypeNumberPad;
                        
                    }];
                
                    [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        
                        textField.text = @"2";
                        textField.keyboardType = UIKeyboardTypeNumberPad;
                
                    }];
                    
                    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    
                    [alertCtl addAction:cancleAction];
                
                    UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                                   {
                                                       UITextField *texfield1 = alertCtl.textFields[0];
                                                       
                                                       UITextField *textfield2 = alertCtl.textFields[1];
                
                                                       if (texfield1.text.length==0 || textfield2.text == 0)
                                                       {
                                                    
                                                           texfield1.placeholder = @"输入不能为空!";
                                                           textfield2.placeholder = @"输入不能为空!";
                                                           [self presentViewController:alertCtl animated:YES completion:nil];
                                                       
                                                       }
                                                       else
                                                       {
                                                    
                                                           myLineView *lineView = [[myLineView alloc]initWithFrame:CGRectMake(8, 8, [texfield1.text  integerValue], 30)];
                                                           lineView.lineWidth = [textfield2.text integerValue];
                                                           [self.myPrinterView addSubview:lineView];
                                                           lineView.tag = Remaing + self.myPrinterView.subviews.count;
                                                           [self addGestureRecognizerToView:lineView];
                                                           
                                                       }
                                                       
                                                   }];
                    
                    [alertCtl addAction:confirAction];
                
                __weak PrinterViewController *weakSelf = self;
                /*延迟执行时间2秒*/
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    
                    [weakSelf presentViewController:alertCtl animated:YES completion:nil];
    
                });
            }
                break;
            //添加矩形
            case 2:
            {
                
                UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"矩形" message:@"请依次输入矩形的长，宽，线宽，单位为像素。" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    
                    textField.text = @"100";
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    
                }];
                
                [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    
                    textField.text = @"100";
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    
                }];
                
                
                [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    
                    textField.text = @"2";
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                }];
                
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                
                [alertCtl addAction:cancleAction];
                
                UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                               {
                                                   UITextField *texfield1 = alertCtl.textFields[0];
                                                   
                                                   UITextField *textfield2 = alertCtl.textFields[1];
                                                   
                                                   UITextField *textfield3 = alertCtl.textFields[2];
                                                   
                                                   if (texfield1.text.length==0 || textfield2.text == 0 || textfield3.text == 0) {
                                                       
                                                       texfield1.placeholder = @"输入不能为空!";
                                                       textfield2.placeholder = @"输入不能为空!";
                                                       textfield3.placeholder = @"输入不能为空!";
                                                       [self presentViewController:alertCtl animated:YES completion:nil];
                                                   }
                                                   else
                                                   {
                                                       
                                                       myRectangleView *rectangleView = [[myRectangleView alloc]initWithFrame:CGRectMake(8, 8, [texfield1.text integerValue]+16, [textfield2.text integerValue]+16)];
                                                       rectangleView.lineWidth = [textfield3.text integerValue];
                                                       [self.myPrinterView addSubview:rectangleView];
                                                       
                                                       rectangleView.tag = Remaing + self.myPrinterView.subviews.count;
                                                       
                                                       
                                                       [self addGestureRecognizerToView:rectangleView];
                                                       
                                                       [_myPrinterView sendSubviewToBack:rectangleView];
                                                   }
                                            
                                                   
                                               }];
                
                [alertCtl addAction:confirAction];
                
                __weak PrinterViewController *weakSelf = self;
                /*延迟执行时间2秒*/
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    
                    [weakSelf presentViewController:alertCtl animated:YES completion:nil];
                    
                });

            }
            
            break;
            //添加圆 OR 椭圆
            case 3:
            {
                
                UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"圆/椭圆" message:@"请依次输入圆/椭圆的宽度，高度，线宽，单位为像素。" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    
                    textField.text = @"100";
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    
                }];
                
                [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
                 {
                    textField.text = @"100";
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    
                }];
             
                [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    
                    textField.text = @"2";
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                }];
                
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                
                [alertCtl addAction:cancleAction];
                
                UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                               {
                                                   UITextField *texfield1 = alertCtl.textFields[0];
                                                   
                                                   UITextField *textfield2 = alertCtl.textFields[1];
                                                   
                                                   UITextField *textfield3 = alertCtl.textFields[2];
                                                   
                                                   if (texfield1.text.length==0 || textfield2.text == 0 || textfield3.text == 0) {
                                                       
                                                       texfield1.placeholder = @"输入不能为空!";
                                                       textfield2.placeholder = @"输入不能为空!";
                                                       textfield3.placeholder = @"输入不能为空!";
                                                       [self presentViewController:alertCtl animated:YES completion:nil];
                                                   }
                                                   else
                                                   {
                                                       
                                                       if (texfield1.text == textfield2.text)
                                                       {
                                                
                                                           myCircleView *circleView = [[myCircleView alloc]initWithFrame:CGRectMake(8, 8, [texfield1.text integerValue]+8, [textfield2.text integerValue]+8)];
                                                           circleView.lineWidth = [textfield3.text integerValue];
                                                           [self.myPrinterView addSubview:circleView];
                                                           [self addGestureRecognizerToView:circleView];
                                                           circleView.tag = Remaing + self.myPrinterView.subviews.count;
                                                           
                                                       }
                                                       else
                                                       {
                                                           
                                                           myOvalView *ovalView = [[myOvalView alloc]initWithFrame:CGRectMake(8, 8, [texfield1.text integerValue]+10, [textfield2.text integerValue]+10)];
                                                           ovalView.lineWidth = [textfield3.text integerValue];
                                                           ovalView.tag = Remaing + self.myPrinterView.subviews.count;
                                                           [self.myPrinterView addSubview:ovalView];
                                                           [self addGestureRecognizerToView:ovalView];
                                                       }
                                                       
                                                   }
                                                   
                                               }];
                
                [alertCtl addAction:confirAction];
                
                __weak PrinterViewController *weakSelf = self;
                
                /*延迟执行时间2秒*/
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    
                 [weakSelf presentViewController:alertCtl animated:YES completion:nil];
                
                });
            
            }
             break;
            //添加特殊图片
            default:
            {
                [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示！" andMessage:@"暂时还没有图标资源，敬请期待！" andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                
            }
            break;
        }
        
        
    };
    
    [self presentViewController:paopaoCtl animated:YES completion:nil];
    
}

//清屏
- (IBAction)cleanAction:(id)sender
{
    
    [self toResetMyCurrentPlist];
    
}

//旋转
- (IBAction)spinSubjectAction:(id)sender
{
    
    CGAffineTransform currentTransform = _currentEditView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, 90 *M_PI / 180.0);
    _currentEditView.transform = newTransform;
    
}

//删除
- (IBAction)deleteAction:(id)sender
{
    
    [_currentEditView removeFromSuperview];
    
    
    
}

- (IBAction)addTextAction:(id)sender {
    
    EditTextViewController *textCtl = [[EditTextViewController alloc]init];
    
    textCtl.cb = ^(NSDictionary *labelInfo) {
      
        NSLog(@"labelInfo = %@",labelInfo);
        
        
        UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, [PrinterToolsObj getMyLabelFont:labelInfo[@"fontName"] andFontSize:[labelInfo[@"fontSize"] integerValue] andText:labelInfo[@"text"]].width, [PrinterToolsObj getMyLabelFont:labelInfo[@"fontName"] andFontSize:[labelInfo[@"fontSize"] integerValue] andText:labelInfo[@"text"]].height)];
        
        myLabel.font = [UIFont fontWithName:labelInfo[@"fontName"] size:[labelInfo[@"fontSize"] integerValue]];
        
        myLabel.textAlignment =  NSTextAlignmentCenter;
        
        myLabel.tag = Remaing + self.myPrinterView.subviews.count;
        
        myLabel.text = labelInfo[@"text"];
        
        [self addGestureRecognizerToView:myLabel];
        
        [self.myPrinterView addSubview:myLabel];
        
        
    };
    
    [self.navigationController pushViewController:textCtl animated:YES];
}

- (IBAction)barcodeOrQRcodeAction:(UIButton *)sender {
    
    
    barCodePaopaoView  *paopaoCtl = [[barCodePaopaoView alloc]init];
    
    paopaoCtl.modalPresentationStyle=UIModalPresentationPopover;
    
    paopaoCtl.preferredContentSize=CGSizeMake(250, 55);
    
    paopaoCtl.popoverPresentationController.permittedArrowDirections=  UIPopoverArrowDirectionDown;
    
    paopaoCtl.popoverPresentationController.sourceRect=sender.bounds;
    
    paopaoCtl.popoverPresentationController.sourceView=sender;
    
    paopaoCtl.popoverPresentationController.delegate = self;
    
    paopaoCtl.cb = ^(NSInteger index)
    {
        
        NSLog(@"Index = %zd",index);
        switch (index) {
            case 1:
            {
            
                BarcodeViewController *barcodeCtl = [[BarcodeViewController alloc]init];
                
                barcodeCtl.cb = ^(NSMutableDictionary *dic) {
                    
                    NSInteger type = [dic[@"Type"] integerValue];
                    
                    NSString *content = dic[@"Content"];
                    
                    [self AddBarcodeOrQrcodeToPrinterViewWithType:type andContent:content];
                    
                };
                
                __weak PrinterViewController *weakSelf = self;
                
                /*延迟执行时间2秒*/
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                
                    [weakSelf.navigationController pushViewController:barcodeCtl animated:YES];
                
                });
                
            }
                break;
            case 2:
            {
                
                QRCodeViewController *QRCodeCtl = [[QRCodeViewController alloc]init];
                
                QRCodeCtl.cb = ^(NSMutableDictionary *dic)
                {
                    NSInteger type = [dic[@"Type"] integerValue];
                    
                    NSString *content = dic[@"Content"];
                    
                    [self AddBarcodeOrQrcodeToPrinterViewWithType:type andContent:content];
                };
            
                __weak PrinterViewController *weakSelf = self;
                /*延迟执行时间2秒*/
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                
                    [weakSelf.navigationController pushViewController:QRCodeCtl animated:YES];
                    
                });
            }
             break;
                
            default:
            {
                
                PDF418ViewController *PDF417Ctl = [[PDF418ViewController alloc]init];
                PDF417Ctl.cb = ^(NSMutableDictionary *dic) {
                    
                    NSInteger type = [dic[@"Type"] integerValue];
                    
                    NSString *content = dic[@"Content"];
                    
                    [self AddBarcodeOrQrcodeToPrinterViewWithType:type andContent:content];
                    
                };
                
                __weak PrinterViewController *weakSelf = self;
                /*延迟执行时间2秒*/
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController pushViewController:PDF417Ctl animated:YES];
                });
                
               
                
            }
                break;
        }
        
        
    };
    
    [self presentViewController:paopaoCtl animated:YES completion:nil];
    
}

#pragma mark-模板的保存与读取

-(void)readModelFromCaches
{
    
    FormBoardViewController *formBoardCtl = [[FormBoardViewController alloc]init];
    
    [self.navigationController pushViewController:formBoardCtl animated:YES];
    
    
}

-(void)saveModelToCaches
{

    
    if (_myPrinterView.subviews.count)
    {
        NSLog(@"Save Plist!");
        
        NSString *myTittle = @"保存模板";
        
        UIAlertController *AlertCtl = [UIAlertController alertControllerWithTitle:myTittle message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [AlertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
        {
         
            textField.placeholder = @"请输入您要保存的文件名";

        }];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *textField = [AlertCtl.textFields firstObject];
            
            NSString *path = [NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath];
            
            NSLog(@"Path = %@",path);
            
            if (textField.text.length == 0 ||[self Chuckawayspace:textField.text].length == 0 )
            {
                textField.text = @"";
                textField.placeholder =@"文件名不能全为空格。";
                [self presentViewController:AlertCtl animated:YES completion:nil];
            }
            else
            {
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                NSString *filePatch = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",textField.text]];
                
                NSLog(@"filePatch = %@",filePatch);
                
                BOOL isExist = [fileManager fileExistsAtPath:filePatch];
                
                if (isExist)
                {
                    textField.text = @"";
                    textField.placeholder =@"该文件名已经存在，请重新输入。";
                    [self presentViewController:AlertCtl animated:YES completion:nil];
                }
                else
                {
                    
                    NSMutableDictionary *dataDic  = [[NSMutableDictionary alloc]init];
                    
                    [dataDic setObject:[self ReturnCurrentUnitArray] forKey:@"Unit"];
                    
                    if ([dataDic writeToFile:filePatch atomically:YES])
                    {
                        
                        [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"模板保存成功！" andCancelTitle:@"确定" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                    }
                    else
                    {
                     
                        [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"糟糕！模板保存失败了！" andCancelTitle:@"确定" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                    }
                }
                
            }
            
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [AlertCtl addAction:confirmAction];
        
        [AlertCtl addAction:cancleAction];
        
        [self presentViewController:AlertCtl animated:YES completion:nil];
       
    }
    else
    {
        
        [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"画板当前没有内容！" andCancelTitle:@"确定" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
    
    }
    
}

#pragma mark- 构造当前的的UnitArray
-(NSMutableArray *)ReturnCurrentUnitArray
{
    
    NSMutableArray *unitArray = [[NSMutableArray alloc]init];
    
    for (UIView *myView in self.myPrinterView.subviews)
    {
        
        NSMutableDictionary *itemDic = [[NSMutableDictionary alloc]init];
        
        NSLog(@"%@",myView);
        
        NSString *name = [NSString stringWithUTF8String:object_getClassName(myView)];
        
        NSLog(@"Class name = %@",name);
        
        CGAffineTransform trans = myView.transform;
    
        NSLog(@"trans.b = %g  trans.c = %g",trans.b,trans.c);
        
        CGFloat rotate = acosf(trans.a);
        
        NSLog(@"old rotate = %g",rotate);
    
        // 旋转180度后，需要处理弧度的变化
        if (trans.b < 0)
        {
            rotate = M_PI*2 -rotate;
        }
        
         NSLog(@"new rotate = %g",rotate);
        
        // 将弧度转换为角度
        CGFloat degree = rotate/M_PI * 180;
        
        NSLog(@"Degree = %g",degree);
        
        if (degree < 90.0 && degree >0)
        {
            //设置旋转角度
            [itemDic setValue:@(0) forKey:@"degree"];
         }
        else
        {
            //设置旋转角度
            [itemDic setValue:@(degree) forKey:@"degree"];
            
        }
        
        //设置放大倍数
        //CGFloat scale = fabsf(trans.b);
        //CGFloat scale2 = fabsf(trans.c);
        
        [itemDic setValue:@(1.0) forKey:@"scaleX"];
        
        [itemDic setValue:@(1.0) forKey:@"scaleY"];
        
        [itemDic setValue:@(myView.frame.origin.x) forKey:@"x"];
        
        [itemDic setValue:@(myView.frame.origin.y) forKey:@"y"];
        
        [itemDic setValue:@(myView.frame.size.width) forKey:@"viewWidth"];
        
        [itemDic setValue:@(myView.frame.size.height) forKey:@"viewHeight"];
        
        if ([name  isEqualToString:@"myOvalView"])
        {
            myOvalView *ovalView = (myOvalView*)myView;
            [itemDic setObject:@(ovalView.lineWidth) forKey:@"lineWidth"];
            [itemDic setObject:@"GRAPH" forKey:@"name"];
            [itemDic setObject:@(102) forKey:@"code"];
            
        }
        
        if ([name  isEqualToString:@"myLineView"])
        {
            myLineView *lineView = (myLineView*)myView;
            [itemDic setObject:@(lineView.lineWidth) forKey:@"lineWidth"];
            [itemDic setObject:@"GRAPH" forKey:@"name"];
            [itemDic setObject:@(100) forKey:@"code"];
        }
        
        if ([name  isEqualToString:@"myCircleView"])
        {
            myCircleView *circleView = (myCircleView*)myView;
            [itemDic setObject:@(circleView.lineWidth) forKey:@"lineWidth"];
            [itemDic setObject:@"GRAPH" forKey:@"name"];
            [itemDic setObject:@(102) forKey:@"code"];
        }
        
        if ([name  isEqualToString:@"myRectangleView"])
        {
            myRectangleView *rectangleView = (myRectangleView*)myView;
            [itemDic setObject:@(rectangleView.lineWidth) forKey:@"lineWidth"];
            [itemDic setObject:@"GRAPH" forKey:@"name"];
            [itemDic setObject:@(101) forKey:@"code"];
        }
        
        if ([name  isEqualToString:@"MyQRCodeView"])
        {
            [itemDic setObject:@"QRCODE" forKey:@"name"];
            
            MyQRCodeView *qrCodeView = (MyQRCodeView *)myView;
            
            NSLog(@"QRCodeString = %@",qrCodeView.contentString);
            
            [itemDic setObject:qrCodeView.contentString forKey:@"content" ];
            
        }
        
        if ([name isEqualToString:@"MyBarcodeView"])
        {
            
            MyBarcodeView *barCodeView = (MyBarcodeView *)myView;
            
            [itemDic setObject:@"BARCODE" forKey:@"name"];
            
            [itemDic setObject:barCodeView.Content forKey:@"code"];
            
            if (barCodeView.isShowLabel)
            {
                [itemDic setObject:@"ture" forKey:@"showContent"];
                
            }
            else
            {
                
                [itemDic setObject:@"false" forKey:@"showContent"];
                
            }
            
            switch (barCodeView.CodeType)
            {
                case EAN8:
                {
                    [itemDic setObject:@"EAN8" forKey:@"code-type"];
                }
                    break;
                case EAN13:
                {
                    [itemDic setObject:@"EAN13" forKey:@"code-type"];
                }
                    break;
                    
                case UPCA:
                {
                    [itemDic setObject:@"UPCA" forKey:@"code-type"];
                }
                    break;
                case ITF:
                {
                    [itemDic setObject:@"ITF" forKey:@"code-type"];
                }
                    break;
                case CODE39:
                {
                    [itemDic setObject:@"CODE39" forKey:@"code-type"];
                }
                    break;
                case CODE128:
                {
                    [itemDic setObject:@"CODE128" forKey:@"code-type"];
                }
                    break;
                case PDF417:
                {
                    [itemDic setObject:@"PDF_417" forKey:@"code-type"];
                }
                    break;
                    
                default:
                    
                    break;
            }
        
        }
        
        if ([name  isEqualToString:@"UIImageView"])
        {
            
            UIImageView *ImageView = (UIImageView *)myView;
            
            [itemDic setObject:@"PICTURE" forKey:@"name"];
            
            [itemDic setObject:UIImagePNGRepresentation(ImageView.image) forKey:@"imageData"];
            
        }
        
        if ([name  isEqualToString:@"UILabel"])
        {
            UILabel *label = (UILabel *)myView;
            
            NSLog(@"Label.font.fontName = %@",label.font.fontName);
            
            [itemDic setObject:@"TEXT" forKey:@"name"];
            
            [itemDic setObject:@(label.font.pointSize) forKey:@"fontSize"];
            
            [itemDic setObject:label.text forKey:@"content"];
         
            [itemDic setObject:label.font.fontName forKey:@"fontType"];
    
        }
        
        [unitArray addObject:itemDic];
        
    }
    
    [self.MyPrinterUnitArr removeAllObjects];
    
    [self.MyPrinterUnitArr addObjectsFromArray:unitArray];
    
    NSLog(@"unitArray = %@",unitArray);
    
    return unitArray;
    
    
}

#pragma mark - 条形码，二维码
-(void)AddBarcodeOrQrcodeToPrinterViewWithType:(NSInteger)type andContent:(NSString *)content
{
    
    switch (type) {
        
        case EAN8:
        {
            NSError *error = nil;
            
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            
            ZXBitMatrix* result = [writer encode:content
                                          format:kBarcodeFormatEan8
                                           width:180
                                          height:66
                                           error:&error];

            if (result)
            {
            
                CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
            
                NSLog(@"%@",image);
                
                UIImage *imag=[UIImage imageWithCGImage:image];
                
                MyBarcodeView *barcodeView = [[MyBarcodeView alloc]init];
                
                barcodeView.frame = CGRectMake(10, 100, 200, 100);
                
                barcodeView.CodeType = type;
                
                [barcodeView setMyBarcodeViewWithImage:imag andTittle:content];
                
                [self.myPrinterView addSubview:barcodeView];
                
                barcodeView.tag = Remaing + self.myPrinterView.subviews.count;
                
                [self addGestureRecognizerToView:barcodeView];
                
                // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
            }
            else
            {
               
                NSString *errorMessage = [error localizedDescription];
                
                NSLog(@"Error = %@",errorMessage);
            
            }
            
        }
        break;
            
        case EAN13:
        {
            NSError *error = nil;
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            ZXBitMatrix* result = [writer encode:content
                                          format:kBarcodeFormatEan13
                                           width:210
                                          height:66
                                           error:&error];
            if (result) {
                CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
                NSLog(@"%@",image);
                
                UIImage *imag=[UIImage imageWithCGImage:image];
                
                MyBarcodeView *barcodeView = [[MyBarcodeView alloc]init];
                
                barcodeView.frame = CGRectMake(10, 100, 200, 100);
                barcodeView.CodeType = type;
                [barcodeView setMyBarcodeViewWithImage:imag andTittle:content];
                
                [self.myPrinterView addSubview:barcodeView];
                barcodeView.tag = Remaing + self.myPrinterView.subviews.count;
                
                [self addGestureRecognizerToView:barcodeView];
                // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
            } else {
                
                NSString *errorMessage = [error localizedDescription];
                NSLog(@"Error = %@",errorMessage);
                
            }
            
        }
            break;
        case UPCA:
        {
            
            NSError *error = nil;
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            ZXBitMatrix* result = [writer encode:content
                                          format:kBarcodeFormatUPCA
                                           width:210
                                          height:66
                                           error:&error];
            if (result) {
                CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
                NSLog(@"%@",image);
                
                UIImage *imag=[UIImage imageWithCGImage:image];
                
                MyBarcodeView *barcodeView = [[MyBarcodeView alloc]init];
                
                barcodeView.frame = CGRectMake(10, 100, 200, 100);
                barcodeView.CodeType = type;
                [barcodeView setMyBarcodeViewWithImage:imag andTittle:content];
                
                [self.myPrinterView addSubview:barcodeView];
                barcodeView.tag = Remaing + self.myPrinterView.subviews.count;
                [self addGestureRecognizerToView:barcodeView];
                
                // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
            } else {
                
                NSString *errorMessage = [error localizedDescription];
                
                NSLog(@"Error = %@",errorMessage);
    
            }
            
        }
            break;
        case ITF:
        {
            NSError *error = nil;
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            ZXBitMatrix* result = [writer encode:content
                                          format:kBarcodeFormatITF
                                           width:450
                                          height:150
                                           error:&error];
            if (result) {
                CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
                NSLog(@"%@",image);
                
                UIImage *imag=[UIImage imageWithCGImage:image];
                
                MyBarcodeView *barcodeView = [[MyBarcodeView alloc]init];
                
                barcodeView.frame = CGRectMake(10, 100, 200, 100);
                barcodeView.CodeType = type;
                [barcodeView setMyBarcodeViewWithImage:imag andTittle:content];
                [self.myPrinterView addSubview:barcodeView];
                barcodeView.tag = Remaing + self.myPrinterView.subviews.count;
                [self addGestureRecognizerToView:barcodeView];
                // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
            }
            else
            {
            
                NSString *errorMessage = [error localizedDescription];
                NSLog(@"Error = %@",errorMessage);
            }
            
        }
            break;
        
        case CODE39:
        {
            NSError *error = nil;
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            ZXBitMatrix* result = [writer encode:content
                                          format:kBarcodeFormatCode39
                                           width:380
                                          height:120
                                           error:&error];
            if (result) {
                CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
                NSLog(@"%@",image);
                
                UIImage *imag=[UIImage imageWithCGImage:image];
                
                MyBarcodeView *barcodeView = [[MyBarcodeView alloc]init];
                
                barcodeView.frame = CGRectMake(10, 100, 200, 100);
                barcodeView.CodeType = type;
                [barcodeView setMyBarcodeViewWithImage:imag andTittle:content];
                
                [self.myPrinterView addSubview:barcodeView];
                barcodeView.tag = Remaing + self.myPrinterView.subviews.count;
                
                [self addGestureRecognizerToView:barcodeView];
                
                
                // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
            } else {
                
                NSString *errorMessage = [error localizedDescription];
                NSLog(@"Error = %@",errorMessage);
                
            }
        }
            break;
        case CODE128:
        {
            
            NSError *error = nil;
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            ZXBitMatrix* result = [writer encode:content
                                          format:kBarcodeFormatCode128
                                           width:480
                                          height:150
                                           error:&error];
            if (result) {
                
                CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
                
                NSLog(@"%@",image);
            
                UIImage *imag=[UIImage imageWithCGImage:image];
                
                MyBarcodeView *barcodeView = [[MyBarcodeView alloc]init];
                
                barcodeView.frame = CGRectMake(10, 100, 200, 100);
                
                barcodeView.CodeType = type;
                
                [barcodeView setMyBarcodeViewWithImage:imag andTittle:content];
                
                [self.myPrinterView addSubview:barcodeView];
                
                barcodeView.tag = Remaing + self.myPrinterView.subviews.count;
               
                [self addGestureRecognizerToView:barcodeView];
                
                
                // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
            } else {
                
                NSString *errorMessage = [error localizedDescription];
            
                NSLog(@"Error = %@",errorMessage);
                
            }
        }
            break;
        case QRCode:
        {
            
            MyQRCodeView *qrcodeView = [[MyQRCodeView alloc]initWithFrame:CGRectMake(8, 8, 120, 120)];
            
            [qrcodeView setQrcodeNewContentString:content];
            
            [self.myPrinterView addSubview:qrcodeView];
           
            qrcodeView.tag = Remaing + self.myPrinterView.subviews.count;
            
            [self addGestureRecognizerToView:qrcodeView];
            
        }
            break;
        case PDF417:
        {
            
            NSError *error = nil;
            
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            
            ZXBitMatrix* result = [writer encode:content
                                          format:kBarcodeFormatPDF417
                                           width:450
                                          height:150
                                           error:&error];
            
            if (result)
            {
                
                CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
                NSLog(@"%@",image);
                UIImage *imag=[UIImage imageWithCGImage:image];
                MyBarcodeView *barcodeView = [[MyBarcodeView alloc]init];
                barcodeView.frame = CGRectMake(10, 100, 200, 100);
                barcodeView.CodeType = type;
                [barcodeView setMyBarcodeViewWithImage:imag andTittle:content];
                [self.myPrinterView addSubview:barcodeView];
                barcodeView.tag = Remaing + self.myPrinterView.subviews.count;
                [self addGestureRecognizerToView:barcodeView];
             // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
            }
            else
            {
                
                NSString *errorMessage = [error localizedDescription];
                NSLog(@"Error = %@",errorMessage);
                
            }
        
        }
        break;
            
        default:
            
        break;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    //需要添加的代码

}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [self saveChangesToPlistWhenAppToBacgroundOrEndEditing];
  
    [super viewWillDisappear:animated];
    
}

-(NSString *)Chuckawayspace:(NSString *)str
{
    
    NSString * str1 = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * str2 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return str2;
   
}

#pragma mark Some delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(17, 30, 180, 180*(image.size.height/image.size.width))];
    
    imageView.image = image;
    
    imageView.tag = Remaing + self.myPrinterView.subviews.count;

    [self.myPrinterView addSubview:imageView];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addGestureRecognizerToView:imageView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)image:(UIImage *)image didFinishSaveingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error)
    {
    
    NSLog(@"Save  Success !");
        
    }
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
   return UIModalPresentationNone;//不适配(不区分ipad或iPhone)
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
