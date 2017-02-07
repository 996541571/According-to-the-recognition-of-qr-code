//
//  ViewController.m
//  longPress
//
//  Created by BEE22 on 15/12/29.
//  Copyright © 2015年 beeway10. All rights reserved.
//

#import "ViewController.h"

#define screen_width self.view.frame.size.width
#define screen_height self.view.frame.size.height

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
//测试图片
@property (weak, nonatomic) IBOutlet UIImageView *outImageView;
- (IBAction)getQRCodeFromAlbum:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    //初始化测试图片 
    _outImageView.layer.borderWidth = 2.0f;
    _outImageView.layer.borderColor = [UIColor redColor].CGColor; 
    UIImage *image = [UIImage imageNamed:@"testPic.jpg"];
    _outImageView.image = image;
    
    //添加手势
    UILongPressGestureRecognizer*longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(dealLongPress:)];
    [_outImageView addGestureRecognizer:longPress];
    [self.view addSubview:_outImageView];
}
#pragma mark-> 长按识别二维码
-(void)dealLongPress:(UIGestureRecognizer*)gesture{
    
    if(gesture.state==UIGestureRecognizerStateBegan){
        
        UIImageView*tempImageView=(UIImageView*)gesture.view;
        if(tempImageView.image){
            /**
             *      CIDetector              初始化扫描仪检测者
             *      detectorOfType          设别类型
             *      CIDetectorAccuracyHigh  识别质量（精度）
             */
            CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
            
            // 扫描获取的特征组，注意这里features可能为空最好判断一下
            NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:tempImageView.image.CGImage]];
            
            //获取扫描结果
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }else {
            
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:@"未检测到二维码特征" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    }else if (gesture.state==UIGestureRecognizerStateEnded){
        //长按完了可以做一些操作
    }
}
#pragma mark -> 相册提取
- (IBAction)getQRCodeFromAlbum:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        //1.初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //2.设置代理
        controller.delegate = self;
        //3.设置资源：
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //4.转场动画
        controller.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:NULL];
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark -> UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //1.获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //2.初始化一个监测器
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未检测到二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}
@end