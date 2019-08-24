//
//  NLMapViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/24.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLMapViewController.h"
#import <BMKLocationKit/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "RouteAnnotation.h"

#import "NLCarLocationInfoModel.h"
#import "NLCarLocationTableViewCell.h"
#import "KKSliderMenuTool.h"
#import "NLMineViewController.h"
#import "CarCollectionViewCell.h"
#import "NLHomeCarModel.h"
#import "NLCallPoliceViewController.h"
#import "NLMessageViewController.h"
#import "NLMessageModel.h"

@interface NLMapViewController ()<BMKLocationManagerDelegate, BMKGeoCodeSearchDelegate, BMKMapViewDelegate, BMKRouteSearchDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

{
    BMKMapView *mapView;
    UIButton *userBtn,*carBtn,*notiBtn,*listBtn;
    UILabel *numLabel;
    UIButton *timeBtn,*okBtn,*cancelBtn,*lockBtn;
    UIView *dateBGView,*bgView,*safeView;
    UIDatePicker *datePicker;
    BOOL isMapView,isShow,isLogin;
    int  planPointCounts;
    AFHTTPSessionManager *manager;
    NSDictionary *userInfo;
}
@property (nonatomic, assign) int dataIndex;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)NSMutableArray *messageSource;
@property(nonatomic,strong)UICollectionView *homeCollectionView;
@property (nonatomic, assign) BOOL haveTrail;
@property (nonatomic, strong) BMKLocationManager *locationManager;
@property (nonatomic, strong) BMKRouteSearch* routesearch;          ///算路搜索，进入步行导航前，把算路路线展示在地图上
@property(nonatomic,strong)NSMutableArray *carLocationModelArray; //车辆位置信息数组
@property(nonatomic,strong)NSMutableArray *carAnnotionArray; //车辆大头针数组
@property(nonatomic,strong)NSMutableArray *tableDataSoure; //
@property(nonatomic ,strong)UITableView  *locationTableView;
@property (nonatomic, strong) NLHomeCarModel* currentCarModel; //当前显示车辆
@property (nonatomic, strong) BMKUserLocation *currentLocation;     ///当前位置信息，作为起点
@end

@implementation NLMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden=YES;
    planPointCounts=0;
    self.dataIndex=1;
    isShow=NO;
    manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    isLogin=[[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] boolValue];
    if (isLogin) {
        userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    
    }
    self.view.backgroundColor=kBGWhiteColor;
    
  [self initMapView];
    [self stopPopGestureRecognizer];
  
   [self initLocationTableView];
