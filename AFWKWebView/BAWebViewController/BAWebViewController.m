//
//  BAWebViewController.m
//  BABAWebViewController
//
//  Created by boai on 2017/6/13.
//  Copyright © 2017年 boai. All rights reserved.
//

#import "BAWebViewController.h"
#import "BAKit_WebView.h"
#import "BAAlertController.h"
#import "WMDragView.h"
#import "NetworkDetectController.h"


@interface BAWebViewController ()

@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) WKWebViewConfiguration *webConfig;
@property(nonatomic, strong) UIProgressView *progressView;

@property(nonatomic, strong) NSURL *ba_web_currentUrl;

@property(nonatomic,strong) WMDragView *dragView;
@property (nonatomic, strong) UIView *headView;

@end

@implementation BAWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    
    [self setupUI];
    [self setUIView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_isNavHidden == YES) {
        self.navigationController.navigationBarHidden = YES;
        //创建一个高20的假状态栏
//        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
//        //设置成绿色
//        statusBarView.backgroundColor=[UIColor whiteColor];
//        // 添加到 navigationBar 上
//        [self.view addSubview:statusBarView];
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
}


- (void)setupUI
{
    self.view.backgroundColor = BAKit_Color_White_pod;
    self.webView.hidden = NO;
    
    [self configBackItem];
    [self configMenuItem];
    
    BAKit_WeakSelf;
    self.webView.ba_web_didStartBlock = ^(WKWebView *webView, WKNavigation *navigation) {
        
//        BAKit_StrongSelf
        NSLog(@"开始加载网页");
    };
    
    self.webView.ba_web_didFinishBlock = ^(WKWebView *webView, WKNavigation *navigation) {
        NSLog(@"加载网页结束");
        
        // WKWebview 禁止长按(超链接、图片、文本...)弹出效果
        [webView ba_web_stringByEvaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none'" completionHandler:nil];
    };
    
    self.webView.ba_web_isLoadingBlock = ^(BOOL isLoading, CGFloat progress) {
        
        BAKit_StrongSelf
        [self ba_web_progressShow];
        self.progressView.progress = progress;
        if (self.progressView.progress == 1.0f)
        {
            [self ba_web_progressHidden];
        }
    };
    
    self.webView.ba_web_getTitleBlock = ^(NSString *title) {
        
        BAKit_StrongSelf
        // 获取当前网页的 title
        self.title = title;
    };
    
    self.webView.ba_web_getCurrentUrlBlock = ^(NSURL * _Nonnull currentUrl) {
        BAKit_StrongSelf
        self.ba_web_currentUrl = currentUrl;
    };
}


#pragma mark - 修改 navigator.userAgent
- (void)changeNavigatorUserAgent
{
    BAKit_WeakSelf
    [self.webView ba_web_stringByEvaluateJavaScript:@"navigator.userAgent" completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        BAKit_StrongSelf
        NSLog(@"old agent ----- :%@", result);
        NSString *userAgent = result;
        
        NSString *customAgent = @" native_iOS";
        if ([userAgent hasSuffix:customAgent])
        {
            NSLog(@"navigator.userAgent已经修改过了");
        }
        else
        {
            NSString *customUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"%@", customAgent]]; // 这里加空格是为了好看
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:customUserAgent, @"UserAgent", nil];
            [BAKit_NSUserDefaults registerDefaults:dictionary];
            [BAKit_NSUserDefaults synchronize];
            if (([[UIDevice currentDevice] systemVersion].floatValue >= 9.0)) {
                 [self.webView setCustomUserAgent:customUserAgent];
            }
           
            [self ba_reload];
        }

    }];
}

- (void)ba_reload
{
    [self.webView ba_web_reload];
//    [self changeNavigatorUserAgent];
}

- (void)ba_web_progressShow
{
    // 开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    // 开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    // 防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}

- (void)ba_web_progressHidden
{
    /*
     *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
     *动画时长0.25s，延时0.3s后开始动画
     *动画结束后将progressView隐藏
     */
    [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
    } completion:^(BOOL finished) {
        self.progressView.hidden = YES;
        
    }];
}

