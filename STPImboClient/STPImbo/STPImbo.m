//
//  STPImboClient.m
//  STPImboClient
//
//  Created by Marek Serafin on 8/8/13.
//  Copyright (c) 2013 Schibsted Tech Polska. All rights reserved.
//

static NSString* const kSTPImboParamsBorder             = @"border";
static NSString* const kSTPImboParamsCanvas             = @"canvas";
static NSString* const kSTPImboParamsCompress           = @"compress";
static NSString* const kSTPImboParamsConvert            = @"convert";
static NSString* const kSTPImboParamsCrop               = @"crop";
static NSString* const kSTPImboParamsDesaturate         = @"desaturate";
static NSString* const kSTPImboParamsFlipHorizontally   = @"flipHorizontally";
static NSString* const kSTPImboParamsFlipVertically     = @"flipVertically";
static NSString* const kSTPImboParamsMaxSize            = @"maxSize";
static NSString* const kSTPImboParamsResize             = @"resize";
static NSString* const kSTPImboParamsRotate             = @"rotate";
static NSString* const kSTPImboParamsSepia              = @"sepia";
static NSString* const kSTPImboParamsThumbnail          = @"thumbnail";
static NSString* const kSTPImboParamsTranspose          = @"transpose";
static NSString* const kSTPImboParamsTransverse         = @"transverse";

static NSString* const kSTPImboServerImagePathFormat    = @"%@/users/%@/images/%@.%@?";

#import "STPImbo.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation STPImbo

#pragma mark - Client singleton

+ (STPImbo*)client
{
    static STPImbo * _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [STPImbo new];
    });
    return _sharedObject;
}

#pragma mark - STPImbo

- (id)initWithPublicKey:(NSString*)publicKey
             privateKey:(NSString*)privateKey
            serversList:(NSArray*)serversList
{
    if(self = [super init]) {
        self.publicKey = publicKey;
        self.privateKey = privateKey;
        self.serversList = serversList;
    }
    return self;
}

- (STPImboImage*)imageWithID:(NSString*)imageID
{
    STPImboImage *image = [[STPImboImage alloc] initWithID:imageID];
    return image;
}

@end

@interface STPImboImage ()

@property (nonatomic, strong, readwrite) NSString *imageID;
@property (nonatomic, strong, readwrite) NSMutableArray *params;
@property (nonatomic, assign, readwrite) STPImboImageExtension imageExtension;

@end

@implementation STPImboImage

- (id)initWithID:(NSString*)imageID
{
    if(self = [super init]) {
        self.imageID = imageID;
        self.params = [NSMutableArray new];
        self.imageExtension = STPImboImageExtensionNONE;
    }
    return self;
}

- (STPImboImage*)border
{
    [_params addObject:@{ kSTPImboParamsBorder: @"" }];
    return self;
}

- (STPImboImage*)border:(CGSize)size
{
    [_params addObject:@{ kSTPImboParamsBorder: [NSString stringWithFormat:@"width=%.f,height=%.f",
                                                 size.width,
                                                 size.height] }];
    return self;
}

- (STPImboImage*)border:(CGSize)size
                  color:(UIColor*)color
{
    [_params addObject:@{ kSTPImboParamsBorder: [NSString stringWithFormat:@"width=%.f,height=%.f,color=%@",
                                                 size.width,
                                                 size.height,
                                                 [[self class] _hexStringFromColor:color]] }];
    return self;
}

- (STPImboImage*)border:(CGSize)size
                  color:(UIColor*)color
                   mode:(STPImboBorderMode)mode
{
    [_params addObject:@{ kSTPImboParamsBorder: [NSString stringWithFormat:@"width=%.f,height=%.f,color=%@,mode=%@",
                                                 size.width,
                                                 size.height,
                                                 [[self class] _hexStringFromColor:color],
                                                 [[self class] _imboBorderMode:mode]] }];
    return self;
}

- (STPImboImage*)crop:(CGRect)rect
{
    [_params addObject:@{ kSTPImboParamsCrop: [NSString stringWithFormat:@"x=%.f,y=%.f,width=%.f,height=%.f",
                                               rect.origin.x,
                                               rect.origin.y,
                                               rect.size.width,
                                               rect.size.height] }];
    return self;
}

- (STPImboImage*)canvas:(CGRect)rect
{
    [_params addObject:@{ kSTPImboParamsCanvas: [NSString stringWithFormat:@"x=%.f,y=%.f,width=%.f,height=%.f",
                                                 rect.origin.x,
                                                 rect.origin.y,
                                                 rect.size.width,
                                                 rect.size.height] }];
    return self;
}

