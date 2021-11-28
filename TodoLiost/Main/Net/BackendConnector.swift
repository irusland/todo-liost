//
//  BackendConnector.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation
import CocoaLumberjack

class BackendConnector {
    private var auth: Auth
    
    init(auth: Auth) {
        self.auth = auth
    }
    
    func getList(using session: URLSession = .shared) {
        let sem = DispatchSemaphore(value: 0)
        let token = auth.authCredentials?.accessToken
        let task = session.request(.list, with: ["Authorization": "1337 OAuth \(token)"]) { data, response, error in
            DDLogInfo("\(data) \(response) \(error)")
            
            let json = """
{
   "status": "ok",
   "list": [
     {
       "id": "af8d39a8-e388-4cb6-80de-bc222414e23e",
       "text": "blablabla",
       "importance": "low",
       "deadline": 1638102322,
       "done": true,
       "color": "#FFFFFF",
       "created_at": 1638102300,
       "changed_at": 1638102310,
       "last_updated_by": 1
    }
  ],
  "revision": 1337
}
"""
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let list: ListModel = try! decoder.decode(ListModel.self, from: Data(json.utf8))
                
            DDLogInfo("GET List \(list)")
            sem.signal()
        }

        sem.wait()
    }
}
