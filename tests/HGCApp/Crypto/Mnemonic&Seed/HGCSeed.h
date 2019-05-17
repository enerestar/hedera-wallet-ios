//
//  HGCSeed.h
//  HGCApp
//
//  Created by Surendra  on 16/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGCSeed : NSObject

@property (nonatomic, readonly) NSData *entropy;

+ (instancetype) seedWithEntropy:(NSData *)entropy; // 32 Bytes
+ (instancetype) seedWithWords:(NSArray<NSString *> *)words; // 22 words
+ (instancetype) seedWithBip39Words:(NSArray<NSString *> *)words; // 24 words


- (NSArray<NSString *> *)toWords;
- (NSArray<NSString *> *)toBIP39Words;

@end
