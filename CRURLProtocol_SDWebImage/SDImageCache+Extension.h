//
//  SDImageCache+Extension.h
//  CRURLProtocol_SDWebImage
//
//  Created by Corotata on 16/12/17.
//  Copyright © 2016年 Corotata. All rights reserved.
//

#import <SDWebImage/SDImageCache.h>

@interface SDImageCache (Extension)

- (NSData *)diskImageDataBySearchingAllPathsForKey:(NSString *)key;

@end
