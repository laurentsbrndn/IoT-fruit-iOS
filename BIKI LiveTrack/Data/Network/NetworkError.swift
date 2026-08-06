//
//  NetworkError.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL yang digunakan tidak valid."
        case .invalidResponse:
            return "Respons dari server tidak dikenali."
        case .requestFailed(let statusCode):
            return "Permintaan gagal dengan kode status HTTP: \(statusCode)"
        case .decodingFailed(let error):
            return "Gagal memproses data dari server: \(error.localizedDescription)"
        case .unknown(let error):
            return "Terjadi kesalahan yang tidak diketahui: \(error.localizedDescription)"
        }
    }
}
