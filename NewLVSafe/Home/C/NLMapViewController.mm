//
//  NLMapViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/24.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLMapViewController.h"
#import <BaiduMapAPI_Map_For_WalkNavi/BMKMapView.h>
#import <BaiduMapAPI_Map_For_WalkNavi/BMKMapComponent.h>
#import <BaiduMapAPI_WalkNavi/BMKWalkNaviComponent.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "RouteAnnotation.h"
#import "BMKWalkNaviViewController.h"
#import "NLCarLocationInfoModel.h"
#import "NLCarLocationTableViewCell.h"
#import "KKSliderMenuTool.h"
#import "NLMineViewController.h"
#import "CarCollectionViewCell.h"
#import "NLHomeCarModel.h"
#import "NLCallPoliceViewController.h"
#import "NLMessageViewController.h"

@interface NLMapViewController ()<BMKWalkCycleRoutePlanDelegate, BMKWalkCycleRouteGuidanceDelegate, BMKWalkCycleTTSPlayerDelegate,BMKLocationManagerDelegate, BMKGeoCodeSearchDelegate, BMKMapViewDelegate, BMKRouteSearchDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

{
    BMKMapView *mapView;
    UIButton *userBtn,*carBtn,*notiBtn,*listBtn;
    UILabel *numLabel;
    UIButton *timeBtn,*okBtn,*cancelBtn,*safeBtn;
    UIView *dateBGView,*bgView,*safeView;
    UIDatePicker *datePicker;
    CGFloat width;
    BOOL isMapView,isShow,isLogin;
    int  planPointCounts;
    AFHTTPSessionManager *manager;
    NSDictionary *userInfo;
}
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)UICollectionView *homeCollectionView;
@property (nonatomic, assign) BOOL haveTrail;
@property (nonatomic, strong) BMKLocationManager *locationManager;
@property (nonatomic, strong) BMKRouteSearch* routesearch;          ///算路搜索，进入步行导航前，把算路路线展示在地图上
@property(nonatomic,strong)NSMutableArray *carLocationModelArray; //车辆位置信息数组
@property(nonatomic,strong)NSMutableArray *carAnnotionArray; //车辆大头针数组
@property(nonatomic ,strong)UITableView  *locationTableView;
@property (nonatomic, strong) RouteAnnotation* startAnnotation;  ///起点
@property (nonatomic, strong) RouteAnnotation* endAnnotation;    ///终点
@property (nonatomic, strong) NLHomeCarModel* currentCarModel; //当前显示车辆
@property (nonatomic, strong) BMKUserLocation *currentLocation;     ///当前位置信息，作为起点
@end

