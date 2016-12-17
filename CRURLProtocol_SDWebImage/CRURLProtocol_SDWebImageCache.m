//
//  CRURLProtocol_SDWebImageCache.m
//  CRURLProtocol_SDWebImage
//
//  Created by Corotata on 16/12/17.
//  Copyright © 2016年 Corotata. All rights reserved.
//

#import "CRURLProtocol_SDWebImageCache.h"

#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/NSData+ImageContentType.h>

#import "SDImageCache+Extension.h"

@interface CRURLProtocol_SDWebImageCache()
@property (nonatomic, strong) id<SDWebImageOperation> operation;
@end

static NSString * const WebviewImageProtocolHandledKey = @"WebviewImageProtocolHandledKey";

@implementation CRURLProtocol_SDWebImageCache

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    NSString *path = request.URL.path;
    // 只处理是图片的URL请求
    if ([path hasSuffix:@".jpg"] || [path hasSuffix:@".jpeg"] || [path hasSuffix:@".webp"]||[path hasSuffix:@".png"]||[path hasSuffix:@".gif"]) {
        if ([NSURLProtocol propertyForKey:WebviewImageProtocolHandledKey inRequest:request]) {
            return NO;
        }
        NSLog(@"%@\n\n\n",request.URL);
        return YES;
    }
    return NO;
    
    //    NSString* extension = request.URL.pathExtension;
    //    BOOL isImage = [@[@"png", @"jpeg", @"gif", @"jpg"] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //        return [extension compare:obj options:NSCaseInsensitiveSearch] == NSOrderedSame;
    //    }] != NSNotFound;
    //    BOOL result = [NSURLProtocol propertyForKey:WebviewImageProtocolHandledKey inRequest:request] == nil && isImage;
    //    NSLog(@"%@___isImage:%d___result:%d\n\n",request.URL,isImage,result);
    //    return result;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    //查看本地是否已经缓存了图片
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
    
    NSData *data = [[SDImageCache sharedImageCache] diskImageDataBySearchingAllPathsForKey:key];
    
    
    if (data) {
        NSString *mimeType = [NSData sd_contentTypeForImageData:data];
        NSMutableDictionary *header = [[NSMutableDictionary alloc] initWithCapacity:2];
        NSString *contentType = [mimeType stringByAppendingString:@";charset=UTF-8"];
        header[@"Content-Type"] = contentType;
        header[@"Content-Length"] = [NSString stringWithFormat:@"%lu", (unsigned long) data.length];
        
        NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                      statusCode:200
                                                                     HTTPVersion:@"1.1"
                                                                    headerFields:header];
        
        [self.client URLProtocol:self didReceiveResponse:httpResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
        
        NSLog(@"\n-------------------命中缓存:%@-------------------------\n",self.request.URL);
        
        
        
    } else {
        self.operation = [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:self.request.URL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            
            NSString *mimeType = [NSData sd_contentTypeForImageData:data];
            NSMutableDictionary *header = [[NSMutableDictionary alloc] initWithCapacity:2];
            NSString *contentType = [mimeType stringByAppendingString:@";charset=UTF-8"];
            header[@"Content-Type"] = contentType;
            header[@"Content-Length"] = [NSString stringWithFormat:@"%lu", (unsigned long) data.length];
            
            NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                          statusCode:200
                                                                         HTTPVersion:@"1.1"
                                                                        headerFields:header];
            
            [self.client URLProtocol:self didReceiveResponse:httpResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
            
            if (image) {
                NSLog(@"\n-------------------缓存成功:%@-------------------------\n",self.request.URL);
                [[SDImageCache sharedImageCache] storeImage:image
                                       recalculateFromImage:NO
                                                  imageData:data
                                                     forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL]
                                                     toDisk:YES];
            }
        }];
        
    }
}

- (void)stopLoading {
    [self.operation cancel];
}


@end
