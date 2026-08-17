//
//  AddShipmentView.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 17/08/26.
//

//
//  AddShipmentView.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 17/08/26.
//

//
//  AddShipmentView.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 17/08/26.
//

//
//  AddShipmentView.swift
//  BIKI LiveTrack
//
//  Created by Grace Frendy on 17/08/26.
//

import SwiftUI

struct AddShipmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddShipmentViewModel()

    @State private var dragOffset: CGFloat = 0
    @State private var isConfirmed: Bool = false
    
    private let knobSize: CGFloat = 44
    private let horizontalPadding: CGFloat = 4
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                
      // Header
                HStack {
                    Spacer()
                    Text("Create a Shipment")
                        .font(.app.bodyBold)
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                
     // Location Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location \(Text("*").foregroundStyle(Color.theme.primaryRed))")
                        .font(.app.bodyBold)
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Circle()
                                .strokeBorder(Color.theme.primaryGreen, lineWidth: 2)
                                .frame(width: 12, height: 12)
                            
                            Circle().frame(width: 2, height: 2).foregroundStyle(.tertiary)
                            Circle().frame(width: 2, height: 2).foregroundStyle(.tertiary)
                            Circle().frame(width: 2, height: 2).foregroundStyle(.tertiary)
                            
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.theme.primaryGreen)
                        }
                        .padding(.vertical, 6)
                        
                        VStack(spacing: 8) {
                            TextField("Current location", text: $viewModel.originLocation)
                                .padding(.horizontal, 12)
                                .frame(height: 36)
                                .background(Color.theme.grey)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            
                            TextField("Where to go?", text: $viewModel.destinationLocation)
                                .padding(.horizontal, 12)
                                .frame(height: 36)
                                .background(Color.theme.grey)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }
                }
                
       // Truck Plate Number
                VStack(alignment: .leading, spacing: 8) {
                    Text("Truck Plate Number \(Text("*").foregroundStyle(Color.theme.primaryRed))")
                        .font(.app.bodyBold)
                    
                    TextField("e.g. B 1234 ABC", text: $viewModel.truckPlateNumber)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(Color.theme.grey)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                
    // Driver
                VStack(alignment: .leading, spacing: 8) {
                    Text("Driver \(Text("*").foregroundStyle(Color.theme.primaryRed))")
                        .font(.app.bodyBold)
                    
                    Menu {
                        ForEach(viewModel.availableDrivers, id: \.self) { item in
                            Button(item) {
                                viewModel.selectedDriver = item
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedDriver.isEmpty ? "Select a driver here" : viewModel.selectedDriver)
                                .foregroundStyle(viewModel.selectedDriver.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .font(.app.body)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(Color.theme.grey)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                
    // Device ID
                VStack(alignment: .leading, spacing: 8) {
                    Text("Device ID \(Text("*").foregroundStyle(Color.theme.primaryRed))")
                        .font(.app.bodyBold)
                    
                    Menu {
                        ForEach(viewModel.availableDevices, id: \.self) { item in
                            Button(item) {
                                viewModel.selectedDeviceID = item
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedDeviceID.isEmpty ? "Select a device id here" : viewModel.selectedDeviceID)
                                .foregroundStyle(viewModel.selectedDeviceID.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .font(.app.body)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(Color.theme.grey)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer(minLength: 12)
                
                // Interactive Swipe To Confirm Slider
                GeometryReader { geo in
                    let trackWidth = geo.size.width
                    let maxDrag = trackWidth - knobSize - (horizontalPadding * 2)
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(
                                isConfirmed
                                ? Color.theme.primaryGreen
                                : Color.theme.secondaryGreen.opacity(0.4)
                            )
                            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isConfirmed)
                        
                        Text(isConfirmed ? "Shipping Started!" : "Swipe to start shipping")
                            .font(isConfirmed ? .app.bodyBold : .app.body)
                            .foregroundStyle(
                                isConfirmed
                                ? .white
                                : Color.theme.primaryGreen
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .opacity(isConfirmed ? 1.0 : (1.0 - Double(dragOffset / (maxDrag > 0 ? maxDrag : 1))))
                            .animation(.easeInOut(duration: 0.2), value: isConfirmed)
                        
                        // Draggable Slider Knob
                        Circle()
                            .fill(
                                isConfirmed
                                ? .white
                                : Color.theme.primaryGreen
                            )
                            .frame(width: knobSize, height: knobSize)
                            .overlay {
                                Image(systemName: isConfirmed ? "checkmark" : "box.truck.fill")
                                    .font(.system(size: isConfirmed ? 14 : 16, weight: .bold))
                                    .foregroundStyle(
                                        isConfirmed
                                        ? Color.theme.primaryGreen
                                        : .white
                                    )
                            }
                            .offset(x: horizontalPadding + dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        guard viewModel.isFormValid && !isConfirmed else { return }
                                        if value.translation.width > 0 {
                                            dragOffset = min(value.translation.width, maxDrag)
                                        }
                                    }
                                    .onEnded { _ in
                                        guard viewModel.isFormValid && !isConfirmed else { return }
                                        if dragOffset >= maxDrag * 0.8 {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                dragOffset = maxDrag
                                                isConfirmed = true
                                            }
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            
                                            viewModel.startShipping {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                    dismiss()
                                                }
                                            }
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                dragOffset = 0
                                            }
                                        }
                                    }
                            )
                    }
                }
                .frame(height: 52)
                .opacity(viewModel.isFormValid ? 1.0 : 0.45)
                .disabled(!viewModel.isFormValid)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isFormValid)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

#Preview(traits: .landscapeLeft) {
    struct PreviewWrapper: View {
        @State private var showSheet = true
        
        var body: some View {
            Color.clear
                .sheet(isPresented: $showSheet) {
                    AddShipmentView()
                }
        }
    }
    
    return PreviewWrapper()
}
