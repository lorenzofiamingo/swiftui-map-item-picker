//
//  MapItemPickerSheet.swift
//
//
//  Created by Lorenzo Fiamingo on 22/02/22.
//

#if os(iOS)

import SwiftUI
import MapKit

@available(iOS 15.0, *)
struct MapItemPickerSheet<Content: View>: View {
    
    @Binding var isPresented: Bool
    
    @State private var pickerViewController: MapItemPickerViewController
    
    private var content: Content
    
    private var onDismiss: ((MKMapItem?) -> Void)?
    
    init(isPresented: Binding<Bool>, onDismiss: ((MKMapItem?) -> Void)?, content: Content) {
        let pickerViewController = MapItemPickerViewController()
        self.onDismiss = onDismiss
        self._pickerViewController = State(wrappedValue: pickerViewController)
        self._isPresented = isPresented
        self.content = content
        setupPickerViewController()
    }
    
    private func setupPickerViewController() {
        pickerViewController.onDismiss = { mapItem in
            onDismiss?(mapItem)
            isPresented = false
        }
    }
    
    var body: some View {
        content
            .onChange(of: pickerViewController.isBeingPresented) { presenting in
                isPresented = presenting
            }
            .onChange(of: isPresented) { presenting in
                if presenting && !pickerViewController.isBeingPresented {
#if targetEnvironment(macCatalyst)
                    UIApplication.shared
                        .topmostViewController?
                        .present(pickerViewController.searchNavigationController, animated: true)
#else
                    UIApplication.shared
                        .topmostViewController?
                        .present(pickerViewController, animated: true)
                    pickerViewController
                        .present(pickerViewController.searchNavigationController, animated: true)
#endif
                } else {
#if targetEnvironment(macCatalyst)
                    pickerViewController.searchNavigationController
                        .presentingViewController?
                        .dismiss(animated: true)
#else
                    pickerViewController
                        .presentingViewController?
                        .dismiss(animated: true)
#endif
                    pickerViewController = MapItemPickerViewController()
                    setupPickerViewController()
                }
            }
    }
}

private extension UIApplication {
    var topmostViewController: UIViewController? {
        var viewController = connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap({$0 as? UIWindowScene})
            .first?
            .windows
            .filter { $0.isKeyWindow }
            .first?
            .rootViewController
        while let presentedViewController = viewController?.presentedViewController {
            viewController = presentedViewController
        }
        return viewController
    }
}

#endif