@implementation NLMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden=YES;
 planPointCounts=0;
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
#pragma mark 头部导航栏
    bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 22+kiPhoneX_Top_Height, kScreenWidth, 44)];
    bgView.backgroundColor=[UIColor whiteColor];
    [mapView addSubview:bgView];
    userBtn=[UIButton iconButtonWithFrame:CGRectMake(15, 7, 30, 30) title:@"\U0000e61a" size:25 color:[UIColor grayColor]  superView:bgView];
    [userBtn addTarget:self action:@selector(userClick) forControlEvents:(UIControlEventTouchUpInside)];
     carBtn=[UIButton iconButtonWithFrame:CGRectMake(60, 7, 30, 30) title:@"\U0000e61d" size:25 color:[UIColor grayColor]  superView:bgView];
    [carBtn addTarget:self action:@selector(carlistClick) forControlEvents:(UIControlEventTouchUpInside)];
   notiBtn=[UIButton iconButtonWithFrame:CGRectMake(kScreenWidth-90, 7, 30, 30) title:@"\U0000e629" size:25 color:[UIColor grayColor]  superView:bgView];
    [notiBtn addTarget:self action:@selector(notiBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
   listBtn=[UIButton iconButtonWithFrame:CGRectMake(kScreenWidth-45, 7, 30, 30) title:@"\U0000e677" size:25 color:[UIColor grayColor]  superView:bgView];
     [listBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
   // areaBtn=[UIButton normalBtnWithFrame:CGRectMake(80, 7, kScreenWidth-160, 30) title:@"豫A123451" size:14 color:[UIColor grayColor]  superView:bgView];
    numLabel=[[UILabel alloc] initWithFrame:CGRectMake(95, 7, kScreenWidth-80-120, 30)];
    numLabel.textColor=[UIColor grayColor];
    numLabel.text=@"豫A123451";
    numLabel.font=[UIFont systemFontOfSize:13];
    if (kScreenWidth>374) {
        numLabel.font=[UIFont systemFontOfSize:16];
    }
    [bgView addSubview:numLabel];

 #pragma mark 底部安全中心
    safeBtn=[UIButton secondIconFontBtnWithFirst:@"\U0000e633" second:@"安全中心" titleColor:kBlueColor size1:35 size2:14 frame:CGRectMake(15, kScreenHeight-kiPhoneX_Bottom_Height-110, 60, 60) superView:mapView];
    safeBtn.backgroundColor=[UIColor whiteColor];
    [safeBtn addTarget:self action:@selector(safeClick:) forControlEvents:(UIControlEventTouchUpInside)];
#pragma mark 日期选择
    dateBGView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-220-kiPhoneX_Bottom_Height, kScreenWidth, 220)];
    dateBGView.backgroundColor=kBGWhiteColor;
    cancelBtn=[[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 20)];
    [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancelBtn setTitleColor:kBlueColor forState:(UIControlStateNormal)];
    [cancelBtn addTarget:self action:@selector(cancelChoose) forControlEvents:(UIControlEventTouchUpInside)];
    [dateBGView addSubview:cancelBtn];
    okBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 0, 40, 20)];
    [okBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [okBtn setTitleColor:kBlueColor forState:(UIControlStateNormal)];
    [okBtn addTarget:self action:@selector(confimChoose) forControlEvents:(UIControlEventTouchUpInside)];
    [dateBGView addSubview:okBtn];
    datePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 200)];
    datePicker.datePickerMode=UIDatePickerModeDate;
    datePicker.maximumDate=[NSDate date];
    [datePicker setDate:[NSDate date] animated:YES];
    datePicker.locale= [NSLocale localeWithLocaleIdentifier:@"zh"];
    [dateBGView addSubview:datePicker];
    //

#pragma mark 地图数组
    CLLocation *loca=[[CLLocation alloc] initWithLatitude:+34.81781978 longitude:+113.57227160];
    self.currentLocation=[[BMKUserLocation alloc] init];
    self.currentLocation.location=loca;
    self.haveTrail=NO;
    [self initMapView];
    self.carLocationModelArray=[NSMutableArray array];
    self.carAnnotionArray=[NSMutableArray array];
    self.dataSource=[NSMutableArray array];
    _startAnnotation=[[RouteAnnotation alloc] init];
    _endAnnotation=[[RouteAnnotation alloc] init];
    [self downLoadMapDataWithDate:[DHHleper getLocalDate]];
    [self initLocationTableView];
    isMapView=YES;
    [self initcarCollectionView];
    [self downLoadData];
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;// 屏幕左侧边缘响应
    [self.view addGestureRecognizer:leftEdgeGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Reactive) name:@"Reactive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Reactive) name:@"Warning" object:nil];
}
-(void)Reactive{
    isLogin=[[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] boolValue];
    if (isLogin) {
        userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
        [self.dataSource removeAllObjects];
        [self downLoadData];
         [self downLoadMapDataWithDate:[DHHleper getLocalDate]];
    }
    
}

