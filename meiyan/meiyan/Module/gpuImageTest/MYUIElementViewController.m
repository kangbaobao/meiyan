//
//  MYUIElementViewController.m
//  meiyan
//
//  Created by kzw on 2020/6/2.
//  Copyright © 2020 康子文. All rights reserved.
//

#import "MYUIElementViewController.h"
#import "GPUImage.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
@interface MYUIElementViewController ()
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}
@property (nonatomic , strong) UILabel  *mLabel;

@end

@implementation MYUIElementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
        self.view = filterView;
        
        self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 88, 100, 100)];
        self.mLabel.textColor = [UIColor redColor];
        [self.view addSubview:self.mLabel];
        
        // 滤镜
        filter = [[GPUImageDissolveBlendFilter alloc] init];
        [(GPUImageDissolveBlendFilter *)filter setMix:0.5];
        
        // 播放
        NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"output" withExtension:@"mp4"];
        AVAsset *asset = [AVAsset assetWithURL:sampleURL];
        CGSize size = self.view.bounds.size;
        movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
        movieFile.runBenchmark = YES;
        movieFile.playAtActualSpeed = YES;
        
    //    movieFile.delegate = self;
        
        // 水印
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        label.text = @"添加文字水印";
        label.font = [UIFont systemFontOfSize:30];
        label.textColor = [UIColor redColor];
        [label sizeToFit];

        UIImage *image = [UIImage imageNamed:@"discover_select"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        subView.backgroundColor = [UIColor clearColor];
        imageView.center = CGPointMake(subView.bounds.size.width / 2, subView.bounds.size.height / 2);
        [subView addSubview:imageView];
        [subView addSubview:label];
        
        GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
        
    //    GPUImageTransformFilter 动画的filter
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
        NSLog(@"pathToMovie : %@",pathToMovie);
        unlink([pathToMovie UTF8String]);
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        
        movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
        
        GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    
        [movieFile addTarget:progressFilter];
        [progressFilter addTarget:filter];
        [uielement addTarget:filter];
        
        movieWriter.shouldPassthroughAudio = YES;
        movieFile.audioEncodingTarget = movieWriter;
        [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
        // 显示到界面
        [filter addTarget:filterView];
        [filter addTarget:movieWriter];
        
        [movieWriter startRecording];
        [movieFile startProcessing];
      
         CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
        [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [dlink setPaused:NO];
        
        __weak typeof(self) weakSelf = self;
        
        [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
            dispatch_async(dispatch_get_main_queue(), ^{
                  CGRect frame = imageView.frame;
                  frame.origin.x += 1;
                  frame.origin.y += 1;
                  imageView.frame = frame;
                //  [self updateProgress];
                  [uielement updateWithTimestamp:time];
            });

        }];
        
        [movieWriter setCompletionBlock:^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf->filter removeTarget:strongSelf->movieWriter];
            [strongSelf->movieWriter finishRecording];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie))
            {
                [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{

                         if (error) {
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                             [alert show];
                         } else {
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                             [alert show];
                         }
                     });
                 }];
            }
            else {
                NSLog(@"error mssg)");
            }
        }];
}

- (void)updateProgress
{
    [self.view bringSubviewToFront:self.mLabel];

    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(movieFile.progress * 100)];
    [self.mLabel sizeToFit];
}
//- (void)didCompletePlayingMovie{
//    NSLog(@"播放完成");
//}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
