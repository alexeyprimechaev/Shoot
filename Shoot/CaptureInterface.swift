//
//  CaptureInterface.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI
import AVFoundation

struct CaptureInterface: View {
    
    @StateObject var model = CameraViewModel()
    
    @State var isExperimental = false
    
    @State var rotation = Angle(degrees: 0)
    
    @Binding var numberOfLines: Int
    
    var body: some View {
        if isExperimental {
            HStack {
                Spacer()
                Button {
                    model.capturePhoto()
                } label: {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 73, height: 73, alignment: .center)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 65, height: 65, alignment: .center)
                        )

                }
                Spacer()
                Menu {
                    Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                        Label("Telephoto", systemImage: "circle.grid.cross.up.fill")
                        Label("Wide", systemImage: "circle.grid.cross.right.fill").tag(true)
                        Label("Ultrawide", systemImage: "circle.grid.cross.down.fill")
                    })
                    Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                        Label("Flash On", systemImage: "bolt").tag(true)
                        Label("Flash Off", systemImage: "bolt.slash").tag(false)
                    })
                    
                    Picker(selection: $numberOfLines, label: Text("Flash"), content: {
                        Label("2x2", systemImage: "rectangle.split.2x2").tag(2)
                        Label("3x3", systemImage: "rectangle.split.3x3").tag(3)
                        Label("Natural", systemImage: "rectangle").tag(0)
                    })
                    
                    
                } label: {
                    Image(systemName: "ellipsis.circle").font(.title2).padding(32).foregroundColor(.white)
                }
                Spacer()
                
            }
        } else {
            GeometryReader { geometry in
            
            Group {
                       if model.photo != nil {
                           Image(uiImage: model.photo.image!)
                               .resizable()
                               .aspectRatio(contentMode: .fill)
                               .frame(width: 32, height: 32)
                               .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                               .animation(.spring())

                       } else {
                           RoundedRectangle(cornerRadius: 8)
                               .frame(width: 52, height: 52, alignment: .center)
                               .foregroundColor(.black)
                       }
            }.padding(28).rotationEffect(rotation).animation(.easeOut(duration: 0.2)).position(x: (geometry.size.width - (geometry.size.width + 73)/2)/2)
                    
                
                ZStack {
            Button {
                model.capturePhoto()
            } label: {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 65, height: 65, alignment: .center)
                    

            }
            .buttonStyle(TitleButtonStyle())
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 73, height: 73, alignment: .center)
                }
            .position(x: geometry.size.width/2)

            Menu {
                Picker(selection: $model.selectedCamera, label: Text("Selected Camera"), content: {
                    ForEach(availableDeviceTypes(), id: \.self) { cameraType in
                        switch cameraType {
                        case .telephoto:
                            Label {
                                Text("Telephoto")
                            } icon: {
                                if UIDevice.modelName == "iPhone 12 Pro Max" {
                                    Image("65.SFSymbol")
                                } else {
                                    Image("52.SFSymbol")
                                }
                            }.tag(cameraType)
                        case .front:
                            Label("Front", image: "FF.SFSymbol").tag(cameraType)
                        case .wide:
                        Label {
                            Text("Wide")
                        } icon: {
                            if UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone 7 Plus" || UIDevice.modelName == "iPhone 8 Plus" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8"{
                                Image("28.SFSymbol")
                            } else if UIDevice.modelName == "iPhone XS Max" || UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone XR" || UIDevice.modelName == "iPhone 11" || UIDevice.modelName == "iPhone 11 Pro" || UIDevice.modelName == "iPhone 11 Pro Max" || UIDevice.modelName == "iPhone 12" || UIDevice.modelName == "iPhone 12 mini" || UIDevice.modelName == "iPhone 12 Pro" || UIDevice.modelName == "iPhone 12 Pro Max" {
                                Image("26.SFSymbol")
                            } else {
                                Image("33.SFSymbol")
                            }
                        }
                        case .ultrawide:
                            Label("Ultrawide", image: "13.SFSymbol").tag(cameraType)
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
                    Button {
                        
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                    Divider()
                    Menu {
                        Picker(selection: $numberOfLines, label: Text("Flash"), content: {
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
                            Label("HEIC", systemImage: "").tag(CaptureFormat.heic)
                            Label("RAW", systemImage: "").tag(CaptureFormat.raw)
                            Label("ProRAW", systemImage: "").tag(CaptureFormat.proRaw)
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
                
                .foregroundColor(.white)
            }.position(x: geometry.size.width - (geometry.size.width - (geometry.size.width + 73)/2)/2)
            .frame(height: 73)
            .onAppear {
                print("here")
                print(availableDeviceTypes())
            }
            
        

        }.frame(height: 73)
        }
    
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
                    regularHaptic()
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
                } else {
                    Text("52").font(.headline).fixedSize()
                }
            case .wide:
                if UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone 7 Plus" || UIDevice.modelName == "iPhone 8 Plus" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8"{
                    Text("28").font(.headline).fixedSize()
                } else if UIDevice.modelName == "iPhone XS Max" || UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone XR" || UIDevice.modelName == "iPhone 11" || UIDevice.modelName == "iPhone 11 Pro" || UIDevice.modelName == "iPhone 11 Pro Max" || UIDevice.modelName == "iPhone 12" || UIDevice.modelName == "iPhone 12 mini" || UIDevice.modelName == "iPhone 12 Pro" || UIDevice.modelName == "iPhone 12 Pro Max" {
                    Text("26").font(.headline).fixedSize()
                } else {
                    Text("33").font(.headline).fixedSize()
                }
            case .ultrawide:
                Text("13").font(.headline).fixedSize()
            case .front:
                Text("FF").font(.headline).fixedSize()
            }
            if selectedCamera != .front {
                Text("mm").font(.caption).fixedSize()
            }
            
        }
    }
}
