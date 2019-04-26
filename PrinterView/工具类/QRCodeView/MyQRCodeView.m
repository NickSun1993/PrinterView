//
//  MyQRCodeView.m
//  Gprinter
//
//  Created by  Nick on 2018/3/8.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "MyQRCodeView.h"
#import "ZXingObjC.h"

@implementation MyQRCodeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // 注意：该处不要给子控件设置frame与数据，可以在这里初始化子控件的属性
        UIImageView *iconImageView = [[UIImageView alloc] init];
        self.QRcodeImageView = iconImageView;
        [self addSubview:iconImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.QRcodeImageView.frame = CGRectMake(0, 0, self.frame.size.width , self.frame.size.height);

}

-(void)setQrcodeNewContentString:(NSString*)NewString
{
    NSError *error = [[NSError alloc]init];
    
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:NewString
                                  format:kBarcodeFormatQRCode
                                   width:250
                                  height:250
                                   error:&error];
    if (result) {
        _contentString = NewString;
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage ];
        NSLog(@"%@",image);
        UIImage *imag=[UIImage imageWithCGImage:image];
        self.QRcodeImageView.image = imag;
        
        
    }
        
    
    
}

@end
