//
//  ImageUtilities.m
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-14.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "ImageUtilities.h"


@interface ImageUtilities()

    

@end

@implementation ImageUtilities

static NSOperationQueue *q;

+(UIImage *)ThumbnailImage:(UIImage *)image Width:(float)width AndHeight:(float)height{
    
    UIImage *theImage=image;
    CGSize sizeContraint = CGSizeMake(width, height);
    CGSize size = CGSizeMake(theImage.size.width, theImage.size.height);
    if(size.width>sizeContraint.width){
        float scale=size.width/sizeContraint.width;
        size.width=sizeContraint.width;
        size.height=size.height/scale;
    }
    if(size.height>sizeContraint.height){
        float scale=size.height/sizeContraint.height;
        size.height=sizeContraint.height;
        size.width=size.width/scale;
    }
    
    
    UIGraphicsBeginImageContext(size);
    
    [theImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return destImage;
    
}

+(NSOperationQueue *)GetQueue{
    if(q==nil){
        
        q= [[NSOperationQueue alloc] init];
        q.name = [NSString stringWithFormat:@"%s: Load Asyncronous Image",__PRETTY_FUNCTION__];
        [q setMaxConcurrentOperationCount:10];
    }
    
    return q;

}

+(UIImage *)ThumbnailImageUrl:(NSString *)url Width:(float)width AndHeight:(float)height{
    
    
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    UIImage *theImage = [UIImage imageWithData:imageData];
    return [ImageUtilities ThumbnailImage:theImage Width:width AndHeight:height];
}

+(void)AddTapGestureDelegate:(id)target Selector:(SEL)selector ToImage:(UIImageView *)image{
    image.userInteractionEnabled=TRUE;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [image addGestureRecognizer:tap];
}
+(UIImage *)CropImage:(UIImage *)image rect:(CGRect)rect{

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    // or use the UIImage wherever you like
    return [UIImage imageWithCGImage:imageRef];
}


+(UIImage *)ImageFromUrl:(NSString *)url{

    UIImage* theImage;
    NSString *iurl= [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //if(iurl!=nil&&[Variables HasKey:iurl]){
    //    theImage =[((UIImage *)[Variables GetObjectForKey:iurl]) copy];
    //}else{
        //image does not exists (for url name) in Variables, so this is the first time loading it.
        //TODO: move this into a concurrent loading thread, and check place marker on icon load. this will
        //save time during loading since the icons are currently loading while the app logo is displayed.
        
        if(iurl!=nil){
            
            
            
            
            
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: iurl]];
            theImage = [UIImage imageWithData:imageData];
        }
        if(theImage){
            //save the image into Variables storage, for reuse later.
            //[Variables SetObject:theImage ForKey:iurl];
            //NSLog(@"%@: Successfully loaded image: %@", [self class], iurl);
        }else{
            NSLog(@"%s: Failed to load image: %@", __PRETTY_FUNCTION__, iurl);
        }
    //}
    return theImage;
}
+(void)ImageFromUrl:(NSString *)url completion: (void (^)(UIImage *))block{
    
    [[ImageUtilities GetQueue] addOperationWithBlock:^{
        UIImage *i=[ImageUtilities ImageFromUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(i);
        });
    }];
}

+(UIImage *)GetCachedImage:(NSString *)url{

    NSString *path=[ImageUtilities ImagePathFromUrl:url];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    
    if(img){
        NSLog(@"%s: Loading Cached Image: %@",__PRETTY_FUNCTION__, url);
        return img;
    }
    return nil;
}

+(bool)CacheImage:(NSString *)url Image:(UIImage *)image{
    
    NSString *path=[ImageUtilities ImagePathFromUrl:url];
    
    NSError *directoryError;
    
    NSMutableArray *a=[NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]];
    [a removeLastObject];

    NSString *dir=[a componentsJoinedByString:@"/"];


    [[[NSFileManager alloc]init] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&directoryError];
    if(directoryError.code!=0){
        
        NSLog(@"%s: Directory Make Error: %@ %@",__PRETTY_FUNCTION__, directoryError, dir);
        
    }
    NSError *writeError;
    if([UIImagePNGRepresentation(image) writeToFile:path options:NSDataWritingAtomic error:&writeError]){
        return true;
    }else{
        NSLog(@"%s: Failed To Cache Image: %@, Error: %@", __PRETTY_FUNCTION__, path, writeError);
    }
    return false;
}


+(UIImage *)CachedImageFromUrl:(NSString *)url{

    UIImage *image=[ImageUtilities GetCachedImage:url];
    if(image)return image;
    
    image = [ImageUtilities ImageFromUrl:url];
    if(image)[ImageUtilities CacheImage:url Image:image];
    return image;
}
+(void)CachedImageFromUrl:(NSString *)url completion: (void (^)(UIImage *))block{
    
    [[ImageUtilities GetQueue] addOperationWithBlock:^{
        UIImage *i=[ImageUtilities CachedImageFromUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(i);
        });
    }];

}


+(UIImage *)ImageFromUrl:(NSString *)url default:(NSString *)namedImage{
    UIImage* theImage = [ImageUtilities ImageFromUrl:url];
    if(!theImage){
            //this should load the default icon stored in this project.
            theImage = [UIImage imageNamed:namedImage];
    }
    return theImage;
}

+(UIImage *)CachedImageFromUrl:(NSString *)url default:(NSString *)namedImage{
    UIImage *image=[ImageUtilities CachedImageFromUrl:url];
    if(image)return image;
    return [UIImage imageNamed:namedImage];
}

+(void)ImageFromUrl:(NSString *)url default:(NSString *)namedImage completion: (void (^)(UIImage *))block{
    [[ImageUtilities GetQueue] addOperationWithBlock:^{
        UIImage *i=[ImageUtilities ImageFromUrl:url default:namedImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(i);
        });
    }];
}
+(void)CachedImageFromUrl:(NSString *)url default:(NSString *)namedImage completion: (void (^)(UIImage *))block{
    [[ImageUtilities GetQueue] addOperationWithBlock:^{
        
        UIImage *image=[ImageUtilities CachedImageFromUrl:url];
        if(image){
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                block([UIImage imageNamed:namedImage]);
            });
        }
        
    }];
}

+(NSString *)ImagePathFromUrl:(NSString *)url{
    
    
    NSString *documentsPath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ImageCache"] stringByAppendingPathComponent:[[url stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""] ] stringByAppendingString:@".png"];
    
    NSLog(@"%s: Path For Images: %@",__PRETTY_FUNCTION__, documentsPath);
    return documentsPath;
}





+(UIImage *)ImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage{
    UIImage* theImage = [ImageUtilities ImageFromUrl:url];
    if(!theImage){
        //this should load the default icon stored in this project.
        theImage = defaultImage;
    }
    return theImage;
}

+(UIImage *)CachedImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage{
    UIImage *image=[ImageUtilities CachedImageFromUrl:url];
    if(image)return image;
    return defaultImage;
}

+(void)ImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage completion: (void (^)(UIImage *))block{
    [[ImageUtilities GetQueue] addOperationWithBlock:^{
        UIImage *i=[ImageUtilities ImageFromUrl:url defaultImage:defaultImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(i);
        });
    }];
}
+(void)CachedImageFromUrl:(NSString *)url defaultImage:(UIImage *)defaultImage completion: (void (^)(UIImage *))block{
    
    
   
    
    [[ImageUtilities GetQueue] addOperationWithBlock:^{
      
        UIImage *image=[ImageUtilities CachedImageFromUrl:url];
        if(image){
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                block(defaultImage);
            });
        }
        
    }];
}

@end
