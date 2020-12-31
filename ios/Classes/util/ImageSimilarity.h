#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef double Similarity;

@interface ImageSimilarity : NSObject

- (void)setImgWithImgA:(UIImage *)imgA
                  ImgB:(UIImage *)imgB
                imgaId:(NSString *)imgaId
                imgbId:(NSString *)imgbId;
- (void)setImgAWidthImg:(UIImage *)img;
- (void)setImgBWidthImg:(UIImage *)img;
- (Similarity)imageSimilarityValue;

/// Id用于缓存该对象的指纹关联的唯一标识，避免重复计算增加耗时.
+ (Similarity)imageSimilarityValueWithImgA:(UIImage *)imga
                                      ImgB:(UIImage *)imgb
                                    imgaId:(NSString *)imgaId
                                    imgbId:(NSString *)imgbId;

@end