/**
 *  加载一个 webview
 *
 *  @param request 请求的 NSURL URLRequest
 */
- (void)ba_web_loadRequest:(NSURLRequest *)request
{
    [self.webView ba_web_loadRequest:request];
}

/**
 *  加载一个 webview
 *
 *  @param URL 请求的 URL
 */
- (void)ba_web_loadURL:(NSURL *)URL
{
    [self.webView ba_web_loadURL:URL];
}

/**
 *  加载一个 webview
 *
 *  @param URLString 请求的 URLString
 */
- (void)ba_web_loadURLString:(NSString *)URLString
{
    [self.webView ba_web_loadURLString:URLString];
}

/**
 *  加载本地网页
 *
 *  @param htmlName 请求的本地 HTML 文件名
 */
- (void)ba_web_loadHTMLFileName:(NSString *)htmlName
{
    [self.webView ba_web_loadHTMLFileName:htmlName];
}

/**
 *  加载本地 htmlString
 *
 *  @param htmlString 请求的本地 htmlString
 */
- (void)ba_web_loadHTMLString:(NSString *)htmlString
{
    [self.webView ba_web_loadHTMLString:htmlString];
}

/**
 *  加载 js 字符串，例如：高度自适应获取代码：
 // webView 高度自适应
 [self ba_web_stringByEvaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
 // 获取页面高度，并重置 webview 的 frame
 self.ba_web_currentHeight = [result doubleValue];
 CGRect frame = webView.frame;
 frame.size.height = self.ba_web_currentHeight;
 webView.frame = frame;
 }];
 *
 *  @param javaScriptString js 字符串
 */
