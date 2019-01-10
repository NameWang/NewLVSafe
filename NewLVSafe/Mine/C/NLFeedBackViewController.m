//
//  NLFeedBackViewController.m
//  NewLVSafe
//
//  Created by 何心晓 on 2018/11/30.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import "NLFeedBackViewController.h"
#import "XMTextView.h"
#import "UITextView+XMExtension.h"
#import "FeedBackTableViewCell.h"
#import "FeedBackModel.h"
@interface NLFeedBackViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    UISegmentedControl *segment;
    UITableView *carListTableView;
    NSMutableArray *dataSource;
    UIButton *sendBtn;
    UIView *line,*bgView;
    UITextView *textV;
}

@end

@implementation NLFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"个人信息";
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    segment=[[UISegmentedControl alloc] initWithItems:@[@"提反馈",@"我的反馈"] ];
    segment.frame=CGRectMake(0, 0, kScreenWidth, 30*kScale);
    segment.tintColor=[UIColor whiteColor];
    [segment addTarget:self action:@selector(segmentClick:) forControlEvents:(UIControlEventValueChanged)];
    //设置Segment的字体
    NSDictionary *dic = @{
                          //1.设置字体样式:例如黑体,和字体大小
                          //  NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:20],
                          //2.字体颜色
                          NSForegroundColorAttributeName:[UIColor blackColor]
                          };
    
    [segment setTitleTextAttributes:dic forState:UIControlStateNormal];
    NSDictionary *dic2=@{  NSForegroundColorAttributeName:kBlueColor};
    [segment setTitleTextAttributes:dic2 forState:(UIControlStateSelected)];
    segment.selectedSegmentIndex=0;
    [self.view addSubview:segment];
    line=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segment.frame)-1, kScreenWidth/2, 1)];
    line.backgroundColor=[UIColor redColor];
    [self.view addSubview:line];
    //
    dataSource=[NSMutableArray array];
    [self initFeedView];
    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [textV resignFirstResponder];
    
}
-(void)resetFrameWithHeight:(CGFloat)height{
  textV.frame = CGRectMake(15, 10, kScreenWidth-30, 200-height);
    sendBtn.frame=CGRectMake(10, CGRectGetMaxY(textV.frame)+15, kScreenWidth-20, 30);
}
#pragma mark -键盘监听方法
- (void)keyboardWasShown:(NSNotification *)notification
{
    // 获取键盘的高度
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat heigh=bgView.frame.size.height-CGRectGetMaxY(sendBtn.frame);
    if (heigh>frame.size.height) {
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            
            [self resetFrameWithHeight:frame.size.height-heigh];
        }];
        
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [textV resignFirstResponder];
}
- (void)keyboardWillBeHiden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        
        [self resetFrameWithHeight:0];
    }];
    
}

-(void)segmentClick:(UISegmentedControl*)seg{
    __weak UIView *lll=line;
    __weak UISegmentedControl*sss=segment;
    if (seg.selectedSegmentIndex==0) {
        [carListTableView removeFromSuperview];
      //  [self initFeedView];
        [UIView animateWithDuration:0.2 animations:^{
            lll.frame=CGRectMake(0, CGRectGetMaxY(sss.frame)-1, kScreenWidth/2, 1);
        }];
     
    }else{
      //  [bgView removeFromSuperview];
          [textV resignFirstResponder];
          [self initTableView];
        [UIView animateWithDuration:0.2 animations:^{
            lll.frame=CGRectMake(kScreenWidth/2, CGRectGetMaxY(sss.frame)-1, kScreenWidth/2, 1);
        }];
        [carListTableView reloadData];
    }
    
}
-(void)initFeedView{
    bgView=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segment.frame)+2, kScreenWidth, kScreenHeight-kiPhoneX_Bottom_Height-104-segment.frame.size.height)];
    bgView.backgroundColor=kBGWhiteColor;
    textV = [[UITextView alloc] init];
    textV.delegate=self;
    textV.frame = CGRectMake(15, 10, kScreenWidth-30, 200*kScale);
    textV.placeholder = @"您的建议与反馈是我们前进的动力";
    textV.placeholderColor = [UIColor grayColor];
    textV.textColor = [UIColor blackColor];
    textV.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:textV];
    sendBtn=[UIButton normalBtnWithFrame:CGRectMake(10, CGRectGetMaxY(textV.frame)+15, kScreenWidth-20, 30*kScale) title:@"发送" size:17 color:[UIColor grayColor] superView:bgView];
    [sendBtn addTarget:self action:@selector(sendClick) forControlEvents:(UIControlEventTouchUpInside)];
    [sendBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    sendBtn.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
}
-(void)sendClick{
    if (textV.text.length>5) {
          [textV resignFirstResponder];
    }
}
-(void)initTableView{
    carListTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segment.frame)+2, kScreenWidth, kScreenHeight-kiPhoneX_Bottom_Height-64-segment.frame.size.height) style:(UITableViewStylePlain)];
    [carListTableView registerNib:[UINib nibWithNibName:@"FeedBackTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedBackTableViewCell"];
    [carListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    carListTableView.backgroundColor=kBGWhiteColor;
    carListTableView.delegate=self;
    carListTableView.dataSource=self;
    carListTableView.tableFooterView=[[UIView alloc] init];
    [self.view addSubview:carListTableView];
    carListTableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
}
-(void)refresh{
    [carListTableView reloadData];
    [carListTableView.mj_header endRefreshing];
}
#pragma mark tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    if (dataSource.count>0) {
        FeedBackModel *model=dataSource[indexPath.row];
        FeedBackTableViewCell *carcell=[tableView dequeueReusableCellWithIdentifier:@"FeedBackTableViewCell" forIndexPath:indexPath];
        carcell.titLabel.text=model.title;
        carcell.bodyLabel.text=model.body;
        carcell.timeLabel.text=model.time;
        cell=carcell;
    }else{
        UITableViewCell *nocell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
        nocell.textLabel.textAlignment=NSTextAlignmentCenter;
        nocell.textLabel.numberOfLines=0;
        nocell.textLabel.textColor=[UIColor grayColor];
        nocell.textLabel.text=@"空空如也\n快去提交反馈吧";
        nocell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell=nocell;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (dataSource.count>0) {
        return 60;
    }else{
        return tableView.frame.size.height;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dataSource.count>0) {
        return dataSource.count;
    }else{
        return 1;
    }
    
}
-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length>5) {
        [sendBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        sendBtn.backgroundColor=kBlueColor;
    }else{
        [sendBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        sendBtn.backgroundColor=[UIColor whiteColor];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
