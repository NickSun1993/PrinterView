//
//  EditImageViewController.m
//  Gprinter
//
//  Created by  Nick on 2018/2/23.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "EditImageViewController.h"
#import "budleNamesCell.h"
#import "SelectImageCollectionCell.h"

@interface EditImageViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
   
    NSString *_mySelectBudleName;
   
    
    NSArray *_budleNamesArray;
    
    NSArray *_kindNamesArray;
}
@property(nonatomic,strong)NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;



@end

@implementation EditImageViewController

-(NSMutableArray *)dataArray
{
    
    if (!_dataArray) {
        
        _dataArray = [[NSMutableArray alloc]init];
    }
    
    return _dataArray;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _mySelectBudleName = @"Abbreviation";
    
    _budleNamesArray = [NSArray arrayWithObjects:@"Abbreviation",@"Unit",@"Electrical",@"Attention",@"Indication",@"Arrows",@"Life",@"Washing",@"Mark", nil];
    
    _kindNamesArray = [NSArray arrayWithObjects:@"字符",@"数学符号",@"电气符号",@"应急预警",@"指示",@"箭头",@"生活",@"洗标标志",@"其他",nil];
    
    [_tableView registerNib:[UINib nibWithNibName:@"budleNamesCell" bundle:nil] forCellReuseIdentifier:@"budleNamesCell"];
    //得到文件的路径
   
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"SelectImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"SelectImageCollectionCell"];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:_mySelectBudleName ofType:@"bundle"];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator;
    enumerator = [fileManager enumeratorAtPath:path];
    while((path = [enumerator nextObject]) != nil)
    {
        //把得到的图片添加到数组中
        [self.dataArray addObject:path];
    }
    
    
    NSLog(@"dataArray = %@",self.dataArray);
    



}

-(void)ToRestDataarray
{
    [self.dataArray removeAllObjects];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:_mySelectBudleName ofType:@"bundle"];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator;
    enumerator = [fileManager enumeratorAtPath:path];
    while((path = [enumerator nextObject]) != nil)
    {
        //把得到的图片添加到数组中
        [self.dataArray addObject:path];
    }
    [_collectionView reloadData];
    
}

#pragma Mark - UITbaleiewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _kindNamesArray.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    budleNamesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"budleNamesCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.nameLabel.text = _kindNamesArray[indexPath.row];

    if ([_mySelectBudleName isEqualToString:_budleNamesArray[indexPath.row]])
    {
        cell.arrowImageView.hidden = NO;
    }
    else
    {
         cell.arrowImageView.hidden = YES;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _mySelectBudleName = _budleNamesArray[indexPath.row];
    [_tableView reloadData];
    [self ToRestDataarray];
    
}

#pragma Mark- MyCollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.dataArray.count;

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SelectImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectImageCollectionCell" forIndexPath:indexPath];
    
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle/%@",_mySelectBudleName, self.dataArray[indexPath.row]]];
        //根据路径显示图片
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    cell.myImageView.image = image;
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return CGSizeMake((WIDTH-50-130)/4,(WIDTH-50-130)/4);

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake( 10, 10, 10, 10);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle/%@",_mySelectBudleName, self.dataArray[indexPath.row]]];
    //根据路径显示图片
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (_cb) {
        
        _cb(image);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [TABBARSHAREINSTANCE HideMyTabbar];
    [TABBARSHAREINSTANCE setMyNavigationViewWithTopTittle:@"Gprinter" andIsTittleHidden:NO andIsConnectButtonHidden:YES andIsBackOrCancel:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [TABBARSHAREINSTANCE ShowMyTabbar];
    
    
}
- (void)didReceiveMemoryWarning {
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
