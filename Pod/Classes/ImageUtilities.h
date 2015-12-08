//
//  ImageUtilities.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-14.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface ImageUtilities : NSObject

+(UIImage *)ThumbnailImageUrl:(NSString *)url Width:(float)width AndHeight:(float)height;
+(UIImage *)ThumbnailImage:(UIImage *)image Width:(float)width AndHeight:(float)height;
+(void)AddTapGestureDelegate:(id)target Selector:(SEL)selector ToImage:(UIImageView *)image;


+(UIImage *)ImageFromUrl:(NSString *)url;
+(void)ImageFromUrl:(NSString *)url completion: (void (^)(UIImage *))block;

+(UIImage *)CachedImageFromUrl:(NSString *)url;
+(void)CachedImageFromUrl:(NSString *)url completion: (void (^)(UIImage *))block;

+(UIImage *)ImageFromUrl:(NSString *)url default:(NSString *)namedImage;
+(UIImage *)CachedImageFromUrl:(NSString *)url default:(NSString *)namedImage;
+(void)ImageFromUrl:(NSString *)url default:(NSString *)namedImage completion: (void (^)(UIImage *))block;
+(void)CachedImageFromUrl:(NSString *)url default:(NSString *)namedImage completion: (void (^)(UIImage *))block;

+(UIImage *)ImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage;
+(UIImage *)CachedImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage;
+(void)ImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage completion: (void (^)(UIImage *))block;

+(UIImage *)CropImage:(UIImage *)image rect:(CGRect)rect;
+(void)CachedImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage completion: (void (^)(UIImage *))block;

@end
