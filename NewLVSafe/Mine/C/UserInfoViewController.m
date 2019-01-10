//
//  NLUserInfoViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "UserInfoViewController.h"
#import "NLUserInfoTableViewCell.h"

#import "NLChangeInfoViewController.h"
#import "NLChangePWDViewController.h"

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    UITableView *userInfoTableView;
    NSMutableArray *dataSource;
    NSMutableArray *titleAry;
    BOOL isLogin;
    AvtionImageView *topImgView;
    AvtionImageView *iconImgView;
    UIButton *loginAndNameBtn,*backBtn;
    
    NSDictionary *userInfo;
}


@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"个人信息";
   
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    dataSource=[NSMutableArray arrayWithObjects:@"手机号",@"身份证",@"姓名",@"签名",@"家庭住址",@"家庭电话",@"修改密码", nil];
    isLogin=[[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] boolValue];
    if (isLogin) {
        userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
        titleAry=[NSMutableArray arrayWithObjects:userInfo[@"phone"],userInfo[@"idcardno"],userInfo[@"sname"], nil];
    }
    
    [self initTableView] ;
    
}

-(void)initTableView{
    userInfoTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topImgView.frame)+2, kScreenWidth, kScreenHeight-topImgView.frame.size.height+20) style:(UITableViewStylePlain)];
    [userInfoTableView registerNib:[UINib nibWithNibName:@"NLUserInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"NLUserInfoTableViewCell"];
    
    
    userInfoTableView.delegate=self;
    userInfoTableView.dataSource=self;
    userInfoTableView.tableFooterView=[[UIView alloc] init];
    [self.view addSubview:userInfoTableView];
}
#pragma mark tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    
    NLUserInfoTableViewCell *nocell=[tableView dequeueReusableCellWithIdentifier:@"NLUserInfoTableViewCell" forIndexPath:indexPath];
    nocell.titLabel.text=dataSource[indexPath.row];
    switch (indexPath.row) {
        case 0:case 1:case 2:
        {
            nocell.accessoryType=UITableViewCellAccessoryNone;
        }
            break;
            
        default:
            break;
    }
    cell=nocell;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44*kScale;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NLChangeInfoViewController *change=[[NLChangeInfoViewController alloc] init];
   
    change.callBackBlock = ^{
        
    };
    switch (indexPath.row) {
        case 3:
        {
            change.type=@"签名";
            
            [self.navigationController pushViewController:change animated:YES];
        }
            break;
        case 4:{
            change.type=@"家庭住址";
            
            [self.navigationController pushViewController:change animated:YES];
        }break;
        case 5:{
            change.type=@"家庭电话";
            
            [self.navigationController pushViewController:change animated:YES];
        }break;
        case 6:{
            NLChangePWDViewController *pwd=[[NLChangePWDViewController alloc] init];
            pwd.callBackBlock = ^{
                
            };
            [self.navigationController pushViewController:pwd animated:YES];
        }break;
        default:
            break;
    }
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return dataSource.count;
    
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
