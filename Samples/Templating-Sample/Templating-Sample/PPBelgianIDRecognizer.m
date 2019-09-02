//
//  PPBelgianIDRecognizer.m
//  Templating-Sample
//
//  Created by Jura on 01/09/2019.
//  Copyright © 2019 Dino. All rights reserved.
//

#import "PPBelgianIDRecognizer.h"

static NSString *ID_DOCUMENT_NUMBER_GROUP = @"DocumentNumberGroup";

static NSString *ID_DOCUMENT_NUMBER = @"DocumentNumber";

static NSString *ID_FACE = @"Belgian.Face";

static NSString *CLASS_ID = @"belgianID";

@interface PPBelgianIDRecognizer () <PPDocumentClassifier>

@end

@implementation PPBelgianIDRecognizer

- (NSMutableSet *)uppercaseCharsWhitelist {

    // initialize new char whitelist
    NSMutableSet *charWhitelist = [[NSMutableSet alloc] init];

    // Add chars 'A'-'Z'
    for (int c = 'A'; c <= 'Z'; c++) {
        [charWhitelist addObject:[PPOcrCharKey keyWithCode:c font:PP_OCR_FONT_ANY]];
    }
    return charWhitelist;
}

- (PPBlinkOcrRecognizerSettings *)ocrRecognizerSettings {

    PPBlinkOcrRecognizerSettings *ocrSettings = [[PPBlinkOcrRecognizerSettings alloc] init];

    NSMutableArray<PPDecodingInfo *> *decodingInfoArray = [NSMutableArray array];

    NSMutableArray<PPDecodingInfo *> *classificationDecodingInfoArray = [NSMutableArray array];

    /** Setup document number */
    {
        /**
         * Since document number is located differently on old and new ID cards, we will use it as our classification.
         */

        [classificationDecodingInfoArray addObject:[[PPDecodingInfo alloc] initWithLocation:CGRectMake(0.250f, 0.530f, 0.270f, 0.130f )
                                                                             dewarpedHeight:150
                                                                                   uniqueId:ID_DOCUMENT_NUMBER_GROUP]];

        PPRegexOcrParserFactory *documentNumberParser = [[PPRegexOcrParserFactory alloc] initWithRegex:@"[0-9]{3}-[0-9]{7}-[0-9]{2}"];

        NSMutableSet *charWhitelist = [[NSMutableSet alloc] init];
        // Add chars '0'-'9'
        for (int c = '0'; c <= '9'; c++) {
            [charWhitelist addObject:[PPOcrCharKey keyWithCode:c font:PP_OCR_FONT_ANY]];
        }
        [charWhitelist addObject:[PPOcrCharKey keyWithCode:'-' font:PP_OCR_FONT_ANY]];
        PPOcrEngineOptions *options = [[PPOcrEngineOptions alloc] init];
        options.charWhitelist = charWhitelist;
        options.minimalLineHeight = 20;
        [documentNumberParser setOptions:options];

        [ocrSettings addOcrParser:documentNumberParser name:ID_DOCUMENT_NUMBER group:ID_DOCUMENT_NUMBER_GROUP];
    }

    /** Setup face photo */
    {
        /**
         * Since document number is located differently on old and new ID cards, we will use it as our classification.
         */

        [decodingInfoArray addObject:[[PPDecodingInfo alloc] initWithLocation:CGRectMake( 0.693f, 0.437f, 0.283f, 0.536f )
                                                                             dewarpedHeight:300
                                                                        uniqueId:ID_FACE]];
    }

    /**
     * Create ID card document specification. Document specification defines geometric/scanning properties of documents to be detected
     */
    PPDocumentSpecification *idSpec = [PPDocumentSpecification newFromPreset:PPDocumentPresetId1Card];

    /**
     * Set decoding infos as our classification decoding infos. One has location of document number on old id, other on new Id
     */
    [idSpec setDecodingInfo:classificationDecodingInfoArray];

    /**
     * Wrap Document specification in detector settings
     */
    PPDocumentDetectorSettings *detectorSettings = [[PPDocumentDetectorSettings alloc] initWithNumStableDetectionsThreshold:1];
    [detectorSettings setDocumentSpecifications:@[idSpec]];

    /**
     * Add created detector settings to recognizer
     */

    [ocrSettings setDetectorSettings:detectorSettings];

    /**
     * Set this class as document classifier delegate
     */
    [ocrSettings setDocumentClassifier:self];

    /**
     * Add decoding infos for classifier results. These infos and their parsers will only be processed if classifier outputs the
     * selected result
     */
    [ocrSettings setDecodingInfoSet:decodingInfoArray forClassifierResult:CLASS_ID];

    return ocrSettings;
}

- (NSString *)documentNumberFromRecognizerResult:(PPBlinkOcrRecognizerResult *)result {
    return [result parsedResultForName:ID_DOCUMENT_NUMBER parserGroup:ID_DOCUMENT_NUMBER_GROUP];
}

- (NSString *)classifyDocumentFromResult:(PPTemplatingRecognizerResult *)result {

    /**
     * Get the result of parsing the location of document number on old ID.
     */
    NSString *documentNumber = [result parsedResultForName:ID_DOCUMENT_NUMBER parserGroup:ID_DOCUMENT_NUMBER_GROUP];
    if (documentNumber != nil && ![documentNumber isEqualToString:@""]) {
        // If result exists then we are dealing with old ID
        return CLASS_ID;
    }

    return @"";
}

- (UIImage *)facePhotoForImageMetadata:(PPImageMetadata *)imageMetadata {

    if ([imageMetadata.name isEqualToString:ID_FACE]) {
        UIImage *image = [imageMetadata image];
        return image;
    }

    return nil;
    
}

@end
