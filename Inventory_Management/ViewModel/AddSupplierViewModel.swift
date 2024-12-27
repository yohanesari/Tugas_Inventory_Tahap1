//
//  AddRiwayatViewModel.swift
//  Inventory_Firebase
//
//  Created by Yohanes  Ari on 16/12/24.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

class AddSupplierViewModel: NSObject, ObservableObject {
    @Published var nama: String = ""
    @Published var alamat: String = ""
    @Published var kontak: String = ""
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        // Periksa apakah layanan lokasi aktif
        if CLLocationManager.locationServicesEnabled() {
            let status = locationManager.authorizationStatus
            switch status {
            case .notDetermined:
                print("Meminta izin lokasi...")
                locationManager.requestWhenInUseAuthorization() // Ini akan memunculkan pop-up
            case .authorizedWhenInUse, .authorizedAlways:
                print("Izin diberikan, meminta lokasi...")
                locationManager.requestLocation()
            case .denied, .restricted:
                errorMessage = "Akses lokasi ditolak. Silakan aktifkan izin lokasi di pengaturan."
            @unknown default:
                errorMessage = "Status lokasi tidak diketahui."
            }
        } else {
            errorMessage = "Gagal mengambil lokasi. Pastikan GPS aktif."
        }
    }

    
    func saveSupplier() {
        guard !nama.isEmpty, !alamat.isEmpty, !kontak.isEmpty else {
            errorMessage = "Semua field harus diisi"
            return
        }
        
        isLoading = true
        
        let supplierData: [String: Any] = [
            "nama": nama,
            "alamat": alamat,
            "kontak": kontak,
            "latitude": latitude ?? 0,
            "longitude": longitude ?? 0,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("suppliers").addDocument(data: supplierData) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Gagal menyimpan: \(error.localizedDescription)"
                } else {
                    // Reset form after successful save
                    self.nama = ""
                    self.alamat = ""
                    self.kontak = ""
                    self.latitude = nil
                    self.longitude = nil
                    self.errorMessage = nil
                }
            }
        }
    }
}

extension AddSupplierViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Lokasi berhasil diperoleh: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.errorMessage = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.errorMessage = "Gagal mengambil lokasi: \(error.localizedDescription)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Izin lokasi diberikan, meminta lokasi...")
            DispatchQueue.global().async {
                self.locationManager.requestLocation()
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "Akses lokasi ditolak. Silakan aktifkan izin lokasi di pengaturan."
            }
        case .notDetermined:
            print("Izin lokasi belum ditentukan.")
        @unknown default:
            DispatchQueue.main.async {
                self.errorMessage = "Status izin lokasi tidak diketahui."
            }
        }
    }
}

