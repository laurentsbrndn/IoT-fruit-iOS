//
//  WebSocketManager.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import Foundation
import Combine

final class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()
    
    @Published var isConnected: Bool = false
    @Published var liveTelemetryString: String = ""
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let wsURL = URL(string: "wss://fruit-shipment.onrender.com/api/live-telemetry")!
    
    private init() {}
    
    func connect() {
        guard webSocketTask == nil else { return }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: wsURL)
        webSocketTask?.resume()
        
        DispatchQueue.main.async {
            self.isConnected = true
        }
        
        listenForMessages()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
    
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self.liveTelemetryString = text
                    }
                case .data(let data):
                    print("Received binary data: \(data.count) bytes")
                @unknown default:
                    break
                }
                
                if self.isConnected {
                    self.listenForMessages()
                }
                
            case .failure(let error):
                print("WebSocket Connection Error: \(error.localizedDescription)")
                self.disconnect()
            }
        }
    }
    
    func sendPing(message: String) {
        let wsMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("WebSocket Send Error: \(error.localizedDescription)")
            }
        }
    }
}
