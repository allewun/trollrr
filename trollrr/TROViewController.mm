//
//  TROViewController.m
//  trollrr
//
//  Created by bp on 4/5/13.
//  Copyright (c) 2013 troll. All rights reserved.
//

#import "TROViewController.h"

using namespace cv;

@interface TROViewController ()

@end

@implementation TROViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
    for (CALayer *layer in self.imageView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  NSLog(@"picker");
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
//    {
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    else
//    {
//        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSArray *results = [self findFacesFromImage:image];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self drawResults:results];
        });
    });
    self.imageView.image = image;
    [picker dismissModalViewControllerAnimated:YES];
    
}

- (void)drawResults:(NSArray *)results {
    for (CIFaceFeature *f in results) {
        CALayer *layer = [CALayer layer];
        UIImage *maskImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"trollface1" ofType:@"png"]];
        layer.contents = (id)[maskImg CGImage];
        layer.frame = f.bounds;
        NSLog(@"%@",NSStringFromCGRect(f.bounds));
        [self.imageView.layer addSublayer:layer];
    }
    [self.imageView setNeedsDisplay];
}

- (NSArray *)findFacesFromImage:(UIImage *)image {
//    cv::Mat frame = [self cvMatFromUIImage:image];
//    std::vector<cv::Rect> faces;
//    Mat frame_gray;
//    cv::CascadeClassifier face_cascade;
//    
//    cvtColor( frame, frame_gray, CV_BGR2GRAY );
//    equalizeHist( frame_gray, frame_gray );
//    
//    // Detect faces
//    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0, cv::Size(80, 80) );
//    
//    NSLog(@"found %d",faces.size());
//    
//    for( int i = 0; i < faces.size(); i++ ) {
//        Mat faceROI = frame_gray( faces[i] );
//        std::vector<cv::Rect> eyes;
//
//        // Draw the face
//        cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
//        ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, Scalar( 255, 0, 0 ), 2, 8, 0 );
//    }
//    
//    return [self UIImageFromCVMat:frame];
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
    CIDetector* faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    NSDictionary* imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];
    NSArray* resultArray = [faceDetector featuresInImage:[CIImage imageWithCGImage:image.CGImage] options:imageOptions];
    NSLog(@"%@",resultArray);
    return resultArray;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)inputImage
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(inputImage.CGImage);
    CGFloat cols, rows;
    if (inputImage.imageOrientation == UIImageOrientationLeft || inputImage.imageOrientation == UIImageOrientationRight) {
        cols = inputImage.size.height;
        rows = inputImage.size.width;
    } else {
        cols = inputImage.size.width;
        rows = inputImage.size.height;
    }
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), inputImage.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

@end
