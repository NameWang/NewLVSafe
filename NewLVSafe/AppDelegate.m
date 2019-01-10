//
//  AppDelegate.m
//  TimeCouplet
//
//  Created by 何心晓 on 2018/11/8.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import "AppDelegate.h"
#import "NLMapViewController.h"
#import "NLLoginViewController.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import  <UserNotifications/UserNotifications.h>
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  BOOL  isLogin=[[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] boolValue];
    if (isLogin) {
   //   NSDictionary *userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:[[NLMapViewController alloc]init]];
        [self.window setRootViewController:nav];
    }else{
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:[[NLLoginViewController alloc]init]];
        [self.window setRootViewController:nav];
       
    }
   
    // 要使用百度地图，请先启动BaiduMapManager
    BMKMapManager *mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [mapManager start:@"kkPXXo5Ok4aGQSNtG6HchZGpZSjlc6ka"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"bmk manager start failed!");
    }
    if(launchOptions){//appkill时通知处理
        NSDictionary* pushInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if (pushInfo)
        {
            [self showAlertWithNotiInfo:pushInfo];
        }
        
    }
    //注册推送
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        [center setDelegate:self];
        UNAuthorizationOptions type = UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:type completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                
                DLog(@"注册成功");
            }else{
                
                DLog(@"注册失败");
            }
        }];
    } else {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound |UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    // 注册获得device Token
    [application registerForRemoteNotifications];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

// 将得到的deviceToken传给后台
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    DLog(@"deviceTokenStr:\n%@",deviceTokenStr);
    
}
// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    DLog(@"error -- %@",error);
    
}
//1.iOS10以上版本的处理
//在前台
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    BOOL   soundClosed=[[[NSUserDefaults standardUserDefaults] objectForKey:@"soundClosed"] boolValue];
    if(!soundClosed){
        completionHandler(UNNotificationPresentationOptionSound);
    }
    [self showAlertWithNotiInfo:notification.request.content.userInfo];
}
//上面的这个方法，加上completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
//用户即使在前台，收到推送时通知栏也会出现，有声音和角标。如果去掉应用在前台有推送时并不会收到。

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    //这个方法是在用户点击了消息栏的通知，进入app后会来到这里。我们可以业务逻辑。比如跳转到相应的页面等。
    //处理推送过来的数据
    
    //  [self handlePushMessage:response.notification.request.content.userInfo];
    [self showAlertWithNotiInfo:response.notification.request.content.userInfo];
    completionHandler();
    
}
//2.iOS10以下的处理

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary * _Nonnull)userInfo fetchCompletionHandler:(void (^ _Nonnull)(UIBackgroundFetchResult))completionHandler{
    
    /*
     UIApplicationStateActive 应用程序处于前台
     UIApplicationStateBackground 应用程序在后台，用户从通知中心点击消息将程序从后台调至前台
     UIApplicationStateInactive 用用程序处于关闭状态(不在前台也不在后台)，用户通过点击通知中心的消息将客户端从关闭状态调至前台
     */
    
    //应用程序在前台给一个提示特别消息
    if (application.applicationState == UIApplicationStateActive) {
        //应用程序在前台
        //  [self createAlertViewControllerWithPushDict:userInfo];
        [self showAlertWithNotiInfo:userInfo];
        
    }else{  //其他两种情况，一种在后台程序没有被杀死，另一种是在程序已经杀死。用户点击推送的消息进入app的情况处理。
        
        //  [self handlePushMessage:userInfo];
        [self showAlertWithNotiInfo:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}
-(void)showAlertWithNotiInfo:(NSDictionary*)userinfo{
    DLog(@"%@",userinfo);
    NSDictionary *body=[DHHleper  dictionaryWithJsonString:userinfo[@"message"]];
    NSString *state=body[@"status"];
    NSString *title,*mess;
    if (state.integerValue==3) {//预报警
        title=@"车辆预警";
        mess=[NSString stringWithFormat:@"\n车牌号:%@\n型号:%@\n颜色:%@\n时间:%@\n\n提醒:车辆位置预警，请确认是否为本人或家人使用",body[@"licensenum"],body[@"type"],body[@"color"],body[@"pushtime"]];
        
    }else{//车辆找到
        title=@"车辆已找到";
        mess=[NSString stringWithFormat:@"\n车牌号:%@\n型号:%@\n颜色:%@\n时间:%@\n\n提醒:车辆已找到，请前往\"郑州市中原区西城科技大厦905\"认领您的车辆",body[@"licensenum"],body[@"type"],body[@"color"],body[@"pushtime"]];
        
    }
    
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
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[mess rangeOfString:body[@"licensenum"]]];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[mess rangeOfString:body[@"type"]]];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[mess rangeOfString:body[@"color"]]];
    //   [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[mess rangeOfString:@"车辆位置预警，请确认是否为本人或家人使用"]];
    [alert setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    if (state.integerValue==3) {//预报警
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"取消预警" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }];
        [alert addAction:cancel];
        UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确认报警" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [self httprequestWithDic:@{@"licensenum":body[@"licensenum"]}];
        }];
        [alert addAction:confirm];
    }else{
        UIAlertAction *ok=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:ok];
    }
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}
-(void)httprequestWithDic:(NSDictionary*)param{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    [MBProgressHUD showMessag:@"报警中···" toView:self.window.rootViewController.view];
    [manager POST:kCallpoliceURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            //   NSString *resStr
            if (resInfo) {
                NSString *result=resInfo[@"result"];
                if (result.integerValue==200) {
                    [MBProgressHUD hideHUDForView:self.window.rootViewController.view animated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Warning" object:nil];
                    [MBProgressHUD showSuccess:@"您已经报警" toView:nil];
                }
                
            }else{
                [MBProgressHUD hideHUDForView:self.window.rootViewController.view animated:YES];
                [MBProgressHUD showError:@"数据格式错误" toView:nil];
            }
        }else{
            [MBProgressHUD hideHUDForView:self.window.rootViewController.view animated:YES];
            [MBProgressHUD showError:@"服务器无响应" toView:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.window.rootViewController.view animated:YES];
        [MBProgressHUD showError:@"网络错误，请检查网络是否正常" toView:nil];
    }];
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"endtime"];
}

-(void)applicationWillEnterForeground:(UIApplication *)application{
    NSDate *now=[NSDate date];
    NSDate *end=[[NSUserDefaults standardUserDefaults] objectForKey:@"endtime"];
    if (end) {
        NSTimeInterval interval=[now timeIntervalSinceDate:end];
        if (interval>30) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Reactive" object:nil];
        }
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