- (void)ba_web_stringByEvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler
{
    [self.webView ba_web_stringByEvaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

#pragma mark - custom Method

#pragma mark 导航栏的返回按钮
- (void)configBackItem
{
    UIImage *backImage = [UIImage imageNamed:@"BAKit_WebView.bundle/navigationbar_back"];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *backBtn = [[UIButton alloc] init];
    //    [backBtn setTintColor:BAKit_ColorOrange];
    [backBtn setBackgroundImage:backImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn sizeToFit];
    
    UIBarButtonItem *colseItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = colseItem;
}

#pragma mark 导航栏的菜单按钮
- (void)configMenuItem
{
    UIImage *menuImage = [UIImage imageNamed:@"BAKit_WebView.bundle/navigationbar_more"];
    menuImage = [menuImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *menuBtn = [[UIButton alloc] init];
    //    [menuBtn setTintColor:BAKit_ColorOrange];
    [menuBtn setImage:menuImage forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [menuBtn sizeToFit];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = menuItem;
}

#pragma mark 导航栏的关闭按钮
- (void)configColseItem
{
    UIButton *colseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [colseBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [colseBtn setTitleColor:BAKit_Color_Black_pod forState:UIControlStateNormal];
    [colseBtn addTarget:self action:@selector(colseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [colseBtn sizeToFit];
    
    UIBarButtonItem *colseItem = [[UIBarButtonItem alloc] initWithCustomView:colseBtn];
    
    NSMutableArray *newArr = [NSMutableArray arrayWithObjects:self.navigationItem.leftBarButtonItem,colseItem, nil];
    self.navigationItem.leftBarButtonItems = newArr;
}

#pragma mark - 按钮点击事件
#pragma mark 返回按钮点击
- (void)backBtnAction:(UIButton *)sender
{
    if (self.webView.ba_web_canGoBack)
    {
        [self.webView ba_web_goBack];
        if (self.navigationItem.leftBarButtonItems.count == 1)
        {
            [self configColseItem];
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 菜单按钮点击
- (void)menuBtnAction:(UIButton *)sender
{
    BAKit_WeakSelf
    
    NSArray *buttonTitleArray = @[@"safari打开", @"复制链接", @"分享", @"刷新"];
    NSArray *buttonTitleColorArray = @[BAKit_Color_Red_pod, BAKit_Color_Green_pod, BAKit_Color_Yellow_pod, BAKit_Color_Orange_pod];
    
    [UIAlertController ba_actionSheetShowInViewController:self title:@"更多" message:nil buttonTitleArray:buttonTitleArray buttonTitleColorArray:buttonTitleColorArray popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
        
    } block:^(UIAlertController * _Nonnull alertController, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        BAKit_StrongSelf
        
        NSString *urlStr = self.ba_web_currentUrl.absoluteString;
        
        if (buttonIndex == 0)
        {
            if (urlStr.length > 0)
            {
                /*! safari打开 */
                BAKit_OpenUrl(urlStr);
                return;
            }
            else
            {
                BAKit_ShowAlertWithMsg_ios8(@"无法获取到当前 URL！");
            }
        }
        else if (buttonIndex == 1)
        {
            /*! 复制链接 */
            if (urlStr.length > 0)
            {
                BAKit_CopyContent(urlStr);
                BAKit_ShowAlertWithMsg_ios8(@"亲爱的，已复制URL到黏贴板中！");
                return;
            }
            else
            {
                BAKit_ShowAlertWithMsg_ios8(@"无法获取到当前 URL！");
            }
        }
        else if (buttonIndex == 2)
        {

        }
        else if (buttonIndex == 3)
        {
            /*! 刷新 */
            [self.webView ba_web_reload];
        }
        
    }];
}

#pragma mark 关闭按钮点击
- (void)colseBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.webView.frame = self.view.bounds;
    
//    self.webView.frame = CGRectMake(0, 0, BAKit_SCREEN_WIDTH, BAKit_SCREEN_HEIGHT);
    
    CGFloat height = self.view.bounds.size.height >= 812.0 ? 44 : 20;
    self.progressView.frame = CGRectMake(0, height, BAKit_SCREEN_WIDTH, 20);
}

#pragma mark - setter / getter

- (WKWebView *)webView
{
    if (!_webView)
    {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webConfig];
        //  添加 WKWebView 的代理，注意：用此方法添加代理
        
        [self.webView ba_web_initWithDelegate:self.webView uIDelegate:self.webView];
        _webView.ba_web_isAutoHeight = NO;
        self.webView.multipleTouchEnabled = YES;
        self.webView.autoresizesSubviews = YES;
        //        self.wkWebView.scrollView.alwaysBounceVertical = YES;
        
//        [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none'"];
        
//        [self.webView ba_web_stringByEvaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none'" completionHandler:nil];
        
        
        
        [self.view addSubview:self.webView];
        
//        [self changeNavigatorUserAgent];
    }
    return _webView;
}

- (WKWebViewConfiguration *)webConfig
{
    if (!_webConfig) {
        
        // 创建并配置WKWebView的相关参数
        // 1.WKWebViewConfiguration:是WKWebView初始化时的配置类，里面存放着初始化WK的一系列属性；
        // 2.WKUserContentController:为JS提供了一个发送消息的通道并且可以向页面注入JS的类，WKUserContentController对象可以添加多个scriptMessageHandler；
        // 3.addScriptMessageHandler:name:有两个参数，第一个参数是userContentController的代理对象，第二个参数是JS里发送postMessage的对象。添加一个脚本消息的处理器,同时需要在JS中添加，window.webkit.messageHandlers.<name>.postMessage(<messageBody>)才能起作用。
        
        _webConfig = [[WKWebViewConfiguration alloc] init];
        _webConfig.allowsInlineMediaPlayback = YES;
        
//        _webConfig.allowsPictureInPictureMediaPlayback = YES;
        
        // 通过 JS 与 webView 内容交互
        // 注入 JS 对象名称 senderModel，当 JS 通过 senderModel 来调用时，我们可以在WKScriptMessageHandler 代理中接收到
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        //        [userContentController addScriptMessageHandler:self name:@"BAShare"];
        _webConfig.userContentController = userContentController;
        
        // 初始化偏好设置属性：preferences
        _webConfig.preferences = [WKPreferences new];
        // The minimum font size in points default is 0;
//        _webConfig.preferences.minimumFontSize = 40;
        // 是否支持 JavaScript
        _webConfig.preferences.javaScriptEnabled = YES;
        // 不通过用户交互，是否可以打开窗口
        _webConfig.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    }
    return _webConfig;
}

- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        _progressView = [UIProgressView new];
        _progressView.tintColor = BAKit_Color_Green_pod;
        _progressView.trackTintColor = BAKit_Color_Gray_8_pod;
        
//        _progressView.backgroundColor =[UIColor redColor];
        
        self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);

        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (void)setBa_web_progressTintColor:(UIColor *)ba_web_progressTintColor
{
    _ba_web_progressTintColor = ba_web_progressTintColor;

    self.progressView.progressTintColor = ba_web_progressTintColor;
}

- (void)setBa_web_progressTrackTintColor:(UIColor *)ba_web_progressTrackTintColor
{
    _ba_web_progressTrackTintColor = ba_web_progressTrackTintColor;

    self.progressView.trackTintColor = ba_web_progressTrackTintColor;
}

- (void)dealloc
{
    [self.webView removeFromSuperview];
    [self.progressView removeFromSuperview];
    self.webView = nil;
    self.webConfig = nil;
    self.progressView = nil;
    self.ba_web_currentUrl = nil;
}

- (BOOL)willDealloc
{
    return NO;
}





#pragma mark -  浮动按钮
- (void)setUIView {
    CGFloat width = 55;
    self.dragView = [[WMDragView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    [self.dragView.button setBackgroundImage:[UIImage imageNamed:@"drag_btn_back"] forState:UIControlStateNormal];
//    self.dragView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.dragView];
    
    CGFloat height = self.view.bounds.size.height -(self.view.bounds.size.height >= 812.0 ? 34 : 0);
    CGRect rect = CGRectMake(self.view.bounds.size.width -width -10, height - 260, width, width);
    self.dragView.frame = rect;
    
    self.dragView.layer.cornerRadius = width/2;
    self.dragView.layer.masksToBounds = YES;
    self.dragView.layer.borderWidth = 1;
    self.dragView.layer.borderColor = [UIColor purpleColor].CGColor;

    __weak typeof(self) weakSelf = self;
    self.dragView.clickDragViewBlock = ^(WMDragView *dragView){
//        [weakSelf actionSheepView];
        [weakSelf showUIAlertController];
//        NSLog(@"clickDragViewBlock");
    };

    self.dragView.beginDragBlock = ^(WMDragView *dragView) {
        NSLog(@"开始拖曳");
    };

    self.dragView.endDragBlock = ^(WMDragView *dragView) {
        NSLog(@"结束拖曳");
    };

    self.dragView.duringDragBlock = ^(WMDragView *dragView) {
        NSLog(@"拖曳中...");
    };
}



/**
 *  系统 - UIAlertController demo
 */
- (void)showUIAlertController {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"]; ; // 获取项目版本号
    NSString *versionStr = [NSString stringWithFormat:@"Sikkimbet %@", version];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:versionStr message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"UIAlertController - 取消");
    }];
    
    UIAlertAction *aa1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Home", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakSelf reloadWebView];
        // 重新加载网页
        [weakSelf ba_web_loadURLString:kWebRequestUrl];
    }];
    UIAlertAction *aa2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Network diagnosis", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"-");
        
        
        [weakSelf webNetworkDetect];
        // 重新加载网页
        //        [weakSelf ba_web_loadURLString:kWebRequestUrl];
    }];
    UIAlertAction *aa3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Option line", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reloadWebView];
    }];
    UIAlertAction *aa4 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear cache", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reloadWebView];
    }];
    UIAlertAction *aa5 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open with broswer", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf skipToSafari];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:aa1];
    [alertController addAction:aa2];
    [alertController addAction:aa3];
    [alertController addAction:aa4];
    [alertController addAction:aa5];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -  网络诊断
- (void)webNetworkDetect {
    
    NetworkDetectController *vc = [[NetworkDetectController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)skipToSafari
{
   NSURL *url = [NSURL URLWithString:kWebRequestUrl];
    
    [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:^(BOOL success) {
    //成功后的回调
        if (!success) {
            //失败后的回调
        }
    }];
}

- (void)reloadWebView {
    /// 强制刷新
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.location.reload(true);"] completionHandler:^(id _Nullable obj, NSError * _Nullable error) {

    }];
}




@end
