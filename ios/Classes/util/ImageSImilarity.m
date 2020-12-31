#import "ImageSimilarity.h"

#define ImgSizeA 30
#define ImgSizeB 100

typedef enum workday {
    SizeA,
    SizeB,
} ImageSimilarityType;


@interface ImageSimilarity()

@property (nonatomic,assign) Similarity similarity;
@property (nonatomic,strong) UIImage *imga;
@property (nonatomic,strong) UIImage *imgb;
@property (nonatomic,strong) NSString *imgaId;
@property (nonatomic,strong) NSString *imgbId;

@end

@implementation ImageSimilarity

static NSMutableDictionary *_imageCharacteristics; //灰度值数组缓存容器

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imga = [[UIImage alloc] init];
        self.imgb = [[UIImage alloc] init];
        if (!_imageCharacteristics) {
            _imageCharacteristics = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)setImgWithImgA:(UIImage *)imgA
                  ImgB:(UIImage *)imgB
                imgaId:(NSString *)imgaId
                imgbId:(NSString *)imgbId
{
    _imga = imgA;
    _imgb = imgB;
    _imgaId = imgaId;
    _imgbId = imgbId;
}

- (void)setImgAWidthImg:(UIImage *)img
{
    self.imga = img;
}

- (void)setImgBWidthImg:(UIImage *)img
{
    self.imgb = img;
}

- (Similarity)imageSimilarityValue
{
    //self.similarity = MAX([self imageSimilarityValueWithType:SizeA], [self imageSimilarityValueWithType:SizeB]);
    self.similarity = [self imageSimilarityValueWithType:SizeA];//(优化)暂不交叉对比取最大相似度，节省1/2计算时间
    return self.similarity;
}

/// Id用于缓存该对象的指纹关联的唯一标识，避免重复计算增加耗时.
+ (Similarity)imageSimilarityValueWithImgA:(UIImage *)imga
                                      ImgB:(UIImage *)imgb
                                    imgaId:(NSString *)imgaId
                                    imgbId:(NSString *)imgbId
{
    ImageSimilarity *imageSimilarity = [[ImageSimilarity alloc] init];
    [imageSimilarity setImgWithImgA:imga ImgB:imgb imgaId:imgaId imgbId:imgbId];
    return [imageSimilarity imageSimilarityValue];
}

- (Similarity)imageSimilarityValueWithType:(ImageSimilarityType)type;
{
    int cursize = (type == SizeA ? ImgSizeA : ImgSizeB);
    int ArrSize = cursize * cursize + 1,a[ArrSize],b[ArrSize],i,j,grey,sum = 0;
    //CGSize size = {cursize,cursize};
    //UIImage * imga = [self reSizeImage:self.imga toSize:size];
    //UIImage * imgb = [self reSizeImage:self.imgb toSize:size]; //缩小图片尺寸
    //(优化)暂不缩放图片，本项目在外部传入数据源时已通过缩放获取缩略图，避免重复操作耗时
    
    CGPoint point;
    const int* cachedA = (const int*)((NSData *)[_imageCharacteristics valueForKey:_imgaId]).bytes;
    const int* cachedB = (const int*)((NSData *)[_imageCharacteristics valueForKey:_imgbId]).bytes;
    
    if (NULL != cachedA) {
        for (int i = 0; i < ArrSize; i++) {
            a[i] = cachedA[i];
        }
    } else {
        a[ArrSize] = 0;
        for (i = 0 ; i < cursize; i++) { //计算a的灰度
            for (j = 0; j < cursize; j++) {
                point.x = i;
                point.y = j;
                grey = ToGrey([self UIcolorToRGB:[self colorAtPixel:point img:self.imga]]);//(优化)[imga]暂不缩放以节省大约0.05s计算时间
                a[cursize * i + j] = grey;
                a[ArrSize] += grey;
            }
        }
        a[ArrSize] /= (ArrSize - 1); //灰度平均值
        for (i = 0 ; i < ArrSize ; i++) //灰度分布计算
        {
            a[i] = (a[i] < a[ArrSize] ? 0 : 1);
        }
        
        //缓存灰度值数组
        NSData *valueA = [NSData dataWithBytes:a length:sizeof(int)*ArrSize];
        [_imageCharacteristics setValue:valueA forKeyPath:_imgaId];
    }
    
    if (NULL != cachedB) {
        for (int i = 0; i < ArrSize; i++) {
            b[i] = cachedB[i];
        }
    } else {
        b[ArrSize] = 0;
        for (i = 0 ; i < cursize; i++) { //计算b的灰度
            for (j = 0; j < cursize; j++) {
                point.x = i;
                point.y = j;
                grey = ToGrey([self UIcolorToRGB:[self colorAtPixel:point img:self.imgb]]);//(优化)[imgb]暂不缩放以节省大约0.05s计算时间
                b[cursize * i + j] = grey;
                b[ArrSize] += grey;
            }
        }
        b[ArrSize] /= (ArrSize - 1); //灰度平均值
        for (i = 0 ; i < ArrSize ; i++) //灰度分布计算
        {
            b[i] = (b[i] < b[ArrSize] ? 0 : 1);
        }
        
        //缓存灰度值数组
        NSData *valueB = [NSData dataWithBytes:b length:sizeof(int)*ArrSize];
        [_imageCharacteristics setValue:valueB forKeyPath:_imgbId];
    }
    
    // 汇总指纹对比数据
    ArrSize -= 1;
    for (i = 0 ; i < ArrSize ; i++)
    {
        sum += (a[i] == b[i] ? 1 : 0);
    }

    return sum * 1.0 / ArrSize;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize //重新设定图片尺寸
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

unsigned int ToGrey(unsigned int rgb) //RGB计算灰度
{
    unsigned int blue   = (rgb & 0x000000FF) >> 0;
    unsigned int green  = (rgb & 0x0000FF00) >> 8;
    unsigned int red    = (rgb & 0x00FF0000) >> 16;
    return ( red*38 +  green * 75 +  blue * 15 )>>7;
}

- (unsigned int)UIcolorToRGB:(UIColor*)color //UIColor转16进制RGB
{
    unsigned int RGB,R,G,B;
    RGB = R = G = B = 0x00000000;
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    R = r * 256 ;
    G = g * 256 ;
    B = b * 256 ;
    RGB = (R << 16) | (G << 8) | B ;
    return RGB;
}

- (UIColor *)colorAtPixel:(CGPoint)point img:(UIImage *)img{ //获取指定point位置的RGB
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, img.size.width, img.size.height), point)) { return nil; }

    NSInteger   pointX  = trunc(point.x);
    NSInteger   pointY  = trunc(point.y);
    CGImageRef  cgImage = img.CGImage;
    NSUInteger  width   = img.size.width;
    NSUInteger  height  = img.size.height;
    int bytesPerPixel   = 4;
    int bytesPerRow     = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    // Convert color values [0..255] to floats [0.0..1.0]

    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
