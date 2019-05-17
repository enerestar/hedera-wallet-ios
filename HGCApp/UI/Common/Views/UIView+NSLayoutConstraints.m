//
//  UIView+NSLayoutConstraints.m
//  HGCApp
//
//  Created by Surendra  on 23/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

#import "UIView+NSLayoutConstraints.h"

@implementation UIView (NSLayoutConstraintsUtility)

-(void)addContentView:(UIView *)view{
    [self addContentView:view inset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

-(void)addContentView:(UIView *)view inset:(UIEdgeInsets)inset{
    
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%.2f)-[view]-(%.2f)-|",inset.left,inset.right]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%.2f)-[view]-(%.2f)-|",inset.top,inset.bottom]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
}

-(void)setConstraintEquivalentToFrame:(CGRect)frame forceLayout:(BOOL)forceLayout{
    if (!self.superview) return;
    
    if (isnan(frame.origin.x) || frame.origin.x == INFINITY)
        frame.origin.x = 0;
    if (isnan(frame.origin.y) || frame.origin.y == INFINITY)
        frame.origin.y = 0;
    if (isnan(frame.size.width) || frame.size.width == INFINITY)
        frame.size.width = 0;
    if (isnan(frame.size.height) || frame.size.height == INFINITY)
        frame.size.height = 0;
    
    UIView *superView = self.superview;
    NSMutableArray *superConstraints = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in superView.constraints) {
        if (constraint.firstItem == self || constraint.secondItem == self) {
            [superConstraints addObject:constraint];
        }
    }
    
    [superView removeConstraints:superConstraints];
    
    NSMutableArray *selfConstraints = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth || constraint.secondAttribute == NSLayoutAttributeWidth || constraint.firstAttribute == NSLayoutAttributeHeight || constraint.secondAttribute == NSLayoutAttributeHeight) {
            [selfConstraints addObject:constraint];
        }
    }
    
    [superView removeConstraints:superConstraints];
    [self removeConstraints:selfConstraints];
    
    UIView *view = self;
    [superView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%.2f)-[view]",frame.origin.x]
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(view)]];
    [superView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%.2f)-[view]",frame.origin.y]
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(view)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[view(==%.2f)]",frame.size.height]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[view(==%.2f)]",frame.size.width]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
    if (forceLayout) {
        [superView setNeedsLayout];
        [superView layoutIfNeeded];
    }
}

-(void)setConstraintEquivalentToFrame:(CGRect)frame{
    [self setConstraintEquivalentToFrame:frame forceLayout:YES];
}

-(NSLayoutConstraint *)widthConstraint{
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth || constraint.secondAttribute == NSLayoutAttributeWidth) {
            return constraint;
        }
    }
    return nil;
}

-(NSLayoutConstraint *)heightConstraint{
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight || constraint.secondAttribute == NSLayoutAttributeHeight) {
            return constraint;
        }
    }
    return nil;
}

@end
