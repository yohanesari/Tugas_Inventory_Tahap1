//
//  DetailSupplierView.swift
//  Inventory_Firebase
//
//  Created by Yohanes  Ari on 16/12/24.
//

import SwiftUI
import MapKit

struct DetailSupplierView: View {
    var supplier: Supplier
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Card
                VStack(alignment: .leading, spacing: 10) {
                    Text(supplier.nama)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    // Contact Information
                    HStack(alignment: .top) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .imageScale(.large)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Alamat")
                                .font(.headline)
                            Text(supplier.alamat)
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Kontak")
                                .font(.headline)
                            Text(supplier.kontak)
                                .font(.body)
                        }
                    }
                    
                    // Coordinates
                    HStack(alignment: .top) {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Koordinat")
                                .font(.headline)
                            Text("\(String(format: "%.4f", supplier.latitude)), \(String(format: "%.4f", supplier.longitude))")
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                
                // Map Preview
                MapPreviewView(coordinate: CLLocationCoordinate2D(latitude: supplier.latitude, longitude: supplier.longitude))
                    .frame(height: 200)
                    .cornerRadius(12)
                
                // Open in Maps Button
                Button(action: bukaPeta) {
                    HStack {
                        Image(systemName: "map")
                        Text("Buka di Peta")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Detail Supplier")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func bukaPeta() {
        let coordinate = CLLocationCoordinate2D(latitude: supplier.latitude, longitude: supplier.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = supplier.nama
        mapItem.openInMaps()
    }
}

// Supporting MapPreviewView
struct MapPreviewView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
