//
//  NetworkConnectionStatusService.swift
//  Eventrr
//
//  Created by Irtiza on 8/31/24.
//

import Foundation

import Network

final class NetworkConnectionStatusService {
    
    static let shared = NetworkConnectionStatusService()
    
    private let backgroudQueue = DispatchQueue.global(qos: .background)
    private var pathMonitor: NWPathMonitor!
    private var path: NWPath?
    
    private lazy var pathUpdateHandler: ((NWPath) -> Void) = { [weak self] path in
        self?.path = path
        
        if path.status == NWPath.Status.satisfied {
            print("Connected")
        } else if path.status == NWPath.Status.unsatisfied {
            print("unsatisfied")
        } else if path.status == NWPath.Status.requiresConnection {
            print("requiresConnection")
        }
    }
    
    init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = self.pathUpdateHandler
        pathMonitor.start(queue: backgroudQueue)
    }
    
    public func isNetworkAvailable() -> Bool {
        if let path = self.path { if path.status == NWPath.Status.satisfied { return true } }
        return false
    }
}
