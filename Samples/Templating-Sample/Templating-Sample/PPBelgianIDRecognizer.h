//
//  PPBelgianIDRecognizer.h
//  Templating-Sample
//
//  Created by Jura on 01/09/2019.
//  Copyright © 2019 Dino. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Microblink/Microblink.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPBelgianIDRecognizer : NSObject

- (PPBlinkOcrRecognizerSettings *)ocrRecognizerSettings;

- (NSString *)documentNumberFromRecognizerResult:(PPBlinkOcrRecognizerResult *)result;

- (NSString *)classifyDocumentFromResult:(PPTemplatingRecognizerResult *)result;

- (UIImage *)facePhotoForImageMetadata:(PPImageMetadata *)metadata;

@end

NS_ASSUME_NONNULL_END
