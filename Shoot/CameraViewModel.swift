//
//  CameraViewModel.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import Combine
import AVFoundation

final class CameraViewModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var selectedCamera: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
    
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
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    

}