- (STPImboImage*)canvas:(CGRect)rect
                   mode:(STPImboCanvasMode)mode
{
    [_params addObject:@{ kSTPImboParamsCanvas: [NSString stringWithFormat:@"x=%.f,y=%.f,width=%.f,height=%.f,mode=%@",
                                                 rect.origin.x,
                                                 rect.origin.y,
                                                 rect.size.width,
                                                 rect.size.height,
                                                 [[self class] _imboCanvasMode:mode]] }];
    return self;
}

- (STPImboImage*)canvas:(CGRect)rect
                   mode:(STPImboCanvasMode)mode
                  color:(UIColor*)color
{
    [_params addObject:@{ kSTPImboParamsCanvas: [NSString stringWithFormat:@"x=%.f,y=%.f,width=%.f,height=%.f,mode=%@,color=%@",
                                                 rect.origin.x,
                                                 rect.origin.y,
                                                 rect.size.width,
                                                 rect.size.height,
                                                 [[self class] _imboCanvasMode:mode],
                                                 [[self class] _hexStringFromColor:color]] }];
    return self;
}

- (STPImboImage*)resize:(CGSize)size
{
    NSString *format = [[self class] _sizeFormatWithSize:size];
    [_params addObject:@{ kSTPImboParamsResize: format }];
    
    return self;
}

- (STPImboImage*)maxSize:(CGSize)size
{
    NSString *format = [[self class] _sizeFormatWithSize:size];
    [_params addObject:@{ kSTPImboParamsMaxSize: format }];
    
    return self;
}

- (STPImboImage*)compress:(CGFloat)quality
{
    [_params addObject:@{ kSTPImboParamsCompress: [NSString stringWithFormat:@"quality=%.f",
                                                   quality] }];
    return self;
}

- (STPImboImage*)rotate:(CGFloat)angle
{
    [_params addObject:@{ kSTPImboParamsRotate: [NSString stringWithFormat:@"angle=%.f",
                                                 angle] }];
    return self;
}

- (STPImboImage*)rotate:(CGFloat)angle
                  color:(UIColor*)color
{
    [_params addObject:@{ kSTPImboParamsRotate: [NSString stringWithFormat:@"angle=%.f,bg=%@",
                                                 angle,
                                                 [[self class] _hexStringFromColor:color]] }];
    return self;
}

- (STPImboImage*)sepia
{
    [_params addObject:@{ kSTPImboParamsSepia: @""}];
    return self;
}

- (STPImboImage*)sepiaThreshold:(CGFloat)threshold;
{
    [_params addObject:@{ kSTPImboParamsSepia: [NSString stringWithFormat:@"threshold=%.f",
                                                threshold] }];
    return self;
}

- (STPImboImage*)thumbnail:(CGSize)size
                      mode:(STPImboThumbnailFit)fit
{
    [_params addObject:@{ kSTPImboParamsThumbnail: [NSString stringWithFormat:@"width=%.f,height=%.f,mode=%@",
                                                    size.width,
                                                    size.height,
                                                    [[self class] _imboThumbnailFit:fit]] }];
    return self;
}

- (STPImboImage*)desaturate
{
    [_params addObject:@{ kSTPImboParamsDesaturate: @""}];
    return self;
}

- (STPImboImage*)flipHorizontally
{
    [_params addObject:@{ kSTPImboParamsFlipHorizontally: @""}];
    return self;
}

- (STPImboImage*)flipVertically
{
    [_params addObject:@{ kSTPImboParamsFlipVertically: @""}];
    return self;
}

- (STPImboImage*)transpose
{
    [_params addObject:@{ kSTPImboParamsTranspose: @""}];
    return self;
}

- (STPImboImage*)transverse
{
    [_params addObject:@{ kSTPImboParamsTransverse: @""}];
    return self;
}

- (STPImboImage*)jpg
{
    self.imageExtension = STPImboImageExtensionJPG;
    return self;
}

- (STPImboImage*)png
{
    self.imageExtension = STPImboImageExtensionPNG;
    return self;
}

- (STPImboImage*)gif
{
    self.imageExtension = STPImboImageExtensionGIF;
    return self;
}

