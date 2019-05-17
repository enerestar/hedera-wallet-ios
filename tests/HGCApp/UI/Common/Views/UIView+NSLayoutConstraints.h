//
//  UIView+NSLayoutConstraints.h
//  HGCApp
//
//  Created by Surendra  on 23/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (NSLayoutConstraintsUtility)

// Add view to receiver's child view and add necessory constraints to make horizontal, vertical, top and bottom space = 0
-(void)addContentView:(UIView *)view;

-(void)addContentView:(UIView *)view inset:(UIEdgeInsets)inset;

// set constraint and force layout
-(void)setConstraintEquivalentToFrame:(CGRect)frame;

// for animations use forceLayout = NO and layout manually in animation block
-(void)setConstraintEquivalentToFrame:(CGRect)frame forceLayout:(BOOL)forceLayout;

-(NSLayoutConstraint *)widthConstraint;
-(NSLayoutConstraint *)heightConstraint;

@end