- (void)moveViewWithGesture:(UIPanGestureRecognizer *)panGes {
    if (panGes.state == UIGestureRecognizerStateEnded) {
        [KKSliderMenuTool showWithRootViewController:self contentViewController:[[NLMineViewController alloc] init]];
    }
}
-(void)userClick{
      [KKSliderMenuTool showWithRootViewController:self contentViewController:[[NLMineViewController alloc] init]];
}
#pragma mark 安全中心
-(void)safeClick:(UIButton*)btn{
   width=(kScreenWidth-90)/3;
     CGFloat hei=45+width+35;
        [self initSafeView];
        safeView.frame=CGRectMake(0, kScreenHeight-hei-kiPhoneX_Bottom_Height, kScreenWidth, hei);
        [mapView addSubview:safeView];
    
}
-(void)closesafe{
        __weak UIView *sv=safeView;
      CGFloat hei=45+width+35;
   // __weak UIButton *bu=safeBtn;
    [UIView animateWithDuration:0.25 animations:^{
        sv.frame=CGRectMake(-kScreenWidth, kScreenHeight-hei-kiPhoneX_Bottom_Height, kScreenWidth, hei);
    } completion:^(BOOL finished) {
        [sv removeFromSuperview];
    }];
}
-(void)initSafeView{
    safeView=[[UIView alloc] init];
    safeView.backgroundColor=[UIColor whiteColor];
  
  UILabel *titLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 25)];
    titLabel.text=@"安全中心";
    [safeView addSubview:titLabel];
   UIButton *closeBtn=[UIButton iconButtonWithFrame:CGRectMake(kScreenWidth-40, 10, 25, 25) title:@"\U0000e61b" size:24 color:[UIColor blackColor] superView:safeView];
    [closeBtn addTarget:self action:@selector(closesafe) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *timeBnt=[UIButton iconButtonWithFrame:CGRectMake(15, 45, width, width) title:@"\U0000e615" size:width/2 color:[UIColor whiteColor] superView:safeView];
    timeBnt.backgroundColor=kBlueColor;
    timeBnt.layer.masksToBounds=YES;
    timeBnt.layer.cornerRadius=width/2;
    [timeBnt addTarget:self action:@selector(chooseTime) forControlEvents:(UIControlEventTouchUpInside)];
    UILabel *tlabel=[[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(timeBnt.frame), width, 20)];
    tlabel.textAlignment=NSTextAlignmentCenter;
    tlabel.text=@"日期";
    [safeView addSubview:tlabel];
    
   UIButton *policeBnt=[UIButton iconButtonWithFrame:CGRectMake(45+width, 45, width, width) title:@"\U0000e640" size:width/2 color:[UIColor whiteColor] superView:safeView];
    policeBnt.backgroundColor=kBlueColor;
    policeBnt.layer.masksToBounds=YES;
    [policeBnt addTarget:self action:@selector(toPolice) forControlEvents:(UIControlEventTouchUpInside)];
    policeBnt.layer.cornerRadius=width/2;
    UILabel *plabel=[[UILabel alloc] initWithFrame:CGRectMake(45+width, CGRectGetMaxY(timeBnt.frame), width, 20)];
    plabel.textAlignment=NSTextAlignmentCenter;
    plabel.text=@"一键报警";
    [safeView addSubview:plabel];
    NSString *iconStr,*nameStr;
    if ([self.currentCarModel.state isEqualToString:@"0"]) {
        iconStr=@"\U0000e657";
        nameStr=@"未锁";
    }else if([self.currentCarModel.state isEqualToString:@"4"]){
        iconStr=@"\U0000e657";
        nameStr=@"已锁";
    }else{
        iconStr=@"\U0000e657";
        nameStr=@"报警";
    }
    UIButton *lockBtn=[UIButton iconButtonWithFrame:CGRectMake(75+2*width, 45, width, width) title:iconStr size:width/2 color:[UIColor whiteColor] superView:safeView];
    lockBtn.backgroundColor=kBlueColor;
    lockBtn.layer.masksToBounds=YES;
    [lockBtn addTarget:self action:@selector(lockClick) forControlEvents:(UIControlEventTouchUpInside)];
    lockBtn.layer.cornerRadius=width/2;
    UILabel *llabel=[[UILabel alloc] initWithFrame:CGRectMake(75+2*width, CGRectGetMaxY(timeBnt.frame), width, 20)];
    llabel.textAlignment=NSTextAlignmentCenter;
    llabel.text=nameStr;
    [safeView addSubview:llabel];
    
}
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
                            [self downLoadData];
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
}
-(void)downLoadData{
    
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
                    }
                }
                   
                    [self.homeCollectionView reloadData];
                    
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
-(void)initcarCollectionView{
    //
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    //设置行间距
    flowLayout.minimumLineSpacing=15;
    
    // 设置item之间间距
    flowLayout.minimumInteritemSpacing=7.5;
    // 全局设置itemSize
    flowLayout.itemSize = CGSizeMake(90, 60);
    //新建
    self.homeCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(bgView.frame), kScreenWidth-30,60) collectionViewLayout:flowLayout];
    self.homeCollectionView.backgroundColor=kBGWhiteColor;
    self.homeCollectionView.delegate=self;
    self.homeCollectionView.dataSource=self;
    
    [self.homeCollectionView registerNib:[UINib nibWithNibName:@"CarCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CarCollectionViewCell"];
    [mapView addSubview:self.homeCollectionView];
}
#pragma mark 瀑布流代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{__weak UILabel *lll=numLabel;
    CarCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"CarCollectionViewCell" forIndexPath:indexPath];
    NLHomeCarModel *model=self.dataSource[indexPath.row];
    cell.nameLabel.text=model.licensenum;
    [cell showcarlist:^{
        lll.text=model.licensenum;
        self.currentCarModel=model;
        [self hideCollect];
    }];
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
        self.locationTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame), kScreenWidth,  kScreenHeight-CGRectGetMaxY(bgView.frame)-kiPhoneX_Top_Height) style:(UITableViewStylePlain)];
        self.locationTableView.delegate=self;
        self.locationTableView.dataSource=self;
        self.locationTableView.backgroundColor=kBGWhiteColor;
        self.locationTableView.tableFooterView=[[UIView alloc] init];
        [self.locationTableView registerNib:[UINib nibWithNibName:@"NLCarLocationTableViewCell" bundle:nil] forCellReuseIdentifier:@"NLCarLocationTableViewCell"];
        [self.locationTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
}
#pragma mark 初始化地图
-(void)initMapView{
    mapView=[[BMKMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate=self;
      mapView.showsUserLocation=YES;
    [self.view addSubview:mapView];
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"kkPXXo5Ok4aGQSNtG6HchZGpZSjlc6ka" authDelegate:nil];
 
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
    [self.carLocationModelArray removeAllObjects];
    if (ary.count>=2) {
        NSMutableArray *cllAry=[NSMutableArray array];
        
        for (int i=0; i<ary.count; i++) {
            NSDictionary *locDic=ary[i];
            NLCarLocationInfoModel *model=[DHHleper transNullmodel:[NLCarLocationInfoModel yy_modelWithDictionary:locDic]];
            [cllAry addObject:@{@"latitude":model.latitude,@"longitude":model.longitude}];
            RouteAnnotation *anno=[[RouteAnnotation alloc] init];
            coor[i].latitude=model.latitude.doubleValue;
            coor[i].longitude=model.longitude.doubleValue;
            anno.title=[NSString stringWithFormat:@"%@%@%@%@%@",model.province,model.city,model.prefecture,model.town,model.addr];
            anno.coordinate=coor[i];
            anno.type=3;
            if (i==0) {
                _startAnnotation.type=2;
            }
            if (i==ary.count-1){
                _endAnnotation.type=1;
            }
            [self.carAnnotionArray addObject:_endAnnotation];
            [self.carLocationModelArray addObject:model];
        }
        if (ary.count>10) {//节点过多无法算路，直接显示节点
            BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coor count:ary.count];
            [mapView addOverlay:polyline];
            [mapView addAnnotations:self.carAnnotionArray];
        }else{//路线规划
            self.routesearch=[[BMKRouteSearch alloc] init];
            self.routesearch.delegate=self;
            BMKPlanNode* start = [[BMKPlanNode alloc]init];
            start.pt=coor[0];
            
            BMKPlanNode* end = [[BMKPlanNode alloc]init];
            end.pt=coor[ary.count-1];
            
            BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
            drivingRouteSearchOption.from = start;
            drivingRouteSearchOption.to = end;
            if (self.carLocationModelArray.count>2) {
                NSMutableArray *wayNodeAry=[NSMutableArray array];
                for (int i=1; i<self.carLocationModelArray.count-1; i++) {
                    BMKPlanNode *Node = [[BMKPlanNode alloc] init];
                    Node.pt=coor[i];
                    
                    [wayNodeAry addObject:Node];
                }
                drivingRouteSearchOption.wayPointsArray=wayNodeAry;
            }
            drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
            BOOL flag = [self.routesearch drivingSearch:drivingRouteSearchOption];
            if(flag) {
                DLog(@"car检索发送成功");
            }else {
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
        DLog(@"distance:%f,level:%d",distance,level);
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
    NSString *startTime=[date stringByAppendingString:@" 00:00:00"];
    NSString *endTime=[date stringByAppendingString:@" 23:59:59"];
    __weak BMKMapView *view=mapView;
    NSDictionary *param=@{@"recordtimeendstart":startTime,@"recordtimeend":endTime,@"licensenum":self.carNum};
    [MBProgressHUD showMessag:@"请求中···" toView:self.view];
    [manager GET:kGetCarTrailURl parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
            if (resInfo) {
                
                NSArray *locationList=resInfo[@"list"];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (locationList.count>0) {
                    [view removeAnnotations:view.annotations];
                    [view removeOverlays:view.overlays];
                    [self drawMapLineWithAry:locationList];
                    self.haveTrail=YES;
                    
                }else{
                    self.haveTrail=NO;
                    [view removeAnnotations:view.annotations];
                    [view removeOverlays:view.overlays];
                    [view setZoomLevel:16];
                    [view updateLocationData:self.currentLocation];
                    [view setCenterCoordinate:(CLLocationCoordinate2DMake(self.currentLocation.location.coordinate.latitude, self.currentLocation.location.coordinate.longitude))];
                    [self.carLocationModelArray removeAllObjects];
                    [MBProgressHUD showError:@"当天无车辆轨迹" toView:nil];
                }
                [self.locationTableView reloadData];
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
        if (anno.type==3||anno.type==2||anno.type==1) {
            
            //此处加for循环 去找annotation对应的序号标题
            for (int i=0; i<self.carLocationModelArray.count; i++) {
                NLCarLocationInfoModel *model=self.carLocationModelArray[i];
                CGFloat lat = model.latitude.floatValue;
                CGFloat lng = model.longitude.floatValue;
                //通过判断给相对应的标注添加序号标题
                if(annotation.coordinate.latitude == lat && annotation.coordinate.longitude ==  lng )
                {
                    if (i>0&&i<self.carLocationModelArray.count-1) {
                        //给不同的标注添加1，2，3，4，5这样的序号标题
                        UILabel *la = [[UILabel alloc]initWithFrame:CGRectMake(0, -1, annotationView.frame.size.width,annotationView.frame.size.height-annotationView.frame.size.height*20/69)];
                        la.backgroundColor = [UIColor clearColor];
                        la.textColor=[UIColor whiteColor];
                        la.font = [UIFont systemFontOfSize:12];
                        la.textAlignment = NSTextAlignmentCenter;
                        la.text = [NSString stringWithFormat:@"%d",i+1];
                        
                        [annotationView addSubview:la];
                    }} }}
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
        
        for (int i = 1; i < size-2; i++) {
            BMKDrivingStep *tansitStep = [plan.steps objectAtIndex:i];
            
            RouteAnnotation* annotation = [[RouteAnnotation alloc]init];
            
            annotation.coordinate =  tansitStep.entrace.location; //路段入口信息
            annotation.type=5;
            
            annotation.degree=tansitStep.direction*30;
            annotation.title = tansitStep.instruction; //路程换成说明
            [mapView addAnnotation:annotation];
            
            //轨迹点总数累计
            planPointCounts += tansitStep.pointsCount;
        }
        for (int i=0; i<self.carLocationModelArray.count; i++) {
            NLCarLocationInfoModel *model=self.carLocationModelArray[i];
            CGFloat lat = model.latitude.floatValue;
            CGFloat lng = model.longitude.floatValue;
            RouteAnnotation* annotation = [[RouteAnnotation alloc]init];
            
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
            annotation.title = [NSString stringWithFormat:@"%@%@%@%@%@",model.province,model.city,model.prefecture,model.town,model.addr];
            if (i==0) {
                annotation.type=2;
            }else if (i==self.carLocationModelArray.count-1){
                annotation.type=1;
            }else{
                annotation.type=3;
            }
            
            [mapView addAnnotation:annotation];
        }
        planPointCounts += self.carLocationModelArray.count;
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
    if (self.carLocationModelArray.count>0) {
           return self.carLocationModelArray.count;
    }else{
        return 1;
    }
 
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    if (self.carLocationModelArray.count>0) {
        NLCarLocationInfoModel *model=self.carLocationModelArray[indexPath.row];
          NLCarLocationTableViewCell *llcell=[tableView dequeueReusableCellWithIdentifier:@"NLCarLocationTableViewCell" forIndexPath:indexPath];
        llcell.numLabel.text=[NSString stringWithFormat:@"序号：%ld",indexPath.row+1];
        llcell.infoLabel.text=model.addr;
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
    [timeBtn setTitle:timeStr forState:(UIControlStateNormal)];
    [self downLoadMapDataWithDate:timeStr];
    
}
-(void)toPolice{//报警
    NLCallPoliceViewController *call=[[NLCallPoliceViewController alloc] init];
    call.callBackBlock = ^{
         self.navigationController.navigationBar.hidden=YES;
    };
    [self.navigationController pushViewController:call animated:YES];
}
-(void)rightBtnClick{//轨迹列表显示与否
    if (isMapView) {
        [listBtn setTitle:@"\U0000e63a" forState:(UIControlStateNormal)];
        
        isMapView=NO;
        [self.view addSubview:self.locationTableView];
    }else{
          [listBtn setTitle:@"\U0000e677" forState:(UIControlStateNormal)];
        isMapView=YES;
        [self.locationTableView removeFromSuperview];
    }
  
}
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
