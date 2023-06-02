//
//  ResultsExtension.swift
//  NotesManagementMVVMRealm
//
//  Created by Yogesh Rao on 21/02/23.
//

import Foundation
import RealmSwift

extension Results {
    func toArray<T>() -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}
