//
//  NLHomeCarModel.h
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/22.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
`id` int(10)  '车辆id',
`licenseNum` varchar(30)  '车牌号',
`getFacDate` date '发卡时间',
`type` varchar(255)  '车型号',
`colour` varchar(255)  '车辆颜色',
`brand` varchar(255)  '车辆品牌',
`machineNo` varchar(10) '电机号',
`VIN` varchar(10) '车架号',
`buyDate` date  '购买日期',
`installDate` date '安装日期',
`buyAdd` varchar(255)  '购买地址',
`buyPrice` decimal(10, 2) '购买价格',
`picPath` varchar(255) '图片路径',
`remark` varchar(255) '车辆备注',
`uname` varchar(255) '车主姓名',
`phone` varchar(255)  '车主手机号',
`IDCardNo` varchar(255)  '车子身份证号',
`homeTele` varchar(255)  '家庭电话',
`IDAdd` varchar(255)  '身份证地址',
`homeAdd` varchar(255) '家庭地址',
`facNum` varchar(255)  '设备号',
`areaCode` varchar(255) '设备区域号',
`facType` varchar(255)  '设备类型',
`facPower` varchar(255)  '设备电量',
`sysManagerId` int(11) '登记人id',
`state` varchar(255)  '车状态',
`classify` int(4)  '电动车为1，巡逻车为0',
 */
@interface NLHomeCarModel : NSObject
//@property(nonatomic,copy)NSString *getfacdate;
//@property(nonatomic,copy)NSString *buydate;
//@property(nonatomic,copy)NSString *installdate;
//
//@property(nonatomic,assign)double buyprice;
//@property(nonatomic,assign)int sysmanagerid;
//@property(nonatomic,assign)int classify;
//@property(nonatomic,assign)int flag;
//
//@property(nonatomic,copy)NSString *userid;
@property(nonatomic,copy)NSString *id;
//@property(nonatomic,copy)NSString *uid;
//@property(nonatomic,copy)NSString *endTime;
//@property(nonatomic,copy)NSString *startTime;
//@property(nonatomic,copy)NSString *transfertime;
//@property(nonatomic,copy)NSString *transferuserphone;
//@property(nonatomic,copy)NSString *department;
//@property(nonatomic,copy)NSString *machineno;
//@property(nonatomic,copy)NSString *vin;
//@property(nonatomic,copy)NSString *buyadd;
@property(nonatomic,copy)NSString *picpath;
//@property(nonatomic,copy)NSString *mark;
//@property(nonatomic,copy)NSString *remark;
//@property(nonatomic,copy)NSString *uname;
//@property(nonatomic,copy)NSString *sname;
//@property(nonatomic,copy)NSString *phone;
//@property(nonatomic,copy)NSString *idcardno;
@property(nonatomic,copy)NSString *licensenum;
//@property(nonatomic,copy)NSString *facilityId;
@property(nonatomic,copy)NSString *color;
@property(nonatomic,copy)NSString *brand;
//@property(nonatomic,copy)NSString *homeTele;
//@property(nonatomic,copy)NSString *IDAdd;
//@property(nonatomic,copy)NSString *homeAdd;
//@property(nonatomic,copy)NSString *facnum;
//@property(nonatomic,copy)NSString *areacode;
//@property(nonatomic,copy)NSString *areaid;
//@property(nonatomic,copy)NSString *factype;
//@property(nonatomic,copy)NSString *facpower;
@property(nonatomic,copy)NSString *state;
//@property(nonatomic,copy)NSString *type;
@end

NS_ASSUME_NONNULL_END
