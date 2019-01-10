//
//  PSMessageViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLMessageViewController.h"
#import "NLMessageModel.h"
#import "NLMessageTableViewCell.h"

@interface NLMessageViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *messageTableView;
    NSMutableArray *dataSource;
    NSDictionary *userInfo;
    AFHTTPSessionManager *manager;
}
@end

@implementation NLMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"消息管理";
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc] initWithTitle:@"清空消息" style:(UIBarButtonItemStylePlain) target:self action:@selector(cleanMessage)];
    [rightBtn setTitleTextAttributes:@{  //1.设置字体样式:例如黑体,和字体大小
                                       NSFontAttributeName:[UIFont systemFontOfSize:14],
                                       //2.字体颜色
                                       NSForegroundColorAttributeName:[UIColor whiteColor]} forState:(UIControlStateNormal)];
    self.navigationItem.rightBarButtonItem=rightBtn;
    userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    dataSource=[NSMutableArray array];
    manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    [self initTableView];
    [self downLoadData];
}
-(void)cleanMessage{
    if (dataSource.count>0) {
        
        NSString *userid=userInfo[@"userid"];
        __weak NSMutableArray *aaa=dataSource;
        __weak UITableView *view=messageTableView;
        
        [manager POST:kDelPushMessageURL parameters:@{@"userid":userid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                NSDictionary *res=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
                if (res) {
                    NSString *result=res[@"result"];
                    if (result.integerValue==200) {
                        [aaa removeAllObjects];
                        [view reloadData];
                    }else{
                        [MBProgressHUD showError:@"清空失败!" toView:nil];
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
    }
}
-(void)initTableView{
    messageTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kiPhoneX_Top_Height) style:(UITableViewStylePlain)];
    [messageTableView registerNib:[UINib nibWithNibName:@"NLMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"NLMessageTableViewCell"];
    messageTableView.backgroundColor=kBGWhiteColor;
    [messageTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    messageTableView.delegate=self;
    messageTableView.dataSource=self;
    
    messageTableView.tableFooterView=[[UIView alloc] init];
    [self.view addSubview:messageTableView];
}
#pragma mark 下载数据
-(void)downLoadData{
    
    NSString *userid=userInfo[@"userid"];
    __weak NSMutableArray *aaa=dataSource;
    __weak UITableView *view=messageTableView;
    
    [manager GET:kGetPushMessageURL parameters:@{@"userid":userid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSArray *resAry=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            if (resAry.count>0) {
                
                for (NSDictionary*car in resAry) {
                    NLMessageModel *model=[NLMessageModel yy_modelWithDictionary:car] ;
                    
                    [aaa addObject:model];
                    
                }
                [view reloadData];
            }else{
                
                //     [MBProgressHUD showError:@"数据格式错误" toView:nil];
            }
        }else{
            
            [MBProgressHUD showError:@"服务器无响应" toView:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD showError:@"网络错误，请检查网络是否正常" toView:nil];
    }];
    
}
#pragma mark tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    if (dataSource.count>0) {
        NLMessageModel *model=dataSource[indexPath.row];
        NLMessageTableViewCell *mecell=[tableView dequeueReusableCellWithIdentifier:@"NLMessageTableViewCell" forIndexPath:indexPath];
        [mecell showDataWithModel:model];
        cell=mecell;
    }else{
        UITableViewCell *nocell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
        nocell.textLabel.text=@"暂无消息";
        nocell.textLabel.textColor=[UIColor grayColor];
        nocell.backgroundColor=kBGWhiteColor;
        nocell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell=nocell;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (dataSource.count>0) {
        NLMessageModel *model=dataSource[indexPath.row];
        CGFloat height=[DHHleper textHeightFromTextString:model.content width:kScreenWidth-65 fontSize:15];
        return height+35;
    }else{
        return 60;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dataSource.count>0) {
        return dataSource.count;
    }else{
        return 1;
    }
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
