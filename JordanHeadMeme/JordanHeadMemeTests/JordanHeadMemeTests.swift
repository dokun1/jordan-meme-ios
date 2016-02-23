//
//  JordanHeadMemeTests.swift
//  JordanHeadMemeTests
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import XCTest
@testable import JordanHeadMeme
@testable import Crashlytics

class JordanHeadMemeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getAppliedFaces(filename: String) -> [JordanHead]? {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource(filename, ofType: "jpg")
        if path == nil {
            return nil
        }
        let image = UIImage.init(contentsOfFile: path!)
        if image == nil {
            return nil
        }
        return ImageProcessor.processImage(image!)!
    }
    
    func testPhotoWithNoFacesGivesNoReturnedFaces() {
        let results = getAppliedFaces("noFaces")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(0, results!.count, "Should return no faces in array for photo with no faces")
        }
    }
    
    func testPhotoWithOneFaceGivesOneReturnedFace() {
        let results = getAppliedFaces("oneFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(1, results!.count, "Should return 1 face in array for photo with 1 face")
        }
    }
    
    func testPhotoWithTwoFacesGivesTwoReturnedFaces() {
        let results = getAppliedFaces("twoFaces")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(2, results!.count, "Should return 2 faces in array for photo with 2 faces")
        }
    }
    
    func testPhotoWithThreeFacesGivesThreeReturnedFaces() {
        let results = getAppliedFaces("threeFaces")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(3, results!.count, "Should return 3 faces in array for photo with 3 faces")
        }
    }
    
    func testPhotoWithFourFacesGivesFourReturnedFaces() {
        let results = getAppliedFaces("fourFaces")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(4, results!.count, "Should return 4 faces in array for photo with 4 faces")
        }
    }
    
    func testPhotoWithFiveFacesGivesFiveReturnedFaces() {
        let results = getAppliedFaces("fiveFaces")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(5, results!.count, "Should return 5 faces in array for photo with 5 faces")
        }
    }
    
    func testPhotoWithElevenFacesGivesElevenReturnedFaces() {
        let results = getAppliedFaces("elevenFaces")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(11, results!.count, "Should return 11 faces in array for photo with 11 faces")
        }
    }
    
    func testAppliedFaceHasGreaterOrEqualSizeThanDetectedFace() {
        let results = getAppliedFaces("oneFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            let head = results?.first
            let imageView = ImageProcessor.getImageViewForHead(head!)
            XCTAssertTrue(imageView.bounds.size.width > head?.rect.size.width, "Image view should be wider than detected head")
            XCTAssertTrue(imageView.bounds.size.height > head?.rect.size.height, "Image view should be longer than detected head")
        }
    }
    
    func testAppliedFaceHasSameEyeLevelAsDetectedFace() {
        let results = getAppliedFaces("oneFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            let head = results?.first
            let imageView = ImageProcessor.getImageViewForHead(head!)
            let bundle = NSBundle(forClass: self.dynamicType)
            let path = bundle.pathForResource("oneFace", ofType: "jpg")
            var newImage = UIImage.init(contentsOfFile: path!)
            newImage = newImage?.drawRectangle(CGRectMake((head?.transformedLeftEyePosition.x)! - 10, (head?.transformedLeftEyePosition.y)! - 10, 20, 20), color: UIColor.blueColor())
            XCTAssertEqualWithAccuracy((head?.faceFeature.leftEyePosition.x)!, imageView.leftEyePosition.x, accuracy: 10, "The x position of the left eye is not within a reasonable distance of the detected left eye in the photo")
            XCTAssertEqualWithAccuracy((head?.faceFeature.leftEyePosition.y)!, imageView.leftEyePosition.y, accuracy: 10, "The x position of the left eye is not within a reasonable distance of the detected left eye in the photo")
            XCTAssertEqualWithAccuracy((head?.faceFeature.rightEyePosition.x)!, imageView.rightEyePosition.x, accuracy: 10, "The x position of the left eye is not within a reasonable distance of the detected left eye in the photo")
            XCTAssertEqualWithAccuracy((head?.faceFeature.rightEyePosition.y)!, imageView.rightEyePosition.y, accuracy: 10, "The x position of the left eye is not within a reasonable distance of the detected left eye in the photo")
        }
    }
    
    func testAppliedFaceHasSameMouthLevelAsDetectedFace() {
        let results = getAppliedFaces("oneFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            let head = results?.first
            let imageView = ImageProcessor.getImageViewForHead(head!)
            XCTAssertEqualWithAccuracy((head?.faceFeature.mouthPosition.x)!, imageView.mouthCenterPosition.x, accuracy: 10, "The x position of the left eye is not within a reasonable distance of the detected left eye in the photo")
            XCTAssertEqualWithAccuracy((head?.faceFeature.mouthPosition.y)!, imageView.mouthCenterPosition.y, accuracy: 10, "The x position of the left eye is not within a reasonable distance of the detected left eye in the photo")
        }
    }
    
    func testAppliedFaceIsFacingLeftOnLeftFacingFace() {
        let results = getAppliedFaces("leftFacingFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(1, results!.count, "Should return 1 faces in array for photo with 1 face of person facing to the left")
            let detectedHead = results?.first
            XCTAssertFalse(detectedHead!.facingRight, "Detected face that is facing to the right should have corresponding head that faces to the right")
        }
    }
    
    func testAppliedFaceIsFacingRightOnRightFacingFace() {
        let results = getAppliedFaces("rightFacingFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(1, results!.count, "Should return 1 faces in array for photo with 1 face of person facing to the right")
            let detectedHead = results?.first
            XCTAssertTrue(detectedHead!.facingRight, "Detected face that is facing to the right should have corresponding head that faces to the right")
        }
    }
    
    func testFaceDetectedWithThickBeard() {
        let results = getAppliedFaces("beardFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(1, results!.count, "Should return 1 faces in array for photo with 1 face of person wearing thick beard")
        }
    }
    
    func testFaceDetectedWithGlasses() {
        let results = getAppliedFaces("glassesFace")
        XCTAssertNotNil(results, "Should return an initialized array")
        if results == nil {
            XCTFail("Unable to check results for nil array of returned faces")
        } else {
            XCTAssertEqual(1, results!.count, "Should return 1 faces in array for photo with 1 face of person wearing glasses")
        }
    }
}
