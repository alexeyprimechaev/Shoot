//
//  CaptureInterface.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI
import AVFoundation
import StoreKit

struct CaptureInterface: View {
    
    @ObservedObject var model = CameraViewModel()
    
    @State var isExperimental = false
    
    @State var rotation = Angle(degrees: 0)
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ImagePreview(model: model).rotationEffect(rotation).animation(.easeOut(duration: 0.2)).position(x: (geometry.size.width - (geometry.size.width + 73)/2)/2)
            
            
            
            CaptureButton(model: model)
            .position(x: geometry.size.width/2)
            
            
            ConfigurationMenu(model: model)
                .rotationEffect(rotation)
                .animation(.easeOut(duration: 0.2))
                .onRotate { newRotation in
                    if newRotation == .landscapeLeft {
                        rotation = Angle(degrees: 90)
                    } else if newRotation == .landscapeRight {
                        rotation = Angle(degrees: -90)
                    } else {
                        rotation = Angle(degrees: 0)
                    }
                }
            
                .position(x: geometry.size.width - (geometry.size.width - (geometry.size.width + 73)/2)/2)
                .frame(height: 73)
            
            
            
        }.frame(height: 73)
        
        
    }
}


struct TitleButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2))
            .onChange(of: configuration.isPressed) { newValue in
                if newValue == true {
                    regularHaptic()
                } else {
                    
                }
                
            }
    }
    
}


public func regularHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .rigid)
    generator.impactOccurred()
}


struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}


extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct CameraIcon: View {
    
    @Binding var selectedCamera: CameraType
    
    var body: some View {
        VStack {
            switch selectedCamera {
            case .telephoto:
                
                if UIDevice.modelName == "iPhone 12 Pro Max" {
                    Text("65").font(.headline).fixedSize()
                } else if UIDevice.modelName == "iPhone 13 Pro" || UIDevice.modelName == "iPhone 13 Pro Max" {
                    Text("77").font(.headline).fixedSize()
                } else {
                    Text("52").font(.headline).fixedSize()
                }
               
                
            case .wide:
                
                if UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone 7 Plus" || UIDevice.modelName == "iPhone 8 Plus" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8"{
                    Text("28").font(.headline).fixedSize()
                } else if UIDevice.modelName == "iPhone XS Max" || UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone XR" || UIDevice.modelName == "iPhone 11" || UIDevice.modelName == "iPhone 11 Pro" || UIDevice.modelName == "iPhone 11 Pro Max" || UIDevice.modelName == "iPhone 12" || UIDevice.modelName == "iPhone 12 mini" || UIDevice.modelName == "iPhone 12 Pro" || UIDevice.modelName == "iPhone 12 Pro Max" || UIDevice.modelName == "iPhone 13" || UIDevice.modelName == "iPhone 13 Pro" || UIDevice.modelName == "iPhone 13 Pro Max" || UIDevice.modelName == "iPhone 13 mini" {
                    Text("26").font(.headline).fixedSize()
                } else {
                    Text("33").font(.headline).fixedSize()
                }

            case .ultrawide:
                Text("13").font(.headline).fixedSize()
            case .front:
                Text("F").font(.headline).fixedSize()
            }
            if selectedCamera != .front {
                Text("mm").font(.caption).fixedSize()
            }
            
        }
    }
}

struct ImagePreview: View {
    
    @ObservedObject var model: CameraViewModel
    
    @State var showingAlert = false
    
    var body: some View {
        Button {
            showingAlert = true
        } label: {
            Group {
                if model.photo != nil {
                    Image(uiImage: model.photo.thumbnailImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .animation(.default)
                    
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 52, height: 52, alignment: .center)
                        .foregroundColor(.black)
                }
            }.padding(28)
        }
        .disabled(model.photo == nil)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("View your pictures in the Photos App"), message: Text("I haven't found a way to open Photos from inside another app, so..."), dismissButton:  .cancel(Text("Damn")))
        }
    }
}

struct CaptureButton: View {
    
    @ObservedObject var model: CameraViewModel
    
    var body: some View {
        ZStack {
            Button {
                model.willCapturePhoto = true
                model.capturePhoto()
            } label: {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 65, height: 65, alignment: .center)
                    .opacity(model.isCameraButtonDisabled ? 0.0 : 1)
                    
                
                
            }
            .buttonStyle(TitleButtonStyle())
            
            Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 73, height: 73, alignment: .center)
            
        }.overlay(
            model.isCameraButtonDisabled ?
            ProgressView().progressViewStyle(.circular).tint(.white) : nil
            
        )
    }
}

struct ConfigurationMenu: View {
    
    @ObservedObject var model: CameraViewModel
    
