import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var activeShipments: [Shipment] = []
    @Published var deliveredShipments: [Shipment] = []
    @Published var shipmentStatuses: [UUID: DeviceStatus] = [:]
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var isRefreshing = false
    
    private let shipmentRepository: ShipmentRepositoryProtocol
    private let alertLogRepository: AlertLogRepositoryProtocol
    private let sensorLogRepository: SensorLogRepositoryProtocol
    
    init(
        shipmentRepository: ShipmentRepositoryProtocol = ShipmentRepository(),
        alertLogRepository: AlertLogRepositoryProtocol = AlertLogRepository(),
        sensorLogRepository: SensorLogRepositoryProtocol = SensorLogRepository() // 2. INJEKSI DI SINI
    ) {
        self.shipmentRepository = shipmentRepository
        self.alertLogRepository = alertLogRepository
        self.sensorLogRepository = sensorLogRepository
    }
    
    func loadHomeData(showLoading: Bool = true) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
        if showLoading { self.isLoading = true }
        self.errorMessage = nil
        
        do {
            async let fetchActive = shipmentRepository.fetchActiveShipments()
            async let fetchAll = shipmentRepository.fetchAllShipments()
            
            let (active, all) = try await (fetchActive, fetchAll)
            
            self.activeShipments = active
            self.deliveredShipments = all
                .filter { $0.endDate != nil }
                .sorted { ($0.endDate ?? Date.distantPast) > ($1.endDate ?? Date.distantPast) }
            
            let activeIDs = Set(active.map { $0.id })
            self.shipmentStatuses = self.shipmentStatuses.filter { activeIDs.contains($0.key) }
            
            // 3. GANTI PEMANGGILAN FUNGSI
            await fetchShipmentStatuses(for: active)
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Gagal mengambil data shipments: \(error)")
        }
        
        if showLoading { self.isLoading = false }
    }
    
    private func fetchShipmentStatuses(for shipments: [Shipment]) async {
        await withTaskGroup(of: (UUID, DeviceStatus).self) { group in
            for shipment in shipments {
                group.addTask {
                    do {
                        let logs = try await self.sensorLogRepository.fetchSensors(byShipmentID: shipment.id.uuidString)
                        let sortedLogs = logs.sorted { ($0.timestamps ?? .distantPast) < ($1.timestamps ?? .distantPast) }
                        
                        guard let latestLog = sortedLogs.last else {
                            return (shipment.id, .offline)
                        }
                        
                        let temp = latestLog.temperature
                        let hum = latestLog.humidity
                        
                        if temp == nil && hum == nil {
                            return (shipment.id, .offline)
                        }
                        
                        let tempIsIdeal = temp != nil && (10...13).contains(temp!)
                        let humIsIdeal = hum != nil && (85...95).contains(hum!)
                        
                        if !tempIsIdeal || !humIsIdeal {
                            return (shipment.id, .warning)
                        } else {
                            return (shipment.id, .ideal)
                        }
                    } catch {
                        print("Gagal mengambil sensor log untuk shipment \(shipment.id): \(error)")
                        return (shipment.id, .offline)
                    }
                }
            }
            
            for await (id, status) in group {
                self.shipmentStatuses[id] = status
            }
        }
    }
}
