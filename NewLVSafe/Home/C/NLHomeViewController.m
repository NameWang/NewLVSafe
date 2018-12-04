//
//  NLHomeViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/22.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLHomeViewController.h"
#import "NLHomeCarTableViewCell.h"
#import "NLLoginViewController.h"
#import "NLHomeNoLoginTableViewCell.h"
#import "NLHomeCarModel.h"
#import "NLFindCarViewController.h"
#import "NLMapViewController.h"


@interface NLHomeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIScrollView *homeBGScrollow;
    UITableView *carListTableView;
    NSMutableArray *dataSource;
    BOOL isLogin;
    NSDictionary *userInfo;
    AFHTTPSessionManager *manager;
}
@end

@implementation NLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title=@"首页";
    homeBGScrollow=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    homeBGScrollow.contentSize=CGSizeMake(0, kScreenHeight+50);
    homeBGScrollow.backgroundColor=kBGWhiteColor;
    [self.view addSubview:homeBGScrollow];
    manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    isLogin=YES;
    [self initTopView];
    [self downLoadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLogin) name:@"Login" object:nil];
  
}


-(void)receiveLogin{
  
}
#pragma mark 下载数据
-(void)downLoadData{
    [manager GET:@"http://192.168.124.6:8181/electrocarmanage/user/phone" parameters:@{@"phone":@"15836670248"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *ddd=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (ddd) {
                DLog(@"数据返回:%@",ddd);
            }else{
                    DLog(@"数据返回但格式不对");
                NSString *str=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (str) {
                    DLog(@"数据:\n%@",str);
                }
            }
        }else{
            DLog(@"无数据返回");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"请求失败:\n%@",error.domain);
    }];
}
#pragma mark 视图初始化
-(void)initTopView{
    //广告视图
    UIImageView *adImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -(20+kiPhoneX_Top_Height), kScreenWidth, 0.6*kScreenWidth)];
    adImgView.image=[UIImage imageNamed:@"ad"];
    [homeBGScrollow addSubview:adImgView];
  
    //车辆列表
    carListTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(adImgView.frame)+2, kScreenWidth, kScreenHeight-kiPhoneX_Bottom_Height-44) style:(UITableViewStylePlain)];
    [carListTableView registerNib:[UINib nibWithNibName:@"NLHomeCarTableViewCell" bundle:nil] forCellReuseIdentifier:@"NLHomeCarTableViewCell"];
     [carListTableView registerNib:[UINib nibWithNibName:@"NLHomeNoLoginTableViewCell" bundle:nil] forCellReuseIdentifier:@"NLHomeNoLoginTableViewCell"];
    
    carListTableView.delegate=self;
    carListTableView.dataSource=self;
    //底部脚视图
    UIView *footView=[[UIView alloc] init];
    
    carListTableView.tableFooterView=footView;
    [homeBGScrollow addSubview:carListTableView];
    //
    dataSource=[NSMutableArray array];
   
}


#pragma mark tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    if (isLogin) {
         NLHomeCarTableViewCell *carcell=[tableView dequeueReusableCellWithIdentifier:@"NLHomeCarTableViewCell" forIndexPath:indexPath];
        if (dataSource.count>0) {
            NLHomeCarModel *model=dataSource[indexPath.row];
          
            [carcell showDataWithModel:model trailBlock:^{
                   self.hidesBottomBarWhenPushed=YES;
                NLMapViewController *map=[[NLMapViewController alloc] init];
                map.carNum=model.licenseNum;
                map.callBackBlock = ^{
                  
                };
                [self.navigationController pushViewController:map animated:YES];
                 self.hidesBottomBarWhenPushed=NO;
            } lockCarBlock:^{
                
            }];
            cell=carcell;
        }else{
            NLHomeCarModel *model=[[NLHomeCarModel alloc] init];
            model.licenseNum=@"豫A12345";
            model.brand=@"法拉利";
            model.picPath=@"http://cc.cocimg.com/api/uploads/181018/739edb962e633691b323b105fbe3fe6b.jpg";
            model.state=@"未锁";
            [carcell showDataWithModel:model trailBlock:^{
                self.hidesBottomBarWhenPushed=YES;
                NLMapViewController *map=[[NLMapViewController alloc] init];
                map.carNum=model.licenseNum;
                map.callBackBlock = ^{
                   
                };
                [self.navigationController pushViewController:map animated:YES];
                self.hidesBottomBarWhenPushed=NO;
            } lockCarBlock:^{
                
            }];
            cell=carcell;
        }
    }else{
        NLHomeNoLoginTableViewCell *nocell=[tableView dequeueReusableCellWithIdentifier:@"NLHomeNoLoginTableViewCell" forIndexPath:indexPath];
       
        [nocell tapLoginWithBlock:^{
            self.hidesBottomBarWhenPushed=YES;
            NLLoginViewController *login=[[NLLoginViewController alloc] init];
            [self.navigationController pushViewController:login animated:YES];
            self.hidesBottomBarWhenPushed=NO;
        }];
        cell=nocell;
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isLogin) {
        if (dataSource.count>0) {
            return dataSource.count;
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
-(void)dealloc{
    DLog(@"首页释放");
}

@end