#pragma mark 头部导航栏
    bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 22+kiPhoneX_Top_Height, kScreenWidth, 44)];
    bgView.backgroundColor=[UIColor whiteColor];
    [mapView addSubview:bgView];
    userBtn=[UIButton iconButtonWithFrame:CGRectMake(15, 7, 30, 30) title:@"\U0000e61a" size:25 color:[UIColor grayColor]  superView:bgView];
    [userBtn addTarget:self action:@selector(userClick) forControlEvents:(UIControlEventTouchUpInside)];
     carBtn=[UIButton iconButtonWithFrame:CGRectMake(60, 7, 30, 30) title:@"\U0000e8c5" size:25 color:[UIColor grayColor]  superView:bgView];
    [carBtn addTarget:self action:@selector(carlistClick) forControlEvents:(UIControlEventTouchUpInside)];
   notiBtn=[UIButton iconButtonWithFrame:CGRectMake(kScreenWidth-90, 7, 30, 30) title:@"\U0000e629" size:25 color:[UIColor grayColor]  superView:bgView];
    [notiBtn addTarget:self action:@selector(notiBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
   listBtn=[UIButton normalBtnWithFrame:CGRectMake(kScreenWidth-45, 7, 40, 30) title:@"列表" size:15 color:[UIColor grayColor]  superView:bgView];
     [listBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
   // areaBtn=[UIButton normalBtnWithFrame:CGRectMake(80, 7, kScreenWidth-160, 30) title:@"豫A123451" size:14 color:[UIColor grayColor]  superView:bgView];
    numLabel=[[UILabel alloc] initWithFrame:CGRectMake(95, 7, kScreenWidth-80-120, 30)];
    numLabel.textColor=[UIColor grayColor];
    numLabel.text=@"";
    numLabel.font=[UIFont systemFontOfSize:13];
    if (kScreenWidth>374) {
        numLabel.font=[UIFont systemFontOfSize:16];
    }
    [bgView addSubview:numLabel];

 #pragma mark 日期
     NSString *timeStr=[DHHleper getLocalDate];
    timeBtn=[UIButton oneIconFontBtnWithFirst:timeStr second:@"\U0000e69b" titleColor:[UIColor grayColor] size1:14 size2:14 frame:CGRectMake(0,CGRectGetMaxY(bgView.frame)+2, 120, 35) superView:mapView];
    timeBtn.backgroundColor=[UIColor whiteColor];
    [timeBtn addTarget:self action:@selector(chooseTime) forControlEvents:(UIControlEventTouchUpInside)];
#pragma mark 日期选择
    dateBGView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-225-kiPhoneX_Bottom_Height, kScreenWidth, 225)];
    dateBGView.backgroundColor=kBGWhiteColor;
    cancelBtn=[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 20)];
    [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancelBtn setTitleColor:kBlueColor forState:(UIControlStateNormal)];
    [cancelBtn addTarget:self action:@selector(cancelChoose) forControlEvents:(UIControlEventTouchUpInside)];
    [dateBGView addSubview:cancelBtn];
    okBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 5, 40, 20)];
    [okBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [okBtn setTitleColor:kBlueColor forState:(UIControlStateNormal)];
    [okBtn addTarget:self action:@selector(confimChoose) forControlEvents:(UIControlEventTouchUpInside)];
    [dateBGView addSubview:okBtn];
    datePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 25, kScreenWidth, 200)];
    datePicker.datePickerMode=UIDatePickerModeDate;
    datePicker.maximumDate=[NSDate date];
    [datePicker setDate:[NSDate date] animated:YES];
    datePicker.locale= [NSLocale localeWithLocaleIdentifier:@"zh"];
    [dateBGView addSubview:datePicker];
  #pragma mark 锁车状态
    NSString *iconStr,*nameStr;
    UIColor *stateColor;
    if ([self.currentCarModel.state isEqualToString:@"0"]) {
        iconStr=@"\U0000e661";
        nameStr=@"未锁";
        stateColor= [UIColor colorWithRed:50.0/255.0 green:205.0/255.0 blue:50/255.0 alpha:1];
    }else if([self.currentCarModel.state isEqualToString:@"4"]){
        iconStr=@"\U0000e640";
        nameStr=@"报警";
        stateColor=[UIColor redColor];
    }else{
        iconStr=@"\U0000e657";
        nameStr=@"已锁";
        stateColor=[UIColor redColor];
    }
   
    lockBtn=[UIButton secondIconFontBtnWithFirst:iconStr second:nameStr titleColor:stateColor size1:45 size2:14 frame:CGRectMake(kScreenWidth-85, kScreenHeight-kiPhoneX_Bottom_Height-100, 80, 80) superView:mapView];
  
    lockBtn.layer.masksToBounds=YES;
    [lockBtn addTarget:self action:@selector(lockClick) forControlEvents:(UIControlEventTouchUpInside)];
    lockBtn.layer.cornerRadius=30;
  
