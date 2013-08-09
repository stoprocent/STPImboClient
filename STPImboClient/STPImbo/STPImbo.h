//
//  STPImbo.h
//  STPImboImage
//  STPImbo
//
//  Created by Marek Serafin on 8/8/13.
//  Copyright (c) 2013 Schibsted Tech Polska. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, STPImboCanvasMode) {
    STPImboCanvasModeFree,
    STPImboCanvasModeCenter,
    STPImboCanvasModeCenterX,
    STPImboCanvasModeCenterY
};

typedef NS_ENUM(NSInteger, STPImboThumbnailFit) {
    STPImboThumbnailFitInset,
    STPImboThumbnailFitOutbound
};

typedef NS_ENUM(NSInteger, STPImboBorderMode) {
    STPImboBorderModeInline,
    STPImboBorderModeOutbound
};

typedef NS_ENUM(NSInteger, STPImboImageExtension) {
    STPImboImageExtensionNONE,
    STPImboImageExtensionJPG,
    STPImboImageExtensionPNG,
    STPImboImageExtensionGIF
};

@class STPImboImage;

@interface STPImbo : NSObject

@property (nonatomic, strong, readwrite) NSString *publicKey;
@property (nonatomic, strong, readwrite) NSString *privateKey;
@property (nonatomic, assign, readwrite) NSArray *serversList;

+ (STPImbo*)client;

- (id)initWithPublicKey:(NSString*)publicKey
             privateKey:(NSString*)privateKey
            serversList:(NSArray*)serversList;

- (STPImboImage*)imageWithID:(NSString*)imageID;

@end

@interface STPImboImage : NSObject

@property (nonatomic, strong, readonly) NSString *imageID;
@property (nonatomic, strong, readonly) NSMutableArray *params;
@property (nonatomic, assign, readonly) STPImboImageExtension imageExtension;

- (id)initWithID:(NSString*)imageID;
- (STPImboImage*)border;
- (STPImboImage*)border:(CGSize)size;
- (STPImboImage*)border:(CGSize)size
                  color:(UIColor*)color;
- (STPImboImage*)border:(CGSize)size
                  color:(UIColor*)color
                   mode:(STPImboBorderMode)mode;
- (STPImboImage*)crop:(CGRect)rect;
- (STPImboImage*)canvas:(CGRect)rect;
- (STPImboImage*)canvas:(CGRect)rect
                   mode:(STPImboCanvasMode)mode;
- (STPImboImage*)canvas:(CGRect)rect
                   mode:(STPImboCanvasMode)mode
                  color:(UIColor*)color;
- (STPImboImage*)resize:(CGSize)size;
- (STPImboImage*)maxSize:(CGSize)size;
- (STPImboImage*)compress:(CGFloat)quality;
- (STPImboImage*)rotate:(CGFloat)angle;
- (STPImboImage*)rotate:(CGFloat)angle
                  color:(UIColor*)color;
- (STPImboImage*)sepia;
- (STPImboImage*)sepiaThreshold:(CGFloat)threshold;
- (STPImboImage*)thumbnail:(CGSize)size
                      mode:(STPImboThumbnailFit)fit;
- (STPImboImage*)desaturate;
- (STPImboImage*)flipHorizontally;
- (STPImboImage*)flipVertically;
- (STPImboImage*)transpose;
- (STPImboImage*)transverse;
- (STPImboImage*)jpg;
- (STPImboImage*)png;
- (STPImboImage*)gif;
- (NSString*)path;
- (NSURL*)url;

@end