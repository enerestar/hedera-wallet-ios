//
//  HGCKeyProtocol.h
//  HGCApp
//
//  Created by Surendra  on 19/04/18.
//  Copyright © 2018 HGC. All rights reserved.
//

@protocol HGCKeyPairProtocol

@property (readonly) NSData *publicKeyData;
@property (readonly) NSData *privateKeyData;

- (NSData *)signMessage:(NSData *)message;
- (BOOL) verify:(NSData*)signature message:(NSData*)message;

@end

@protocol HGCKeyChainProtocol

- (id <HGCKeyPairProtocol>)keyAtIndex:(NSInteger)index;

@end