- (NSString*)path
{
    NSString *serverUrl;
    if([[[STPImbo client] serversList] count] > 1) {
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString: [_imageID substringWithRange:NSMakeRange(0,2)] ];
        
        if(![scanner scanHexInt:&result]) {
            return nil;
        }
        
        serverUrl = [[[STPImbo client] serversList] objectAtIndex:(result % 10)];
    }
    else if([[[STPImbo client] serversList] count] > 0)
    {
        serverUrl = [[[STPImbo client] serversList] objectAtIndex: 0];
    }
    else {
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:kSTPImboServerImagePathFormat,
                     serverUrl,
                     [[STPImbo client] publicKey],
                     _imageID,
                     [[self class] _imboImageExtension:self.imageExtension]];
    
    NSMutableArray *elements = [NSMutableArray array];
    for(NSDictionary *trans in _params) {
        NSArray *keys = [trans allKeys];
        for (NSString *key in keys) {
            NSString *params;
            if([trans[key] isEqualToString:@""]) {
                params = [NSString stringWithFormat:@"%@", key];
            }else{
                params = [NSString stringWithFormat:@"%@:%@", key, trans[key]];
            }
            
            [elements addObject:[NSString stringWithFormat:@"t[]=%@", [[self class] _urlString: params
                                                                           encodeUsingEncoding: NSUTF8StringEncoding]]];
        }
    }
    
    url = [url stringByAppendingString:[elements componentsJoinedByString:@"&"]];
    url = [url stringByAppendingFormat:@"&accessToken=%@",
           [[self class] _accessTokenFromURL:url
                             usingPrivateKey:[[STPImbo client] privateKey]]];

    return url;
}

- (NSURL*)url
{
    return [NSURL URLWithString:[self path]];
}

#pragma mark - STPImboImage (Private Helpers)

+ (NSString*)_sizeFormatWithSize:(CGSize)size
{
    NSString *format;
    if(size.width <= 0) {
        format = [NSString stringWithFormat: @"height=%.f", size.height];
    }
    else if (size.height <= 0) {
        format = [NSString stringWithFormat: @"width=%.f", size.width];
    }
    else {
        format = [NSString stringWithFormat: @"width=%.f,height=%.f", size.width, size.height];
    }
    return format;
}

+ (NSString *)_accessTokenFromURL:(NSString *)url
                  usingPrivateKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [url cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString   stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
}

+(NSString *)_urlString:(NSString*)string
    encodeUsingEncoding:(NSStringEncoding)encoding
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

+ (NSString*)_imboCanvasMode:(STPImboCanvasMode)mode
{
    NSString *modeString;
    switch (mode) {
        case STPImboCanvasModeCenter:
            modeString = @"center";
            break;
            
        case STPImboCanvasModeCenterX:
            modeString = @"center-x";
            break;
            
        case STPImboCanvasModeCenterY:
            modeString = @"center-y";
            break;
            
        case STPImboCanvasModeFree:
        default:
            modeString = @"free";
            break;
    }
    return modeString;
}

+ (NSString*)_imboImageExtension:(STPImboImageExtension)extensions
{
    NSString *ext;
    switch (extensions) {
        case STPImboImageExtensionPNG:
            ext = @"png";
            break;
            
        case STPImboImageExtensionGIF:
            ext = @"gif";
            break;
        
        case STPImboImageExtensionNONE:
        case STPImboImageExtensionJPG:
        default:
            ext = @"jpg";
            break;
    }
    return ext;
}

+ (NSString*)_imboBorderMode:(STPImboBorderMode)mode
{
    NSString *modeString;
    switch (mode) {
        case STPImboBorderModeInline:
            modeString = @"inline";
            break;
            
        case STPImboBorderModeOutbound:
        default:
            modeString = @"outbound";
            break;
    }
    return modeString;
}

+ (NSString*)_imboThumbnailFit:(STPImboThumbnailFit)fit
{
    NSString *fitString;
    switch (fit) {
        case STPImboThumbnailFitInset:
            fitString = @"inset";
            break;
            
        case STPImboThumbnailFitOutbound:
        default:
            fitString = @"outbound";
            break;
    }
    return fitString;
}

+ (NSString *)_hexStringFromColor:(UIColor *)color
{
    const NSUInteger totalComponents = CGColorGetNumberOfComponents( [color CGColor] );
    const CGFloat *components = CGColorGetComponents( [color CGColor] );
    NSString *hexadecimal = nil;
    
    switch ( totalComponents )
    {
        case 4 :
            hexadecimal = [NSString stringWithFormat: @"%02X%02X%02X" , (int)(255 * components[0]) , (int)(255 * components[1]) , (int)(255 * components[2])];
            break;
            
        case 2 :
            hexadecimal = [NSString stringWithFormat: @"%02X%02X%02X" , (int)(255 * components[0]) , (int)(255 * components[0]) , (int)(255 * components[0])];
            break;
            
        default:
            break;
    }
    return hexadecimal;
}

@end
