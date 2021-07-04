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

public enum CameraType: String, CaseIterable {
    case ultrawide, wide, telephoto, front
}

public let defaultsStored = UserDefaults.standard


final class CameraViewModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = ((defaultsStored.value(forKey: "isFlashOn") ?? false) as! Bool) {
        didSet {
            defaultsStored.set(isFlashOn, forKey: "isFlashOn")
        }
    }
    
    @Published var gridLines = ((defaultsStored.value(forKey: "gridLines") ?? 0) as! Int) {
        didSet {
            defaultsStored.set(gridLines, forKey: "gridLines")
        }
    }
    
    @Published var isCameraButtonDisabled = false
    
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
        
        self.$isFlashOn.sink { [weak self] (isOn) in
            self?.service.flashMode = isOn ? .on : .off
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
