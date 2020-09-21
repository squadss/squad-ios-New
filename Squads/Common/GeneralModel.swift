//
//  GeneralModel.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/3.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation

struct GeneralModel {
    
    struct Base<T: Decodable>: Decodable {
        let success: Bool
        let code: Int
        let message: String
        let data: T?
        
        enum CodingKeys: CodingKey {
            case success
            case code
            case message
            case data
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            success = try container.decode(Bool.self, forKey: .success)
            code = try container.decode(Int.self, forKey: .code)
            message = try container.decode(String.self, forKey: .message)
            data = try container.decodeIfPresent(T.self, forKey: .data)
        }
    }

    struct Plain: Decodable {
        let success: Bool
        let code: Int
        let message: String
        
        enum CodingKeys: CodingKey {
            case success
            case code
            case message
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            success = try container.decode(Bool.self, forKey: .success)
            code = try container.decode(Int.self, forKey: .code)
            message = try container.decode(String.self, forKey: .message)
        }
    }

    struct List<T: Decodable>: Decodable {
        var records: Array<T>
        let total: Int
        let pageSize: Int
        let pageIndex: Int
        
        init(records: Array<T>, total: Int, pageSize: Int = 20, pageIndex: Int = 1) {
            self.records = records
            self.total = total
            self.pageSize = pageSize
            self.pageIndex = pageIndex
        }
        
        /*
         self.paging.total = pagation.total
         if pagation.canLoadNext {
             self.paging.nextPage()
         }
         */
        var canLoadNext: Bool {
            return (pageIndex - 1) * pageSize < total
        }
        
        var existMore: Bool {
            return pageIndex * pageSize < total
        }
    }

}
