//
//  TROViewController.h
//  trollrr
//
//  Created by bp on 4/5/13.
//  Copyright (c) 2013 troll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <opencv2/opencv.hpp>
#import <QuartzCore/QuartzCore.h>

@interface TROViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
