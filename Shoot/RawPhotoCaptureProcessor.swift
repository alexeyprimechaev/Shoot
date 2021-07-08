//
//  PhotoCaptureProcessor.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import Foundation
import Photos

class RawPhotoCaptureProcessor: NSObject {
    
    lazy var context = CIContext()

    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    private let willCapturePhotoAnimation: () -> Void
    
    private let completionHandler: (RawPhotoCaptureProcessor) -> Void
    
    private let photoProcessingHandler: (Bool) -> Void
    
    private var rawFileURL: URL?
    
//    The actual captured photo's data
    var compressedPhotoData: Data?
    
//    The maximum time lapse before telling UI to show a spinner
    private var maxPhotoProcessingTime: CMTime?
        
//    Init takes multiple closures to be called in each step of the photco capture process
    init(with requestedPhotoSettings: AVCapturePhotoSettings, willCapturePhotoAnimation: @escaping () -> Void, completionHandler: @escaping (RawPhotoCaptureProcessor) -> Void, photoProcessingHandler: @escaping (Bool) -> Void) {
        
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
        self.photoProcessingHandler = photoProcessingHandler
    }
}

extension RawPhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    
    // This extension adopts AVCapturePhotoCaptureDelegate protocol methods.
    
    /// - Tag: WillBeginCapture
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        DispatchQueue.main.async {
            self.willCapturePhotoAnimation()
        }
        maxPhotoProcessingTime = resolvedSettings.photoProcessingTimeRange.start + resolvedSettings.photoProcessingTimeRange.duration
    }
    
    /// - Tag: WillCapturePhoto
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {

        
        guard let maxPhotoProcessingTime = maxPhotoProcessingTime else {
            return
        }
        
        // Show a spinner if processing time exceeds one second.
        let oneSecond = CMTime(seconds: 2, preferredTimescale: 1)
        if maxPhotoProcessingTime > oneSecond {
            DispatchQueue.main.async {
                self.photoProcessingHandler(true)
            }
        }
    }
    
    /// - Tag: DidFinishProcessingPhoto
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        DispatchQueue.main.async {
            self.photoProcessingHandler(false)
        }
        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            guard let photoData = photo.fileDataRepresentation() else {
                        print("No photo data to write.")
                        return
                    }
            
            if photo.isRawPhoto {
                // Generate a unique URL to write the RAW file.
                rawFileURL = makeUniqueDNGFileURL()
                do {
                    // Write the RAW (DNG) file data to a URL.
                    try photoData.write(to: rawFileURL!)
                } catch {
                    fatalError("Couldn't write DNG file to the URL.")
                }
            } else {
                // Store compressed bitmap data.
                compressedPhotoData = photoData
            }
        }
        
        
    }
    
    private func makeUniqueDNGFileURL() -> URL {
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = ProcessInfo.processInfo.globallyUniqueString
            return tempDir.appendingPathComponent(fileName).appendingPathExtension("dng")
        }
    
    //        MARK: Saves capture to photo library
    func saveToPhotoLibrary(_ photoData: Data) {
        
        if let rawFileURL = rawFileURL, let compressedData = compressedPhotoData {
            print("raw")
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: compressedData, options: nil)
                                    
                        options.shouldMoveFile = true
                        options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                        creationRequest.addResource(with: .alternatePhoto, fileURL: rawFileURL, options: options)
                        
                        
                    }, completionHandler: { _, error in
                        if let error = error {
                            print("Error occurred while saving photo to photo library: \(error)")
                        }
                        
                        DispatchQueue.main.async {
                            self.completionHandler(self)
                        }
                    }
                    )
                } else {
                    DispatchQueue.main.async {
                        self.completionHandler(self)
                    }
                }
            }
        } else if let compressedData = compressedPhotoData {
            print("ne raw")
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: compressedData, options: nil)
                                    

                        
                        
    //                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                        
                        
                    }, completionHandler: { _, error in
                        if let error = error {
                            print("Error occurred while saving photo to photo library: \(error)")
                        }
                        
                        DispatchQueue.main.async {
                            self.completionHandler(self)
                        }
                    }
                    )
                } else {
                    DispatchQueue.main.async {
                        self.completionHandler(self)
                    }
                }
            }
        } else {
            print("The expected photo data isn't available.")
            return
        }
        

        
        
        
    }
    
    /// - Tag: DidFinishCapture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            DispatchQueue.main.async {
                self.completionHandler(self)
            }
            return
        } else {
            
            
            
            guard let data  = compressedPhotoData else {
                DispatchQueue.main.async {
                    self.completionHandler(self)
                }
                return
            }
            
            self.saveToPhotoLibrary(data)
            regularHaptic()
        }
    }
}
