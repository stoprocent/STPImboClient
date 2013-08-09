# STPImbo

STPImbo is a simple helper to create image URLs for [imbo](https://github.com/imbo/imbo) Image Server.

## Adding to Your Project

1. Add `STPImbo.h` and `STPImbo.m` to your project.

STPImbo requires ARC.

## Working with the STPImbo

First you need to set publicKey, privateKey and serversList

```objective-c
[[STPImbo client] setPublicKey:@"PUBLIC_KEY"];
[[STPImbo client] setPrivateKey:@"PRIVATE_KEY"];
[[STPImbo client] setServersList:@[@"http://server01",
                                   @"http://server02",
                                   @"http://server03",
                                   @"http://server04"]];
```

To get an image:

```objective-c
NSURL *url = [[[[STPImbo client] imageWithID:@"IMAGE_ID"] jpg] url]
NSString *path = [[[[STPImbo client] imageWithID:@"IMAGE_ID"] png] path]
```

You can chain transformations like this:

```objective-c
NSURL *url = [[[[[[[[STPImbo client] imageWithID:@"IMAGE_ID"] resize:CGSizeMake(2000, 0)] crop:CGRectMake(120,12,640, 960)] 
compress:100] desaturate] jpg] url];
```
STPImbo has the following class methods:

```objective-c
+ (STPImbo*)client;
- (id)initWithPublicKey:(NSString*)publicKey
             privateKey:(NSString*)privateKey
            serversList:(NSArray*)serversList;
- (STPImboImage*)imageWithID:(NSString*)imageID;
```

STPImboImage has the following class methods to work with images:

```objective-c
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
```

Easy as that. (See [STPImbo.h](https://github.com/stoprocent/STPImboClient/blob/master/STPImboClient/STPImbo/STPImbo.h) for all of the 
methods.)