#pragma mark 地图数组
    CLLocation *loca=[[CLLocation alloc] initWithLatitude:+34.81781978 longitude:+113.57227160];
    self.currentLocation=[[BMKUserLocation alloc] init];
    self.currentLocation.location=loca;
    self.haveTrail=NO;
  //  [self initMapView];
      [self initcarCollectionView];
    self.carLocationModelArray=[NSMutableArray array];
    self.carAnnotionArray=[NSMutableArray array];
    self.dataSource=[NSMutableArray array];
      self.tableDataSoure=[NSMutableArray array];
     self.messageSource=[[NSMutableArray alloc] init];
  
  //  [self downLoadMapDataWithDate:[DHHleper getLocalDate]];
 
 //     [self downLoadTableViewDataWithDate:[DHHleper getLocalDate] index:self.dataIndex];
       [self downLoadCarData];
    isMapView=YES;
    BOOL   isPush=[[[NSUserDefaults standardUserDefaults] objectForKey:@"actForPush"] boolValue];
    if (!isPush) {
        [self.messageSource removeAllObjects];
        [self downMessageData];
    }
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;// 屏幕左侧边缘响应
    [self.view addGestureRecognizer:leftEdgeGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Reactive) name:@"Reactive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(warning) name:@"Warning" object:nil];
}
-(void)warning{
    isLogin=[[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] boolValue];
    if (isLogin) {
        userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
        [self.dataSource removeAllObjects];
        [self.messageSource removeAllObjects];
        [self downLoadCarData];
    }
}
-(void)Reactive{
    isLogin=[[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] boolValue];
    if (isLogin) {
        userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
        [self.dataSource removeAllObjects];
        [self.tableDataSoure removeAllObjects];
        [self downLoadCarData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         //   [self downLoadMapDataWithDate:[DHHleper getLocalDate]];
         //   [self downLoadTableViewDataWithDate:[DHHleper getLocalDate] index:0];
            BOOL   isPush=[[[NSUserDefaults standardUserDefaults] objectForKey:@"actForPush"] boolValue];
            if (!isPush) {
                [self.messageSource removeAllObjects];
                [self downMessageData];
            }
        });
      
    }
    
}
#pragma mark 下载消息数据
-(void)downMessageData{
    NSString *userid=userInfo[@"userid"];
    
    [manager GET:kGetPushMessageURL parameters:@{@"userid":userid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            if ([resInfo isKindOfClass:[NSDictionary class]]) {
                
                NSString *resStr=resInfo[@"msg"];
                if ([resStr isEqualToString:@"yes"]) {
                    NSArray *resAry=resInfo[@"obj"];
                    if (resAry.count>0) {
                        for (NSDictionary*car in resAry) {
                            NLMessageModel *model=[NLMessageModel yy_modelWithDictionary:car] ;
                            
                            [self.messageSource addObject:[DHHleper transNullMessagemodel:model]];
                            
                        }
                        self.hidesBottomBarWhenPushed=YES;
                        NLMessageViewController *mess=[[NLMessageViewController alloc] init];
                        mess.inType=@"未读";
                        mess.modelAry=self.messageSource;
                        
                        mess.callBackBlock = ^{
                            
                        };
                        [self.navigationController pushViewController:mess animated:YES];
                        self.hidesBottomBarWhenPushed=NO;
                    }
                }
            }}
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void)moveViewWithGesture:(UIPanGestureRecognizer *)panGes {
    if (panGes.state == UIGestureRecognizerStateEnded) {
        [KKSliderMenuTool showWithRootViewController:self contentViewController:[[NLMineViewController alloc] init]];
    }
}
-(void)userClick{
      [KKSliderMenuTool showWithRootViewController:self contentViewController:[[NLMineViewController alloc] init]];
}
#pragma mark 重置锁车按钮状态
-(void)resetLockBtnTitle{
    NSString *iconStr,*nameStr;
    UIColor *stateColor;
    if ([self.currentCarModel.state isEqualToString:@"0"]) {
        iconStr=@"\U0000e661";
        nameStr=@"未锁";
        stateColor= [UIColor colorWithRed:50.0/255.0 green:205.0/255.0 blue:50/255.0 alpha:1];
    }else if([self.currentCarModel.state isEqualToString:@"4"]){
        iconStr=@"\U0000e640";
        nameStr=@"报警";
        stateColor=[UIColor redColor];
    }else{
        iconStr=@"\U0000e657";
        nameStr=@"已锁";
        stateColor=[UIColor redColor];
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",iconStr,nameStr]];
    NSRange range1 = [[str string] rangeOfString:iconStr];
    NSRange range2 = [[str string] rangeOfString:nameStr];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:14] range:range2];
    
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"iconfont" size:45] range:range1];
    [str addAttribute:NSForegroundColorAttributeName value:stateColor range:range2];
    [str addAttribute:NSForegroundColorAttributeName value:stateColor range:range1];
    [self->lockBtn setAttributedTitle:str forState:(UIControlStateNormal)];
    self->lockBtn.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
    
    self->lockBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    
}
#pragma mark 锁车解锁事件
-(void)lockClick{
    if(self.currentCarModel.state.integerValue!=4) {
        [MBProgressHUD showMessag:@"修改中···" toView:self.view];
        NSString *state=self.currentCarModel.state;
        [manager POST:kLockAUnlockCarURL parameters:@{@"electrocarId":self.currentCarModel.id,@"state":state} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
                if (resInfo) {
                    NSString *result=resInfo[@"result"];
                    if (result.integerValue==200) {
                        NLHomeCarModel *resModel=self.currentCarModel;
                        if (state.integerValue==1) {
                            resModel.state=@"0";
                        }else{
                            resModel.state=@"1";
                        }
                        self.currentCarModel=resModel;
                        [self resetLockBtnTitle];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }else{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    }else{
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"取消报警" message:@"车辆已找到，取消报警？" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"未找到" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:cancel];
        UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self->manager POST:kCancelpoliceURL parameters:@{@"licensenum":self.currentCarModel.licensenum} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject) {
                    NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
                    if (resInfo) {
                        NSString *result=resInfo[@"result"];
                        if (result.integerValue==200) {
                            [self.dataSource removeAllObjects];
                            [self downLoadCarData];
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
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark 下载车辆列表
-(void)downLoadCarData{
    
    NSString *phone=userInfo[@"phone"];
   // __weak typeof(self)weakself=self;
    __weak UILabel *label=numLabel;
  
    [manager GET:kGetMyCarListURL parameters:@{@"phone":phone} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            if (resInfo) {
                NSArray *carInfos=resInfo[@"list"];
                if (carInfos.count>0) {
                    [self.dataSource removeAllObjects];
                    for (int i=0;i<carInfos.count;i++) {
                    NSDictionary*car=carInfos[i];
                    NLHomeCarModel *model=[NLHomeCarModel yy_modelWithDictionary:car] ;
                    
                    [self.dataSource addObject:model];
                    if (i==0) {
                        label.text=model.licensenum;
                        self.currentCarModel=model;
                        [self resetLockBtnTitle];
                    }
                }
                   
                    [self.homeCollectionView reloadData];
                     [self downLoadMapDataWithDate:[DHHleper getLocalDate]];
                     [self downLoadTableViewDataWithDate:[DHHleper getLocalDate] index:self.dataIndex];
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
#pragma mark 车辆瀑布流
-(void)carlistClick{
    if (isShow) {
        [self hideCollect];
    }else{
        isShow=YES;
        [carBtn setTitleColor:kBlueColor forState:(UIControlStateNormal)];
        [self.homeCollectionView setHidden:NO];
    }
}
-(void)hideCollect{
    isShow=NO;
    [carBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    [self.homeCollectionView setHidden:YES];
    [self downLoadMapDataWithDate:[DHHleper getLocalDate]];
    self.dataIndex=1;
    [self.tableDataSoure removeAllObjects];
     [self.locationTableView reloadData];
    [self downLoadTableViewDataWithDate:[DHHleper getLocalDate] index:self.dataIndex];
}
-(void)initcarCollectionView{
    //
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    //设置行间距
    flowLayout.minimumLineSpacing=15;
    
    // 设置item之间间距
    flowLayout.minimumInteritemSpacing=7.5;
    // 全局设置itemSize
    flowLayout.itemSize = CGSizeMake(160, 140);
    //新建
    self.homeCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 67+kiPhoneX_Top_Height, kScreenWidth,140) collectionViewLayout:flowLayout];
    self.homeCollectionView.backgroundColor=kBGWhiteColor;
    self.homeCollectionView.delegate=self;
    self.homeCollectionView.dataSource=self;
    
    [self.homeCollectionView registerNib:[UINib nibWithNibName:@"CarCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CarCollectionViewCell"];
    [mapView addSubview:self.homeCollectionView];
    self.homeCollectionView.hidden=YES;
}
#pragma mark 瀑布流代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CarCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"CarCollectionViewCell" forIndexPath:indexPath];
    NLHomeCarModel *model=self.dataSource[indexPath.row];
    cell.nameLabel.text=model.licensenum;
    [cell.carImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",carimg_header,model.picpath]] placeholderImage:[UIImage imageNamed:@"car"]];
    return cell;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   NLHomeCarModel *model=self.dataSource[indexPath.row];
    numLabel.text=model.licensenum;
    self.currentCarModel=model;
      [self hideCollect];
}
#pragma mark 初始化车辆位置列表
-(void)initLocationTableView{
    if (!self.locationTableView) {
        self.locationTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 67+kiPhoneX_Top_Height, kScreenWidth,  kScreenHeight-CGRectGetMaxY(bgView.frame)-64-kiPhoneX_Bottom_Height) style:(UITableViewStylePlain)];
        self.locationTableView.delegate=self;
        self.locationTableView.dataSource=self;
        self.locationTableView.backgroundColor=kBGWhiteColor;
        self.locationTableView.tableFooterView=[[UIView alloc] init];
        [self.locationTableView registerNib:[UINib nibWithNibName:@"NLCarLocationTableViewCell" bundle:nil] forCellReuseIdentifier:@"NLCarLocationTableViewCell"];
        [self.locationTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        MJRefreshAutoNormalFooter *footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        [footer setTitle:@"正在加载更多记录..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"---我的底线---" forState:MJRefreshStateNoMoreData];
        footer.stateLabel.textColor=[UIColor grayColor];
        self.locationTableView.mj_footer=footer;
        [self.view addSubview:self.locationTableView];
        self.locationTableView.hidden=YES;
    }
}
-(void)refresh{
    NSDate *ddd=datePicker.date;
    NSString *timeStr=[DHHleper transDateToString:ddd];
    [self downLoadTableViewDataWithDate:timeStr index:self.dataIndex];
}
#pragma mark 初始化地图
-(void)initMapView{
    mapView=[[BMKMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate=self;
      mapView.showsUserLocation=YES;
    [self.view addSubview:mapView];
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"uOWxXINBl36nqO34nunGHqmBteAcumOy" authDelegate:nil];
 
    _routesearch = [[BMKRouteSearch alloc]init];
    [mapView setZoomLevel:16];
    mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
   
}
- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.allowsBackgroundLocationUpdates = NO;
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
}
#pragma mark 地图绘线
-(void)drawMapLineWithAry:(NSArray*)ary{
    CLLocationCoordinate2D coor[[ary count]];
    
    if (ary.count>=2) {
        NSMutableArray *cllAry=[NSMutableArray array];
        
        for (int i=0; i<ary.count; i++) {
            NSDictionary *locDic=ary[i];
            NLCarLocationInfoModel *model=[DHHleper transNullmodel:[NLCarLocationInfoModel yy_modelWithDictionary:locDic]];
            [cllAry addObject:@{@"latitude":model.latitude,@"longitude":model.longitude}];
            RouteAnnotation *anno=[[RouteAnnotation alloc] init];
            coor[i].latitude=model.latitude.floatValue+(float)(arc4random()%100) / 1000000;
            coor[i].longitude=model.longitude.floatValue+(float)(arc4random()%100) / 1000000;
            anno.title=[NSString stringWithFormat:@"%@%@%@%@%@",model.province,model.city,model.prefecture,model.town,model.addr];
            anno.coordinate=coor[i];
            anno.type=3;
            if (i==0) {
                anno.type=2;
            }
            if (i==ary.count-1){
                anno.type=1;
            }
            [self.carAnnotionArray addObject:anno];
            [self.carLocationModelArray addObject:model];
        }
        if (ary.count>12) {//节点过多无法算路，直接显示节点
            BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coor count:ary.count];
            [mapView addOverlay:polyline];
            [mapView addAnnotations:self.carAnnotionArray];
        }else{//路线规划
            self.routesearch=[[BMKRouteSearch alloc] init];
            self.routesearch.delegate=self;
            BMKPlanNode* start = [[BMKPlanNode alloc]init];
            NLCarLocationInfoModel *model=self.carLocationModelArray[0];
            CLLocationCoordinate2D startcoor=CLLocationCoordinate2DMake([model.latitude floatValue], [model.longitude floatValue]);
            start.pt = startcoor;
            
            BMKPlanNode* end = [[BMKPlanNode alloc]init];
            NLCarLocationInfoModel *model2=self.carLocationModelArray[ary.count-1];
            CLLocationCoordinate2D endcoor=CLLocationCoordinate2DMake([model2.latitude floatValue], [model2.longitude floatValue]);
            end.pt=endcoor;
            
            BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
            drivingRouteSearchOption.from = start;
            drivingRouteSearchOption.to = end;
            if (self.carLocationModelArray.count>2) {
                NSMutableArray *wayNodeAry=[NSMutableArray array];
                for (int i=1; i<self.carLocationModelArray.count-1; i++) {
                    BMKPlanNode *Node = [[BMKPlanNode alloc] init];
                    NLCarLocationInfoModel *model3=self.carLocationModelArray[i];
                    CLLocationCoordinate2D coors=CLLocationCoordinate2DMake([model3.latitude floatValue], [model3.longitude floatValue]);
                    Node.pt=coors;
                    
                    [wayNodeAry addObject:Node];
                }
                drivingRouteSearchOption.wayPointsArray=wayNodeAry;
            }
            drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
            BOOL flag = [self.routesearch drivingSearch:drivingRouteSearchOption];
            if(!flag) {
                DLog(@"car检索发送失败");
            }
        }
        
        NSDictionary *resultDic=[DHHleper findCenterStringWithLocationAry:cllAry];
        CLLocation *maxL=[[CLLocation alloc] initWithLatitude:[resultDic[@"maxlatitude"]doubleValue] longitude:[resultDic[@"maxlongitude"]doubleValue]];
        CLLocation *minL=[[CLLocation alloc] initWithLatitude:[resultDic[@"minlatitude"]doubleValue] longitude:[resultDic[@"minlongitude"]doubleValue]];
        double distance=[maxL distanceFromLocation:minL];
        NSArray *zoomAry=@[@"50",@"100",@"200",@"500",@"1000",@"2000",@"5000",@"10000",@"20000",@"25000",@"50000",@"100000",@"200000",@"500000",@"1000000",@"2000000"];//级别18到3。
        int level = 16;
        for (int i=0; i<zoomAry.count; i++) {
            if ([zoomAry[i] doubleValue]-distance>0) {
                level=18-i+3;
                break;
            }
        }
        
        double centerla=([resultDic[@"maxlatitude"]doubleValue]+[resultDic[@"minlatitude"]doubleValue])/2;
        double centerlo=([resultDic[@"maxlongitude"]doubleValue]+[resultDic[@"minlongitude"]doubleValue])/2;
        CLLocationCoordinate2D center=CLLocationCoordinate2DMake(centerla,centerlo);
        [mapView setCenterCoordinate:center];
        [mapView setZoomLevel:level];
    }else{
        NSDictionary *locDic=ary[0];
        NLCarLocationInfoModel *model=[DHHleper transNullmodel:[NLCarLocationInfoModel yy_modelWithDictionary:locDic]];
        RouteAnnotation *anno=[[RouteAnnotation alloc] init];
        coor[0].latitude=model.latitude.doubleValue;
        coor[0].longitude=model.longitude.doubleValue;
        anno.title=[NSString stringWithFormat:@"%@%@%@%@%@",model.province,model.city,model.prefecture,model.town,model.addr];
        anno.coordinate=coor[0];
        anno.type=1;
        [mapView addAnnotation:anno];
        [self.carLocationModelArray addObject:model];
        [mapView setCenterCoordinate:coor[0]];
    }
    
}

#pragma mark 地图轨迹下载
-(void)downLoadMapDataWithDate:(NSString*)date{
    DLog(@"下载车辆%@的地图数据",self.currentCarModel.licensenum);
    NSString *startTime=[date stringByAppendingString:@" 00:00:00"];
    NSString *endTime=[date stringByAppendingString:@" 23:59:59"];
    __weak BMKMapView *view=mapView;
    NSDictionary *param=@{@"recordtimeendstart":startTime,@"recordtimeend":endTime,@"licensenum":self.currentCarModel.licensenum};
    [MBProgressHUD showMessag:@"请求中···" toView:self.view];
    [manager GET:kGetMapURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSArray *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            if ([resInfo isKindOfClass:[NSArray class]]) {
                
                //  NSArray *locationList=resInfo[@"list"];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (resInfo.count>0) {
                    [self.carLocationModelArray removeAllObjects];
                    [self.carAnnotionArray removeAllObjects];
                    [view removeAnnotations:view.annotations];
                    [view removeOverlays:view.overlays];
                    [self drawMapLineWithAry:resInfo];
                    self.haveTrail=YES;
                    
                }else{
                    self.haveTrail=NO;
                    [view removeAnnotations:view.annotations];
                    [view removeOverlays:view.overlays];
                    [view setZoomLevel:16];
                    [view updateLocationData:self.currentLocation];
                    [view setCenterCoordinate:(CLLocationCoordinate2DMake(self.currentLocation.location.coordinate.latitude, self.currentLocation.location.coordinate.longitude))];
                    [self.carLocationModelArray removeAllObjects];
                    [self.carAnnotionArray removeAllObjects];
                    [MBProgressHUD showError:@"当天无车辆轨迹" toView:nil];
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
#pragma mark 位置信息下载
-(void)downLoadTableViewDataWithDate:(NSString*)date index:(int)index{
    NSString *startTime=[date stringByAppendingString:@" 00:00:00"];
    NSString *endTime=[date stringByAppendingString:@" 23:59:59"];
    self.locationTableView.mj_footer.userInteractionEnabled=NO;
    NSDictionary *param=@{@"recordtimeendstart":startTime,@"recordtimeend":endTime,@"licensenum":self.currentCarModel.licensenum,@"pageSize":@"20",@"current":@(index)};
    // [MBProgressHUD showMessag:@"请求中···" toView:self.view];
    [manager GET:kGetCarTrailURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            
            self.locationTableView.mj_footer.userInteractionEnabled=YES;
            NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            if ([resInfo isKindOfClass:[NSDictionary class]]) {
                
                NSArray *locationList=resInfo[@"list"];
                //   [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (locationList.count>0) {
                    [self.locationTableView.mj_footer endRefreshing];
                    for (int i=0; i<locationList.count; i++) {
                        NSDictionary *locDic=locationList[i];
                       NLCarLocationInfoModel *model=[DHHleper transNullmodel:[NLCarLocationInfoModel yy_modelWithDictionary:locDic]];
                        [self.tableDataSoure addObject:model];
                        
                    }
                    self.dataIndex++;
                    [self.locationTableView reloadData];
                }else{
                   
                    if (index>1) {
                        [self.locationTableView.mj_footer endRefreshingWithNoMoreData];
                        [MBProgressHUD showError:@"没有更多轨迹了" toView:nil];
                    }
                }
                
            }else{
                // [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showError:@"数据格式错误" toView:nil];
            }
        }else{
            [self.locationTableView.mj_footer endRefreshing];
            self.locationTableView.mj_footer.userInteractionEnabled=YES;
            // [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器无响应" toView:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.locationTableView.mj_footer endRefreshing];
        self.locationTableView.mj_footer.userInteractionEnabled=YES;
        //   [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"网络错误，请检查网络是否正常" toView:nil];
    }];
}
#pragma mark - BMKLocationManagerDelegate
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
        DLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
     BMKUserLocation * userLocation = [[BMKUserLocation alloc] init];
    userLocation.location = location.location;
    self.currentLocation = userLocation;
    // [self reverseSearchUserLocaion];
    if (!_haveTrail) {
        
        [mapView updateLocationData:self.currentLocation];
        [mapView setCenterCoordinate:(CLLocationCoordinate2DMake(self.currentLocation.location.coordinate.latitude, self.currentLocation.location.coordinate.longitude))];
    }
    
}

#pragma mark 地图代理

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        RouteAnnotation *anno=annotation;
        BMKAnnotationView *annotationView=[(RouteAnnotation*)anno getRouteAnnotationView:mapView];
        if (self.carAnnotionArray.count>2&&anno.type==3) {
            
            //此处加for循环 去找annotation对应的序号标题
            for (int i=1; i<self.carAnnotionArray.count-1; i++) {
                RouteAnnotation *ranno=self.carAnnotionArray[i];
                CGFloat lat =ranno.coordinate.latitude;
                CGFloat lng = ranno.coordinate.longitude;
                //通过判断给相对应的标注添加序号标题
                if(annotation.coordinate.latitude == lat && annotation.coordinate.longitude ==  lng )
                {
                    //给不同的标注添加1，2，3，4，5这样的序号标题
                    UILabel *la = [[UILabel alloc]initWithFrame:CGRectMake(0, -1, annotationView.frame.size.width,annotationView.frame.size.height-annotationView.frame.size.height*20/69)];
                    la.backgroundColor = [UIColor clearColor];
                    la.textColor=[UIColor whiteColor];
                    la.font = [UIFont systemFontOfSize:12];
                    la.textAlignment = NSTextAlignmentCenter;
                    la.text = [NSString stringWithFormat:@"%d",i+1];
                    
                    [annotationView addSubview:la];
                }
            }
            
        }
        return annotationView;
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 2.0;
        return polylineView;
    }
    return nil;
}
- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher  result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        
        NSInteger size = [plan.steps count];
        for (int i = 0; i < size; i++) {
            BMKDrivingStep *tansitStep = [plan.steps objectAtIndex:i];
            
            RouteAnnotation* annotation = [[RouteAnnotation alloc]init];
            
            annotation.coordinate =  tansitStep.entrace.location; //路段入口信息
            // DLog(@"%lf,%lf",annotation.coordinate.latitude,annotation.coordinate.longitude );
            annotation.type=5;
            
            annotation.degree=tansitStep.direction*30;
            annotation.title = tansitStep.instruction; //路程换成说明
            [mapView addAnnotation:annotation];
            
            //轨迹点总数累计
            planPointCounts += tansitStep.pointsCount;
        }
        
        if (self.carAnnotionArray.count>0) {
            [mapView addAnnotations:self.carAnnotionArray];
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts]; //文件后缀名改为mm
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKTransitStep *transitStep = [plan.steps objectAtIndex:j];
            int k = 0;
            for (k = 0; k < transitStep.pointsCount; k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        //通过points构建BMKPolyline
        BMKPolyline *polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [mapView addOverlay:polyLine]; //添加路线overlay
        planPointCounts=0;
        delete []temppoints;
        
    }else{
        DLog(@"%u",error);
    }
    
    
}
#pragma mark 位置获取
-(void)myLocClick{
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
      [mapView updateLocationData:self.currentLocation];
       [mapView setCenterCoordinate:(CLLocationCoordinate2DMake(_currentLocation.location.coordinate.latitude, _currentLocation.location.coordinate.longitude))];
}
-(void)carLocClick{
    if (self.carLocationModelArray.count>0) {
        NLCarLocationInfoModel *model=self.carLocationModelArray.lastObject;
        CGFloat latitude=model.latitude.floatValue;
        CGFloat longitude=model.longitude.floatValue;
        [mapView setCenterCoordinate:(CLLocationCoordinate2DMake(latitude, longitude))];
    }
}
-(void)chooseTime{
     [datePicker setDate:[NSDate date] animated:YES];
    [self.view addSubview:dateBGView];
    
}
#pragma mark tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.tableDataSoure.count>0) {
           return self.tableDataSoure.count;
    }else{
        return 1;
    }
 
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    if (self.tableDataSoure.count>0) {
        NLCarLocationInfoModel *model=self.tableDataSoure[indexPath.row];
          NLCarLocationTableViewCell *llcell=[tableView dequeueReusableCellWithIdentifier:@"NLCarLocationTableViewCell" forIndexPath:indexPath];
        llcell.numLabel.text=[NSString stringWithFormat:@"序号：%ld",indexPath.row+1];
        llcell.infoLabel.text=model.addr;
        llcell.timeLabel.text=model.recordtime;
        cell=llcell;
    }else{
        UITableViewCell *nocell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
        nocell.textLabel.text=@"无车辆轨迹";
        cell=nocell;
    }
  
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
#pragma mark 时间选择器事件
-(void)cancelChoose{
    [dateBGView removeFromSuperview];
}
-(void)confimChoose{
    [dateBGView removeFromSuperview];
    NSDate *ddd=datePicker.date;
    NSString *timeStr=[DHHleper transDateToString:ddd];
    // second:@"\U0000e69b" titleColor:[UIColor grayColor] size1:14 size2:14
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",timeStr,@"\U0000e69b"]];
    NSRange range1 = [[str string] rangeOfString:@"\U0000e69b"];
     NSRange range2 = [[str string] rangeOfString:timeStr];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:14] range:range2];
   
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"iconfont" size:14] range:range1];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range2];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range1];
    [timeBtn setAttributedTitle:str forState:(UIControlStateNormal)];
    timeBtn.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
    
    timeBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
   // [timeBtn setTitle:timeStr forState:(UIControlStateNormal)];
    [self downLoadMapDataWithDate:timeStr];
    [self.tableDataSoure removeAllObjects];
    [self.locationTableView reloadData];
    self.dataIndex=1;
    [self downLoadTableViewDataWithDate:timeStr index:self.dataIndex];
}
#pragma mark 报警事件
-(void)toPolice{//报警
    NLCallPoliceViewController *call=[[NLCallPoliceViewController alloc] init];
    call.callBackBlock = ^{
         self.navigationController.navigationBar.hidden=YES;
    };
    [self.navigationController pushViewController:call animated:YES];
}
#pragma mark 轨迹列表显示与否
-(void)rightBtnClick{//轨迹列表显示与否
    if (isMapView) {
        [listBtn setTitle:@"地图" forState:(UIControlStateNormal)];
        
        isMapView=NO;
     //   [self.view addSubview:self.locationTableView];
        self.locationTableView.hidden=NO;
    }else{
          [listBtn setTitle:@"列表" forState:(UIControlStateNormal)];
        isMapView=YES;
       // [self.locationTableView removeFromSuperview];
          self.locationTableView.hidden=YES;
    }
  
}
#pragma mark 消息事件
-(void)notiBtnClick{//消息
    NLMessageViewController *mess=[[NLMessageViewController alloc] init];
    mess.callBackBlock = ^{
         self.navigationController.navigationBar.hidden=YES;
    };
    [self.navigationController pushViewController:mess animated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
        [super viewWillAppear:animated];
    [mapView viewWillAppear];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [mapView viewWillDisappear];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    
    self.locationManager.delegate = nil;
    mapView.delegate = nil; // 不用时，置nil
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"地图页释放");
}

