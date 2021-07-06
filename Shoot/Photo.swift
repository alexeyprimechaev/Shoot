//
//  Photo.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import Foundation
import UIKit

public struct Photo: Identifiable, Equatable {
//    The ID of the captured photo
    public var id: String
//    Data representation of the captured photo
    public var originalData: Data
    
    public init(id: String = UUID().uuidString, originalData: Data) {
        self.id = id
        self.originalData = originalData
    }
}

extension Photo {
    public var compressedData: Data? {
        ImageResizer(targetWidth: 800).resize(data: originalData)?.jpegData(compressionQuality: 0.5)
    }
    public var thumbnailData: Data? {
        ImageResizer(targetWidth: 32).resize(data: originalData)?.jpegData(compressionQuality: 0.5)
    }
    public var thumbnailImage: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    public var image: UIImage? {
        guard let data = compressedData else { return nil }
        return UIImage(data: data)
    }
}

public struct AlertError {
    public var title: String = ""
    public var message: String = ""
    public var primaryButtonTitle = "Accept"
    public var secondaryButtonTitle: String?
    public var primaryAction: (() -> ())?
    public var secondaryAction: (() -> ())?
    
    public init(title: String = "", message: String = "", primaryButtonTitle: String = "Accept", secondaryButtonTitle: String? = nil, primaryAction: (() -> ())? = nil, secondaryAction: (() -> ())? = nil) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryAction = secondaryAction
    }
}

enum ImageResizingError: Error {
    case cannotRetrieveFromURL
    case cannotRetrieveFromData
}

public struct ImageResizer {
    var targetWidth: CGFloat
    
    public func resize(at url: URL) -> UIImage? {
        guard let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        return self.resize(image: image)
    }
    
    public func resize(image: UIImage) -> UIImage {
        let originalSize = image.size
        let targetSize = CGSize(width: targetWidth, height: targetWidth*originalSize.height/originalSize.width)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    public func resize(data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else {return nil}
        return resize(image: image )
    }
}

struct MemorySizer {
    static func size(of data: Data) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(data.count))
        return string
    }
}
