//
//  ImagePreviewCell.h
//  ImageSearch
//
//  Created by VA Gautham  on 30-6-14.
//  Copyright (c) 2014 Gautham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingImageIndicator;

@end
