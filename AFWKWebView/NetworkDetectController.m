//
//  ViewController.m
//  AFWKWebView
//
//  Created by lvan Lewis on 2019/12/5.
//  Copyright © 2019 AFan. All rights reserved.
//

#import "NetworkDetectController.h"
#import "LDNetDiagnoService.h"

@interface NetworkDetectController () <LDNetDiagnoServiceDelegate, UITextFieldDelegate> {
    UIActivityIndicatorView *_indicatorView;
    UIButton *btn;
    UITextView *_txtView_log;
    UITextField *_txtfield_dormain;

    NSString *_logInfo;
    LDNetDiagnoService *_netDiagnoService;
    BOOL _isRunning;
}

@end

@implementation NetworkDetectController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark -  复制
/// 复制
- (void)rightBtnAction {
    NSString *text = _txtView_log.text;
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    pastboard.string = text;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"网络诊断";
    
    
    // nav按钮  nav文字
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"复制" style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBtnAction)];
    // 字体颜色
    [rightBtn setTintColor:[UIColor blackColor]];
    // 字体大小
    [rightBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    
    
    
    CGFloat navHeight = self.view.bounds.size.height >= 812.0 ? 88 : 64;

    _indicatorView = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(self.view.bounds.size.width/2 -15, navHeight, 30, 30);
    _indicatorView.hidden = NO;
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView stopAnimating];
//    _indicatorView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_indicatorView];
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
//    self.navigationItem.rightBarButtonItem = rightItem;


    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10.0f, navHeight + 15, 100.0f, 50.0f);
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btn.titleLabel setNumberOfLines:2];
    [btn setTitle:@"开始诊断" forState:UIControlStateNormal];
    [btn addTarget:self
                  action:@selector(startNetDiagnosis)
        forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [self.view addSubview:btn];


    _txtfield_dormain =
        [[UITextField alloc] initWithFrame:CGRectMake(130.0f, navHeight + 15, 180.0f, 50.0f)];
    _txtfield_dormain.delegate = self;
    _txtfield_dormain.returnKeyType = UIReturnKeyDone;
//    _txtfield_dormain.text = @"www.baidu.com";
    _txtfield_dormain.text = kWebRequestUrl;
    
    [self.view addSubview:_txtfield_dormain];


    _txtView_log = [[UITextView alloc] initWithFrame:CGRectZero];
    _txtView_log.layer.borderWidth = 1.0f;
    _txtView_log.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _txtView_log.backgroundColor = [UIColor whiteColor];
    _txtView_log.font = [UIFont systemFontOfSize:12.0f];
    _txtView_log.textAlignment = NSTextAlignmentLeft;
    _txtView_log.scrollEnabled = YES;
    _txtView_log.editable = NO;
    _txtView_log.frame =
        CGRectMake(0.0f, navHeight + 15 + 10 + 50, self.view.frame.size.width, self.view.frame.size.height - 120.0f);
    [self.view addSubview:_txtView_log];

    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"]; ; // 获取项目版本号
    NSString *versionStr = [NSString stringWithFormat:@"Sikkimbet %@", version];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    _netDiagnoService = [[LDNetDiagnoService alloc] initWithAppCode:@"诊断"
                                                            appName:@"网络诊断应用"
                                                         appVersion:versionStr
                                                             userID:@"无"
                                                           deviceID:nil
                                                            dormain:_txtfield_dormain.text
                                                        carrierName:nil
                                                     ISOCountryCode:nil
                                                  MobileCountryCode:nil
                                                      MobileNetCode:nil];
    _netDiagnoService.delegate = self;
    _isRunning = NO;
    
    
    [self performSelector:@selector(startNetDiagnosis) withObject:nil afterDelay:0.5];
}


- (void)startNetDiagnosis
{
    [_txtfield_dormain resignFirstResponder];
    _netDiagnoService.dormain = _txtfield_dormain.text;
    if (!_isRunning) {
        [_indicatorView startAnimating];
        [btn setTitle:@"停止诊断" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
        [btn setUserInteractionEnabled:FALSE];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
        _txtView_log.text = @"";
        _logInfo = @"";
        _isRunning = !_isRunning;
        [_netDiagnoService startNetDiagnosis];
    } else {
        [_indicatorView stopAnimating];
        _isRunning = !_isRunning;
        [btn setTitle:@"开始诊断" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
        [btn setUserInteractionEnabled:FALSE];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
        [_netDiagnoService stopNetDialogsis];
    }
}

- (void)delayMethod
{
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setUserInteractionEnabled:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NetDiagnosisDelegate
- (void)netDiagnosisDidStarted
{
    NSLog(@"开始诊断～～～");
}

- (void)netDiagnosisStepInfo:(NSString *)stepInfo
{
    NSLog(@"%@", stepInfo);
    _logInfo = [_logInfo stringByAppendingString:stepInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        _txtView_log.text = _logInfo;
    });
}


- (void)netDiagnosisDidEnd:(NSString *)allLogInfo;
{
    NSLog(@"logInfo>>>>>\n%@", allLogInfo);
    //可以保存到文件，也可以通过邮件发送回来
    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicatorView stopAnimating];
        [btn setTitle:@"开始诊断" forState:UIControlStateNormal];
        _isRunning = NO;
    });
}

- (void)emailLogInfo
{
    [_netDiagnoService printLogInfo];
}


#pragma mark -
#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end

