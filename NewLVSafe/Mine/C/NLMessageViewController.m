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
    if ([self.inType isEqualToString:@"未读"]) {
        dataSource=[NSMutableArray arrayWithArray:self.modelAry];
        [messageTableView reloadData];
    }else{
        [self downLoadData];
    }
}
-(void)cleanMessage{
    if (dataSource.count>0) {
        NSString *userid=userInfo[@"userid"];
        __weak NSMutableArray *aaa=dataSource;
        __weak UITableView *view=messageTableView;
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"清空消息" message:@"消息中可能存在未读预警消息，为了您的车辆安全，请确认后再清空！" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"再看看" style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:cancel];
        UIAlertAction *ok=[UIAlertAction actionWithTitle:@"确认清空" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            [self->manager POST:kDelPushMessageURL parameters:@{@"userid":userid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject) {
                    NSDictionary *res=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
                    if ([res isKindOfClass:[NSDictionary class]]) {
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
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
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
            NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            if ([resInfo isKindOfClass:[NSDictionary class]]) {
                NSArray *resAry=resInfo[@"obj"];
                if (resAry.count>0) {
                    for (NSDictionary*car in resAry) {
                        NLMessageModel *model=[NLMessageModel yy_modelWithDictionary:car] ;
                        
                        [aaa addObject:[DHHleper transNullMessagemodel:model]];
                        
                    }
                    [view reloadData];
                }
                
            }}
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NLMessageModel *model=dataSource[indexPath.row];
    if (model.state.integerValue==0) {
        NSString *title,*mess;
        //  if (state.integerValue==3) {//预报警
        title=@"车辆预警";
        mess=[NSString stringWithFormat:@"\n车牌号:%@\n型号:%@\n颜色:%@\n时间:%@\n\n提醒:车辆位置预警，请确认是否为本人或家人使用",model.licensenum,model.type,model.color,model.pushtime];
        
        //        }else{//车辆找到
        //            title=@"车辆已找到";
        //            mess=[NSString stringWithFormat:@"\n车牌号:%@\n型号:%@\n颜色:%@\n时间:%@\n\n提醒:车辆已找到，请前往\"郑州市中原区西城科技大厦905\"认领您的车辆",model.licensenum,model.type,model.color,model.pushtime];
        //
        //        }
        
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:mess preferredStyle:(UIAlertControllerStyleAlert)];
        UIView *subView1 = alert.view.subviews[0];
        UIView *subView2 = subView1.subviews[0];
        UIView *subView3 = subView2.subviews[0];
        UIView *subView4 = subView3.subviews[0];
        UIView *subView5 = subView4.subviews[0];
        // NSLog(@"%@",subView5.subviews);
        UILabel *messagelabel = subView5.subviews[2];
        messagelabel.textAlignment = NSTextAlignmentLeft;
        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:mess];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[mess rangeOfString:model.licensenum]];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[mess rangeOfString:model.type]];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[mess rangeOfString:model.color]];
        //   [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[mess rangeOfString:@"车辆位置预警，请确认是否为本人或家人使用"]];
        [alert setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        
        //  if (state.integerValue==3) {//预报警
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"取消预警" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [self httprequestWithDic:@{@"url":kCancelCallURL,@"licensenum":model.licensenum,@"type":@"cancel"}];
        }];
        [alert addAction:cancel];
        UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确认报警" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [self httprequestWithDic:@{@"url":kCallpoliceURL,@"licensenum":model.licensenum,@"type":@"call"}];
        }];
        [alert addAction:confirm];
        //        }else{
        //            UIAlertAction *ok=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        //
        //            }];
        //            [alert addAction:ok];
        //        }
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}
-(void)httprequestWithDic:(NSDictionary*)param{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    [MBProgressHUD showMessag:@"报警中···" toView:self.view];
    [manager POST:param[@"url"] parameters:@{@"licensenum":param[@"licensenum"]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            //   NSString *resStr
            if (resInfo) {
                NSString *result=resInfo[@"result"];
                if (result.integerValue==200) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    [self->dataSource removeAllObjects];
                    [self downLoadData];
                    if ([param[@"type"] isEqualToString:@"call"]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"Warning" object:nil];
                        [MBProgressHUD showSuccess:@"您已经报警" toView:nil];
                    }else{
                        [MBProgressHUD showSuccess:@"报警已取消" toView:nil];
                    }
                    
                }
                
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showError:@"数据格式错误" toView:nil];
            }
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器无响应" toView:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"网络错误，请检查网络是否正常" toView:nil];
    }];
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
