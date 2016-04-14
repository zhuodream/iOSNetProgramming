//
//  PostViewContentViewController.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "PostViewContentViewController.h"
#import "Utils.h"
#import "BrowserViewController.h"
#import "TweetsTableViewController.h"

@interface PostViewContentViewController ()

- (void)tweetButtonTapped:(id)sender;
- (void)postHeaderTapped:(id)sender;

@end

@implementation PostViewContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.post.title;
    
    UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweets" style:UIBarButtonItemStylePlain target:self action:@selector(tweetButtonTapped:)];
    self.navigationItem.rightBarButtonItem = tweetButton;
    
    NSString *headerContent = [NSString stringWithFormat:@"%@\n%@%@", self.post.title, self.post.pubDate, self.post.author];
    CGSize constraint = CGSizeMake(280, MAXFLOAT);
    CGRect headerSize = [headerContent boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]} context:nil];
    CGRect frame = headerSize;
    frame.size.height += 12;
    headerSize = frame;
    // create the header content
    NSMutableString *postHeaderContent = [[NSMutableString alloc] init];
    [postHeaderContent appendFormat:@"<html><body>"];
    [postHeaderContent appendFormat:@"<head><style>body{background-color:#f4f4f4; margin:0px; padding:5px 10px 5px 10px;} .title{font-weight:bold; font-size:18px;} .meta{font-size:12px;} .meta .subtitle{font-weight:bold;}</style></head>"];
    [postHeaderContent appendFormat:@"<div class='title'>%@</div>", _post.title];
    [postHeaderContent appendFormat:@"<div class='meta'><span class='subtitle'>Published:</span> %@</div>", [Utils prettyStringFromDate:_post.pubDate]];
    [postHeaderContent appendFormat:@"<div class='meta'><span class='subtitle'>Author:</span> %@</div>", _post.author];
    [postHeaderContent appendFormat:@"</body></html>"];
    
    // create the post header
    UIWebView *postHeader = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        self.view.frame.size.width,
                                                                        headerSize.size.height)];
    [postHeader loadHTMLString:postHeaderContent baseURL:nil];
    postHeader.backgroundColor = [UIColor clearColor];
    postHeader.scrollView.scrollEnabled = NO;
    // add a recognizer so we can display the post source url
    UIGestureRecognizer *tappedRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(postHeaderTapped:)];
    tappedRecognizer.delegate = self;
    postHeader.gestureRecognizers = [NSArray arrayWithObject:tappedRecognizer];
    
    [self.view addSubview:postHeader];
    
    // set our post content
    UIWebView *postContent = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                                         headerSize.size.height,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height-44-headerSize.size.height)]; // 93 = 44 nav bar + 49 tab bar
    [postContent loadHTMLString:_post.content baseURL:nil];
    NSLog(@"_post.content = %@", _post.content);
    postContent.scrollView.contentInset = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
    postContent.backgroundColor = [UIColor whiteColor];
    postContent.scrollView.showsHorizontalScrollIndicator = NO;
    postContent.delegate = self;
    postContent.tag = 2;
    [self.view addSubview:postContent];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tweetButtonTapped:(id)sender
{
    TweetsTableViewController *tvc = [[TweetsTableViewController alloc] init];
    tvc.post = self.post;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:tvc];
    [self.tabBarController presentViewController:nc animated:YES completion:nil];
}

- (void)postHeaderTapped:(id)sender
{
    BrowserViewController *bv = [[BrowserViewController alloc] init];
    bv.url = [NSURL URLWithString:self.post.contentURL];
    [self.navigationController pushViewController:bv animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark = UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        BrowserViewController *bv = [[BrowserViewController alloc] init];
        bv.url = [request URL];
        [self.navigationController pushViewController:bv animated:YES];
        return NO;
    }
    return YES;
}

@end
