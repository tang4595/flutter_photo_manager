#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef double Similarity;

@interface ImageSimilarity : NSObject

- (void)setImgWithImgA:(UIImage*)imgA ImgB:(UIImage*)imgB;
- (void)setImgAWidthImg:(UIImage*)img;
- (void)setImgBWidthImg:(UIImage*)img;
- (Similarity)imageSimilarityValue;
+ (Similarity)imageSimilarityValueWithImgA:(UIImage*)imga ImgB:(UIImage*)imgb;

@end
