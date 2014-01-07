//
//  CKBlurView.m
//  CKBlurView
//
//  Created by Conrad Kramer on 10/25/13.
//  Copyright (c) 2013 Kramer Software Productions, LLC. All rights reserved.
//
//  MRC-Augmented by Julian Weiss on 1/4/14.
//  Copyright (c) 2014 Julian Weiss.
//  

#import <QuartzCore/QuartzCore.h>

#import "CKBlurView.h"

@interface CABackdropLayer : CALayer

@end

@interface CKBlurView ()

@property (retain, nonatomic) CAFilter *blurFilter;

@property (retain, nonatomic) CAFilter *colorFilter;

@end

extern NSString * const kCAFilterGaussianBlur;

NSString * const CKBlurViewQualityDefault = @"default";

NSString * const CKBlurViewQualityLow = @"low";

static NSString * const CKBlurViewQualityKey = @"inputQuality";

static NSString * const CKBlurViewRadiusKey = @"inputRadius";

static NSString * const CKBlurViewBoundsKey = @"inputBounds";

static NSString * const CKBlurViewHardEdgesKey = @"inputHardEdges";


@implementation CKBlurView

+(Class)layerClass {
    return [CABackdropLayer class];
}

-(CKBlurView *)commonInit{
    CAFilter *filter = [CAFilter filterWithName:kCAFilterGaussianBlur];
    self.layer.filters = @[ filter ];
    self.blurFilter = filter;

    self.blurQuality = CKBlurViewQualityDefault;
    self.blurRadius = 5.0f;   

    return self;
}

-(instancetype)init{
    self = [super init];
    return [self commonInit];
}

-(instancetype)initWithFrame:(CGRect)frame{
   [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleVisible) name:@"CKToggleVisible" object:nil];

    self = [super initWithFrame:frame];
    return [self commonInit];
}

-(void)toggleVisible{
    [self setHidden:!self.hidden];
}

-(void)setTintColorFilter:(CAFilter *)filter{
    self.colorFilter = filter;
    self.layer.filters = @[ self.colorFilter , self.blurFilter ];
}

-(void)setQuality:(NSString *)quality{
    [self.blurFilter setValue:quality forKey:CKBlurViewQualityKey];
}

-(NSString *)quality{
    return [self.blurFilter valueForKey:CKBlurViewQualityKey];
}

-(void)setBlurRadius:(CGFloat)radius{
    [self.blurFilter setValue:@(radius) forKey:CKBlurViewRadiusKey];
}

-(CGFloat)blurRadius{
    return [[self.blurFilter valueForKey:CKBlurViewRadiusKey] floatValue];
}

-(void)setBlurCroppingRect:(CGRect)croppingRect{
    [self.blurFilter setValue:[NSValue valueWithCGRect:croppingRect] forKey:CKBlurViewBoundsKey];
}

-(CGRect)blurCroppingRect{
    NSValue *value = [self.blurFilter valueForKey:CKBlurViewBoundsKey];
    return value ? [value CGRectValue] : CGRectNull;
}

-(void)setBlurEdges:(BOOL)blurEdges{
    [self.blurFilter setValue:@(!blurEdges) forKey:CKBlurViewHardEdgesKey];
}

-(BOOL)blurEdges{
    return ![[self.blurFilter valueForKey:CKBlurViewHardEdgesKey] boolValue];
}

-(void)dealloc{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
 
    _blurFilter = nil;
    _colorFilter = nil;
    _blurQuality = nil;

    [_blurFilter release];
    [_colorFilter release];
    [_blurQuality release];
    [super dealloc];
}

@end