//    UIButton *myLocBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-30-64-kiPhoneX_Bottom_Height, kScreenWidth/2, 30)];
//    [myLocBtn setTitle:@"我的位置" forState:(UIControlStateNormal)];
//    myLocBtn.backgroundColor=kBlueColor;
//    [myLocBtn addTarget:self action:@selector(myLocClick) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.view addSubview:myLocBtn];
//    UIButton *carLocBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2+1, kScreenHeight-30-64-kiPhoneX_Bottom_Height, kScreenWidth/2-1, 30)];
//    [carLocBtn setTitle:@"车位置" forState:(UIControlStateNormal)];
//    carLocBtn.backgroundColor=kBlueColor;
//    [carLocBtn addTarget:self action:@selector(carLocClick) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.view addSubview:carLocBtn];

//    UILabel *tLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 30)];
//    tLabel.text=@"日期:";
//    [bgView addSubview:tLabel];
//    timeBtn=[[UIButton alloc] initWithFrame:CGRectMake(50, 0, kScreenWidth/2-50, 30)];
//    NSString *timeStr=[DHHleper getLocalDate];
//    [timeBtn setTitle:timeStr forState:(UIControlStateNormal)];
//    [timeBtn setTitleColor:kBlueColor forState:(UIControlStateNormal)];
//    [timeBtn addTarget:self action:@selector(chooseTime) forControlEvents:(UIControlEventTouchUpInside)];
//    [bgView addSubview:timeBtn];
//    UILabel *nLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 0, 60, 30)];
//    nLabel.text=@"车牌号:";
//    [bgView addSubview:nLabel];
//    UILabel *numLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2+60, 0, kScreenWidth/2-60, 30)];
//    numLabel.text=self.carNum;
//    numLabel.textColor=[UIColor grayColor];
//    [bgView addSubview:numLabel];
@end
