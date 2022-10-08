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
    var onDismiss: ((MKMapItem?) -> Void)?
    var content: Content
    
    var body: some View {
        content
            .sheet(isPresented: $isPresented) {
                MapItemPickerView(isPresented: $isPresented, onDismiss: onDismiss)
            }
    }
}

#endif

