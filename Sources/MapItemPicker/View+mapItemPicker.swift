//
//  View+mapItemPickerSheet.swift
//
//
//  Created by Lorenzo Fiamingo on 25/02/22.
//

#if os(iOS)

import SwiftUI
import MapKit

@available(iOS 15.0, *)
extension View {
    public func mapItemPicker(
        isPresented: Binding<Bool>,
        onDismiss: ((MKMapItem?) -> Void)? = nil
    ) -> some View {
        MapItemPickerSheet(isPresented: isPresented, onDismiss: onDismiss, content: self)
    }
}

// allow previews
@available(iOS 15.0, *)
struct MapItemPickerSheet_Previews: PreviewProvider {
    static var previews: some View {
        Spacer()
            .mapItemPicker(isPresented: .constant(true))
    }
}

#endif
