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

@implementation CRURLProtocol_SDWebImageCache

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    NSString *path = request.URL.path;
    // Catch the Image URL
    if ([path hasSuffix:@".jpg"] || [path hasSuffix:@".jpeg"] || [path hasSuffix:@".webp"]||[path hasSuffix:@".png"]||[path hasSuffix:@".gif"]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
    NSData *data = [[SDImageCache sharedImageCache] diskImageDataBySearchingAllPathsForKey:key];
    
    if (data) {
        [self p_updateImageData:data];
        NSLog(@"\nCatch the cache:%@ \n\n",self.request.URL);
    } else {
        self.operation = [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:self.request.URL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            
            [self p_updateImageData:data];
            
            if (image) {
                NSLog(@"\nCache success:%@\n\n",self.request.URL);
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



#pragma mark - Private Metod 
- (void)p_updateImageData:(NSData *)data {
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
}


@end
