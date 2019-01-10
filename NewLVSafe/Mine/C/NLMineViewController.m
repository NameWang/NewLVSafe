//
//  NLMineViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/22.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLMineViewController.h"
#import "NLMineTableViewCell.h"
#import "NLLoginViewController.h"
#import "NLAboutUsViewController.h"
#import "NLSetupViewController.h"
#import "NLMessageViewController.h"
#import "UserInfoViewController.h"
#import "YSPhotoPicker.h"
#import "NLFeedBackViewController.h"
#import "NLMapViewController.h"

@interface NLMineViewController ()<UITableViewDelegate,UITableViewDataSource,YSPhotoPickerDelegate>
{
   
    UITableView *mineTableView;
    NSMutableArray *dataSource;
    NSMutableArray *titleAry;
    UIButton *quitBtn;
    UIView *topView;
    AvtionImageView *iconImgView;
    UILabel *contentLabel,*nameLabel;
    NSDictionary *userInfo;
    CGFloat width;
     YSPhotoPicker *photoPicker;
}

@end

@implementation NLMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title=@"我的";
    // self.navigationController.navigationBar.hidden=YES;
     [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor=kBGWhiteColor;
    width = [UIScreen mainScreen].bounds.size.width - 50;
    if ([UIScreen mainScreen].bounds.size.width > 375) {
        width -= 50;
    } else if ([UIScreen mainScreen].bounds.size.width > 320) {
        width = width - 25;
    }
   userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
  
    dataSource=[NSMutableArray arrayWithObjects:@"\U0000e60d",@"\U0000e65f",@"\U0000e63d",@"\U0000e639", nil];
    titleAry=[NSMutableArray arrayWithObjects:@"个人信息",@"关于我们",@"帮助与反馈",@"设置", nil];
    [self initTopView];
    
}
-(void)initTopView{
    CGFloat height=60+80+70+kiPhoneX_Top_Height;
    topView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
   topView.backgroundColor=kBGWhiteColor;
    [self.view addSubview:topView];
    iconImgView=[[AvtionImageView alloc] initWithFrame:CGRectMake(width/2-40, 60, 80, 80)];
    //绘制曲线路径
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:iconImgView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(40, 40)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    //设置大小
    maskLayer.frame = iconImgView.bounds;
    //设置图形样子
    maskLayer.path = maskPath.CGPath;
    iconImgView.layer.mask = maskLayer;
    [iconImgView addTarget:self action:@selector(changeClick)];
    
    iconImgView.image=[UIImage imageNamed:@"iconPlace"];
    
    [topView addSubview:iconImgView];
    nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, width, 25)];
    nameLabel.text=userInfo[@"uname"];
      nameLabel.font=[UIFont systemFontOfSize:15];
    nameLabel.textAlignment=NSTextAlignmentCenter;
    [topView addSubview:nameLabel];
    
    contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame), width, 25)];
    contentLabel.textColor=[UIColor grayColor];
    contentLabel.textAlignment=NSTextAlignmentCenter;
    contentLabel.font=[UIFont systemFontOfSize:13];
    contentLabel.text=userInfo[@"sign"];
       [topView addSubview:contentLabel];
    
  
    [self initTableView] ;
    
}
//换头像事件
-(void)changeClick{
    photoPicker = [[YSPhotoPicker alloc] initWithViewController:self];
    photoPicker.delegate = self;
    
    [photoPicker showPickerChoice];
    
}
-(void)initTableView{
    mineTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame)+2, width, 44*4*kScale) style:(UITableViewStylePlain)];
    [mineTableView registerNib:[UINib nibWithNibName:@"NLMineTableViewCell" bundle:nil] forCellReuseIdentifier:@"NLMineTableViewCell"];
  
    
    mineTableView.delegate=self;
    mineTableView.dataSource=self;
    mineTableView.tableFooterView=[[UIView alloc] init];
    [self.view addSubview:mineTableView];
    quitBtn=[UIButton normalBtnWithFrame:CGRectMake(10, CGRectGetMaxY(mineTableView.frame)+20, width-20, 30*kScale) title:@"退出登录" size:15 color:[UIColor whiteColor] superView:self.view];
    quitBtn.backgroundColor=kBlueColor;
    [quitBtn addTarget:self action:@selector(quitClick) forControlEvents:(UIControlEventTouchUpInside)];
}
-(void)quitClick{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isLogin"];
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Close" object:nil];
 
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:[[NLLoginViewController alloc]init]];
    
    [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
}
#pragma mark tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    
        NLMineTableViewCell *nocell=[tableView dequeueReusableCellWithIdentifier:@"NLMineTableViewCell" forIndexPath:indexPath];
    nocell.iconLabel.text=dataSource[indexPath.row];
    nocell.bodyLabel.text=titleAry[indexPath.row];
        cell=nocell;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            {
               
                    UserInfoViewController *info=[[UserInfoViewController alloc] init];
                info.callBackBlock = ^{
                    
                };
                    [self.navigationController pushViewController:info animated:YES];
                    
                
            }
            break;
        case 2:
        {
            
            NLFeedBackViewController *info=[[NLFeedBackViewController alloc] init];
            info.callBackBlock = ^{
                
            };
            [self.navigationController pushViewController:info animated:YES];
            
            
        }
            break;
        case 3:{
           
            NLSetupViewController *us=[[NLSetupViewController alloc] init];
       
            us.callBackBlock = ^{
             
            };
            [self.navigationController pushViewController:us animated:YES];
            
        }break;
        case 1:{
            
            NLAboutUsViewController *us=[[NLAboutUsViewController alloc] init];
            us.callBackBlock = ^{
              //  self.navigationController.navigationBar.hidden=YES;
            };
            [self.navigationController pushViewController:us animated:YES];
           
        }break;
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44*kScale;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return dataSource.count;
   
}
- (void)imagePickerController:(UIImagePickerController *)picker didSelectImage:(UIImage *)image
{
    if (image)
    {
        //  [self.userDataHandler uploadHeadImage:image];
        __weak AvtionImageView *imgv=iconImgView;
        __weak NSDictionary *info=userInfo;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *dict = @{@"id" : info[@"id"]};
            
            AFHTTPSessionManager *s_manager = [AFHTTPSessionManager manager];
            s_manager.responseSerializer=[AFHTTPResponseSerializer serializer];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            [s_manager POST:kUploadICONURl parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:imageData name:@"file" fileName:@"picFile.jpg" mimeType:@"image/png"];
            } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject) {
                    NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
                    if (resInfo) {
                        NSString *states=resInfo[@"result"];
                        if (states.integerValue==200) {
                            [MBProgressHUD showSuccess:@"头像修改成功!"];
                            NSMutableDictionary *resddd=[NSMutableDictionary dictionaryWithDictionary:info];
                            [resddd setValue:resInfo[@"fileName"] forKey:@"headimgurl"];
                            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:resddd] forKey:@"UserInfo"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                imgv.image=image;
                                
                            });
                        }else{
                            [MBProgressHUD showError:@"上传失败!" toView:nil];
                        }
                        
                    }else{
                        
                        [MBProgressHUD showError:@"数据格式错误" toView:nil];
                    }
                    
                }else{
                    [MBProgressHUD showError:@"服务器无响应" toView:nil];
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [MBProgressHUD showError:@"网络错误，请检查网络是否正常" toView:nil];
            }];
            
        });
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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
