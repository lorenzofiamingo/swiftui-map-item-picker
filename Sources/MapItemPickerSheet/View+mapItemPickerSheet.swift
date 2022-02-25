//
//  View+mapItemPickerSheet.swift
//
//
//  Created by Lorenzo Fiamingo on 25/02/22.
//

#if os(iOS)

import SwiftUI
import MapKit

extension View {
    public func mapItemPickerSheet(
        isPresented: Binding<Bool>,
        onDismiss: ((MKMapItem?) -> Void)? = nil
    ) -> some View {
        MapItemPickerSheet(isPresented: isPresented, onDismiss: onDismiss, content: self)
    }
}

#endif
