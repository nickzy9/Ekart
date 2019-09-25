//
//  Service.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import Foundation
import Alamofire

/// Service class for API calls
class Service {
    static let shared = Service()
    private init() {}
    
    private let ssManager: SessionManager = {
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            Global.api.headyProducts: .disableEvaluation
        ]
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        config.timeoutIntervalForRequest = Global.api.requestTimeOut
        return Alamofire.SessionManager(configuration: config, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()
    
    /// Function to call API
    ///
    /// - Parameters:
    ///   - api: API endpoint
    ///   - m: Method
    ///   - parameters: Parameters
    ///   - completion: Completion block to receive status
    func apiCall(_ api: String, method m: HTTPMethod = .get,
                 parameters: [String: Any]? = nil, isToSaveData: Bool = true, isToGetSavedData: Bool,
                 completion:  @escaping (Any?, ResponseWithMessage) -> Void) {
        var param = [String: Any]()
        if let p = parameters {
            param = p
        }
        ssManager.request(api, method: m, parameters: param)
            .responseData { response in
                var res = ResponseWithMessage.networkIssue
                
                switch response.result {
                case .success(let data):
                    if let model = self.decodeJsonData(data: data, api: api) {
                        if isToSaveData { self.saveData(response.data!, key: api) }
                        completion(model, .success)
                        return
                    }
                    res = .badResponse
                case .failure:
                    res = .serverIssue
                }
                if isToGetSavedData, let model = self.getStoredData(api: api) {
                    completion(model, res)
                    return
                }
                completion(nil, res)
        }
    }
}

// MARK: -Service extension to Process response data
extension Service {
    
    /// Decode response data with decodable
    ///
    /// - Parameters:
    ///   - data: Data
    ///   - api: api URL
    /// - Returns: Data model or nil
    private func decodeJsonData(data: Data, api: String) -> Any? {
        do {
            let decoder = JSONDecoder()
            switch api {
            case Global.api.headyProducts:
                let model = try decoder.decode(HeadyModel.self, from: data)
                return model
            default:
                return nil
            }
        }
        catch let parsingError {
            let error = "[JSON DECODE ERROR: \(api) ERROR: \(parsingError)]"
            Global.log(error)
            return nil
        }
    }
    
    /// Cache data
    ///
    /// - Parameters:
    ///   - data: Data
    ///   - key: Key value to access data
    private func saveData(_ data: Data, key: String) {
        let rawString = String(data: data, encoding: .utf8)
        UserDefaults.standard.set(rawString, forKey: key)
    }
    
    /// Get cached data
    ///
    /// - Parameter api: api URL
    /// - Returns: Data model or nil
    private func getStoredData(api: String) -> Any? {
        let rawString = UserDefaults.standard.string(forKey: api)
        if let data = rawString?.data(using: .utf8) {
            return decodeJsonData(data: data, api: api)
        }
        return nil
    }
}