    var body: some View {
        Menu {
            Picker(selection: $model.selectedCamera, label: Text("Selected Camera"), content: {
                ForEach(availableDeviceTypes(), id: \.self) { cameraType in
//                ForEach(CameraType.allCases, id: \.self) { cameraType in
                    switch cameraType {
                    case .telephoto:
                        Label {
                            Text("Telephoto")
                        } icon: {
                            if UIDevice.modelName == "iPhone 12 Pro Max" {
                                Image("65.circle")
                            } else if UIDevice.modelName == "iPhone 13 Pro" || UIDevice.modelName == "iPhone 13 Pro Max" {
                                Image("77.circle")
                            } else {
                                Image("52.circle")
                            }
                        }.tag(cameraType)
                    case .front:
                        Label("Front", systemImage: "f.circle").tag(cameraType)
                    case .wide:
                        Label {
                            Text("Wide")
                        } icon: {
                            if UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone 7 Plus" || UIDevice.modelName == "iPhone 8 Plus" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8"{
                                Image(systemName: "28.circle")
                            } else if UIDevice.modelName == "iPhone XS Max" || UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone XR" || UIDevice.modelName == "iPhone 11" || UIDevice.modelName == "iPhone 11 Pro" || UIDevice.modelName == "iPhone 11 Pro Max" || UIDevice.modelName == "iPhone 12" || UIDevice.modelName == "iPhone 12 mini" || UIDevice.modelName == "iPhone 12 Pro" || UIDevice.modelName == "iPhone 12 Pro Max" {
                                Image(systemName: "26.circle")
                            } else {
                                Image(systemName: "33.circle")
                            }
                            //                            Image("26.SFSymbol")
                            
                        }
                    case .ultrawide:
                        Label("Ultrawide", systemImage: "13.circle").tag(cameraType)
                    }
                    
                }
                
            })
            
            Button {
                model.showGrid.toggle()
            } label: {
                if !model.showGrid {
                    Label("Toggle Grid", systemImage: "square")
                } else {
                    Label("Toggle Grid", systemImage: "square.split.2x2")
                }
            }
            
            
            Button {
                model.isFlashOn.toggle()
            } label: {
                if model.isFlashOn {
                    Label("Toggle Flash", systemImage: "bolt")
                } else {
                    Label("Toggle Flash", systemImage: "bolt.slash")
                }
            }
            
            //                Picker(selection: .constant(true), label: Text("Format"), content: {
            //                    Label("Compressed", systemImage: "").tag(true)
            //                    Label("RAW", systemImage: "").tag(false)
            //                })
            Divider()
            Menu {
                Menu {
                    
                    Text("1.0 “Uno”")
                    
                    Divider()
                    
                    Link(destination: URL(string: "mailto:monochromestudios@icloud.com")!) {
                        Label("Contact Us", systemImage: "envelope")
                    }
                    
                    Button {
                        SKStoreReviewController.requestReview()
                    } label: {
                        Label("Rate App", systemImage: "star")
                    }
                    
                    Divider()
                    
                    Link(destination: URL(string: "https://twitter.com/stopUIKit")!) {
                        Label("Igor Dyachuk", image: "igor")
                    }
                    Link(destination: URL(string: "https://twitter.com/FetchRequested")!) {
                        Label("Alexey Primechaev", image: "alesha")
                    }
                    Divider()
                    Text("Made in Moscow with ❤️")
                    Divider()
                    
                    
                } label: {
                    Label("About", systemImage: "info.circle")
                }
                Divider()
                Menu {
                    Picker(selection: $model.gridLines, label: Text("Flash"), content: {
                        Label("1 Line", systemImage: "square.split.2x2").tag(2)
                        Label("2 Lines", image: "grid.3x3").tag(3)
                    })
                    
                    Picker(selection: $model.gridFormat, label: Text("Grid Format"), content: {
                        
                        Label("Full", systemImage: "rectangle.portrait").tag(GridFormat.full)
                        Label("Square", systemImage: "square").tag(GridFormat.square)
                        
                    })
                } label: {
                    Text("Grid...")
                }
                Menu {
                    Picker(selection: $model.captureFormat, label: Text("Format"), content: {
                        Label("HEIF", systemImage: "").tag(CaptureFormat.heif)
                        Label("RAW", systemImage: "").tag(CaptureFormat.raw)
                        if model.service.isProRawAvailable {
                            Label("ProRAW", systemImage: "").tag(CaptureFormat.proRAW)
                        }
                    })
                } label: {
                    Text("Capture Format...")
                }
                
            } label: {
                Label("Settings", systemImage: "gear")
            }
            
            
        } label: {
            HStack {
                CameraIcon(selectedCamera: $model.selectedCamera)
                if model.isFlashOn {
                    Image(systemName: "bolt.fill")
                }
            }
            
            .padding(28)
            
            
            .foregroundColor(.white)
        }
    }
}
