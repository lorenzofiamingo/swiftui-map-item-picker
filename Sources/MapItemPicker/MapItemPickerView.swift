//
//  MapItemPickerView.swift
//  
//
//  Created by Oscar Fridh on 2022-10-08.
//

#if os(iOS)

import SwiftUI
import MapKit

@available(iOS 15.0, *)
struct MapItemPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onDismiss: ((MKMapItem?) -> Void)?
    
    func makeUIViewController(context: Context) -> MapItemPickerViewController {
        let vc = MapItemPickerViewController()
        context.coordinator.setupPickerViewController(vc)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MapItemPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        var parent: MapItemPickerView
        
        func setupPickerViewController(_ vc: MapItemPickerViewController) {
            vc.onDismiss = { [unowned self, unowned vc] mapItem in
                vc.dismiss(animated: true) {
                    self.parent.isPresented = false
                    self.parent.onDismiss?(mapItem)
                }
            }
        }
        
        init(_ parent: MapItemPickerView) {
            self.parent = parent
        }
    }
}

#endif
