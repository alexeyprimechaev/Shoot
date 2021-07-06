//
//  CameraViewModel.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import Combine
import AVFoundation

extension AVCaptureDevice {
    func cameraType() -> CameraType {
        
        if self.position == .back {
            
            switch self.deviceType {
            case .builtInTelephotoCamera:
                return.telephoto
            case .builtInWideAngleCamera:
                return .wide
            case .builtInUltraWideCamera:
                return .ultrawide
            default:
                return .wide
            }

        } else {
            return .front
        }
    }
    
}

public enum CaptureFormat: String {
    case heif, raw, proRAW
}

enum GridFormat: String {
    case square, full
}

func availableDeviceTypes() -> [CameraType] {
    var availableDeviceTypes = [CameraType]()
    
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera], mediaType: .video, position: .unspecified)
    let devices = videoDeviceDiscoverySession.devices
    
    for cameraTypeIn in CameraType.allCases {
        print(cameraTypeIn)
        if let device = devices.first(where: { $0.cameraType() == cameraTypeIn }) {
            availableDeviceTypes.append(cameraTypeIn)
        }
    }
    return availableDeviceTypes
}

//func availableCaptureFormates() -> [CaptureFormat] {
//    var availableDeviceTypes = [CaptureFormat]()
//    
//    let query = photoOutput.isAppleProRAWEnabled ?
//        { AVCapturePhotoOutput.isAppleProRAWPixelFormat($0) } :
//        { AVCapturePhotoOutput.isBayerRAWPixelFormat($0) }
//
//    // Retrieve the RAW format, favoring Apple ProRAW when enabled.
//    guard let rawFormat =
//            photoOutput.availableRawPhotoPixelFormatTypes.first(where: query) else {
//        fatalError("No RAW format found.")
//    }
//
//
//}

public enum CameraType: String, CaseIterable {
    case ultrawide, wide, telephoto, front
}

public let defaultsStored = UserDefaults.standard


final class CameraViewModel: ObservableObject {
    let service = CameraService()
    
    @Published var isProRAWSupported: Bool = {
        let rawFormatQuery = {AVCapturePhotoOutput.isBayerRAWPixelFormat($0)}
        if let rawFormat = AVCapturePhotoOutput().availableRawPhotoPixelFormatTypes.first(where: rawFormatQuery) {
            print("gooood")
            return true
        } else {
            print("baaaad")
            return false
        }
    }()
    
    @Published var photo: Photo!
    
    @Published var showAlertError = false
    
    @Published var captureFormat: CaptureFormat = CaptureFormat(rawValue: ((defaultsStored.value(forKey: "captureFormat") ?? CaptureFormat.heif.rawValue) as! String)) ?? .heif {
        didSet {
            if oldValue != captureFormat {
                defaultsStored.set(captureFormat.rawValue, forKey: "captureFormat")
            }
        }
    }
    
    @Published var isFlashOn = ((defaultsStored.value(forKey: "isFlashOn") ?? false) as! Bool) {
        didSet {
            defaultsStored.set(isFlashOn, forKey: "isFlashOn")
        }
    }
    
    @Published var hasChangedIcon = ((defaultsStored.value(forKey: "hasChangedIcon") ?? false) as! Bool) {
        didSet {
            defaultsStored.set(hasChangedIcon, forKey: "hasChangedIcon")
        }
    }
    
    @Published var showGrid = ((defaultsStored.value(forKey: "showGrid") ?? false) as! Bool) {
        didSet {
            defaultsStored.set(showGrid, forKey: "showGrid")
        }
    }
    
    @Published var gridLines = ((defaultsStored.value(forKey: "gridLines") ?? 3) as! Int) {
        didSet {
            defaultsStored.set(gridLines, forKey: "gridLines")
        }
    }
    
    @Published var gridFormat: GridFormat = GridFormat(rawValue: ((defaultsStored.value(forKey: "gridFormat") ?? GridFormat.full.rawValue) as! String)) ?? .full {
        didSet {
            if oldValue != gridFormat {
                defaultsStored.set(gridFormat.rawValue, forKey: "gridFormat")
            }
        }
    }
    
    
    @Published var isCameraButtonDisabled = false
    
    @Published var willCapturePhoto = false
    
    @Published var selectedCamera: CameraType = CameraType(rawValue: ((defaultsStored.value(forKey: "selectedCamera") ?? CameraType.wide.rawValue) as! String)) ?? .wide {
        didSet {
            if oldValue != selectedCamera {
                defaultsStored.set(selectedCamera.rawValue, forKey: "selectedCamera")
                changeCamera()
            }
        }
    }
    
    @Published var selectedCameraPosition: AVCaptureDevice.Position = .back {
        didSet {
            if oldValue != selectedCameraPosition {
                changeCamera()
            }
        }
    }
    
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$isCameraButtonDisabled.sink { [weak self] (isCameraButtonDisabled) in
            self?.isCameraButtonDisabled = isCameraButtonDisabled
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (willCapturePhoto) in
            self?.willCapturePhoto = willCapturePhoto
        }
        .store(in: &self.subscriptions)
        
        self.$isFlashOn.sink { [weak self] (isOn) in
            self?.service.flashMode = isOn ? .on : .off
        }
        .store(in: &self.subscriptions)
        
        self.$captureFormat.sink { [weak self] (captureFormat) in
            self?.service.captureFormat = captureFormat
        }
        .store(in: &self.subscriptions)
        
        self.$selectedCamera.sink { [weak self] (selectedCamera) in
            self?.service.selectedCamera = selectedCamera
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configureSession()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func changeCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    

}
