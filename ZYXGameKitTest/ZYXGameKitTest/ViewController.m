//
//  ViewController.m
//  ZYXGameKitTest
//
//  Created by 卓酉鑫 on 16/5/11.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()<GKPeerPickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *customIV;
@property (nonatomic, strong) GKSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender
{
    GKPeerPickerController *peerPK = [[GKPeerPickerController alloc] init];
    peerPK.delegate = self;
    [peerPK show];
}

- (IBAction)selectedPhoto:(id)sender
{
    UIImagePickerController *imagePK = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        imagePK.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePK.delegate = self;
        
        [self presentViewController:imagePK animated:YES completion:nil];
    }
}

- (IBAction)send:(id)sender
{
    UIImage *image = self.customIV.image;
    NSData *data = UIImagePNGRepresentation(image);
    
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.customIV.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GKPeerPickerControllerDelegate

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    NSLog(@"peerId = %@", peerID);
    
    self.session = session;
    
    [self.session setDataReceiveHandler:self withContext:nil];
    [picker dismiss];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    NSLog(@"%s", __func__);
    
    UIImage *image = [UIImage imageWithData:data];
    self.customIV.image = image;
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    NSLog(@"取消");
}


@end
