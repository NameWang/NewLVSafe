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
    BOOL isMapView,isShow;
}
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)UICollectionView *homeCollectionView;
@property (nonatomic, assign) BOOL isStartPointSearched;            ///起点搜索完毕后不再进行定位
@property (nonatomic, strong) BMKLocationManager *locationManager;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;      ///根据定位返回的经纬度检索出当前位置地址，显示起点栏中
@property (nonatomic, strong) BMKRouteSearch* routesearch;          ///算路搜索，进入步行导航前，把算路路线展示在地图上，注，此算路与实际步行导航算路不相关，仅仅做demo展示用
@property(nonatomic,strong)NSMutableArray *carLocationModelArray; //车辆位置信息数组
@property(nonatomic,strong)NSMutableArray *carAnnotionArray; //车辆大头针数组
@property(nonatomic ,strong)UITableView  *locationTableView;
@property (nonatomic, strong) BMKPointAnnotation* startAnnotation;  ///起点
@property (nonatomic, strong) BMKPointAnnotation* endAnnotation;    ///终点

@property (nonatomic, strong) BMKUserLocation *currentLocation;     ///当前位置信息，作为起点
@property (nonatomic, strong) NSString *currentCity;                ///记录下当前城市
@end

@implementation NLMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden=YES;
 
    isShow=NO;
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
    self.carLocationModelArray=[NSMutableArray array];
    self.carAnnotionArray=[NSMutableArray array];
    _startAnnotation=[[BMKPointAnnotation alloc] init];
    _endAnnotation=[[BMKPointAnnotation alloc] init];
     CLLocationCoordinate2D coor[12] = {0};
    for (int i=0; i<12; i++) {
        NLCarLocationInfoModel *model=[[NLCarLocationInfoModel alloc] init];
        RouteAnnotation *anno=[[RouteAnnotation alloc] init];
  
        model.latitude=[NSString stringWithFormat:@"34.44%d",arc4random()%10];
        model.longitude=[NSString stringWithFormat:@"113.42%d",arc4random()%10];
        model.add=[NSString stringWithFormat:@"新密市某某路%d号",i];
        model.SDState=[NSString stringWithFormat:@"%d:%d:%d",arc4random()%24,arc4random()%60,arc4random()%60];
        coor[i].latitude=model.latitude.floatValue;
        coor[i].longitude=model.longitude.floatValue;
        anno.title=model.add;
        anno.coordinate=coor[i];
        if (i==0) {
            _startAnnotation.title=@"新密市某某路0号";
            _startAnnotation.coordinate=coor[0];
             [self.carAnnotionArray addObject:_startAnnotation];
        }else if (i==11){
            _endAnnotation.title=@"新密市某某路11号";
            _endAnnotation.coordinate=coor[11];
             [self.carAnnotionArray addObject:_endAnnotation];
        }else{
              [self.carAnnotionArray addObject:anno];
        }
      
        [self.carLocationModelArray addObject:model];
    }
    BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coor count:12];
    [mapView addOverlay:polyline];
    [mapView addAnnotations:self.carAnnotionArray];
    [mapView setCenterCoordinate:coor[11]];
    [self initLocationTableView];
    isMapView=YES;
   
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGesture:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;// 屏幕左侧边缘响应
    [self.view addGestureRecognizer:leftEdgeGesture];
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
    
    UIButton *lockBtn=[UIButton iconButtonWithFrame:CGRectMake(75+2*width, 45, width, width) title:@"\U0000e657" size:width/2 color:[UIColor whiteColor] superView:safeView];
    lockBtn.backgroundColor=kBlueColor;
    lockBtn.layer.masksToBounds=YES;
    lockBtn.layer.cornerRadius=width/2;
    UILabel *llabel=[[UILabel alloc] initWithFrame:CGRectMake(75+2*width, CGRectGetMaxY(timeBnt.frame), width, 20)];
    llabel.textAlignment=NSTextAlignmentCenter;
    llabel.text=@"状态";
    [safeView addSubview:llabel];
    
}
#pragma mark 瀑布流
-(void)carlistClick{
    if (isShow) {
        [self hideCollect];
    }else{
        isShow=YES;
        [carBtn setTitleColor:kBlueColor forState:(UIControlStateNormal)];
        [self initCollectionView];
        
    }
}
-(void)hideCollect{
    isShow=NO;
    [carBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    [self.homeCollectionView removeFromSuperview];
}
-(void)initCollectionView{
    //
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    //设置行间距
    flowLayout.minimumLineSpacing=15;
    
    // 设置item之间间距
    flowLayout.minimumInteritemSpacing=7.5;
    // 全局设置itemSize
    flowLayout.itemSize = CGSizeMake(90, 60);
    self.dataSource=[NSMutableArray array];
    for (int i=0; i<9; i++) {
        NLHomeCarModel *model2=[[NLHomeCarModel alloc] init];
        model2.licenseNum=[NSString stringWithFormat:@"豫A12345%d",i+1];
      
        [self.dataSource addObject:model2];
    }
  
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
    cell.nameLabel.text=model.licenseNum;
    [cell showcarlist:^{
      lll.text=model.licenseNum;
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
    numLabel.text=model.licenseNum;
      [self hideCollect];
}
#pragma mark s初始化位置列表
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
    _geocodesearch= [[BMKGeoCodeSearch alloc] init];
    _routesearch = [[BMKRouteSearch alloc]init];
    [mapView setZoomLevel:16];
    mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    _isStartPointSearched = NO;
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
    _currentLocation = userLocation;
    [self reverseSearchUserLocaion];
  
     // [mapView updateLocationData:userLocation];
     // [mapView setCenterCoordinate:(CLLocationCoordinate2DMake(_currentLocation.location.coordinate.latitude, _currentLocation.location.coordinate.longitude))];
}
//反地理搜索，查看当前位置地址信息
- (void)reverseSearchUserLocaion {
    if (_isStartPointSearched) {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
    }
    _isStartPointSearched = YES;
    BMKReverseGeoCodeSearchOption *geoOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    geoOption.location = _currentLocation.location.coordinate;
    DLog(@"SDK-纬度：%@",@(_currentLocation.location.coordinate.latitude));
    DLog(@"SDK-经度：%@",@(_currentLocation.location.coordinate.longitude));
    BOOL ret = [_geocodesearch reverseGeoCode:geoOption];
    if (ret) {
        DLog(@"SDK-检索当前位置发送成功");
    } else {
        DLog(@"SDK-检索当前位置发送失败");
    }
}

#pragma mark 地图代理
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
 //
  
//    [self.locationManager startUpdatingLocation];
//    [self.locationManager startUpdatingHeading];
    
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    
    NSString *AnnotationViewID = @"AnimatedAnnotation";
    BMKAnnotationView *annotationView = nil;
    if (annotationView == nil) {
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        annotationView.image=[UIImage imageNamed:@"mapapi.bundle/images/pin_red@2x"];
        if (annotation == _startAnnotation) {
          //  Icon_route_walk_start_without_floorId
            annotationView.image = [UIImage imageNamed:@"navigation.bundle/WalkNavi/NaviNormal/Icon_route_walk_start_without_floorId"];
        }
        if (annotation == _endAnnotation){
            annotationView.image = [UIImage imageNamed:@"navigation.bundle/WalkNavi/NaviNormal/Icon_route_walk_end_without_floorId"];
        }
    }
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
            }
          
        }}
    return annotationView;
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
#pragma mark 位置获取
-(void)myLocClick{
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
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
        llcell.timeLabel.text=model.SDState;
        llcell.infoLabel.text=model.add;
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
   
}
-(void)toPolice{
    NLCallPoliceViewController *call=[[NLCallPoliceViewController alloc] init];
    call.callBackBlock = ^{
         self.navigationController.navigationBar.hidden=YES;
    };
    [self.navigationController pushViewController:call animated:YES];
}
-(void)rightBtnClick{
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
-(void)notiBtnClick{
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
