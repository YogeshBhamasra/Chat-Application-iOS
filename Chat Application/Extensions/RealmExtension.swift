//
//  RealmExtension.swift
//  NotesManagementMVVMRealm
//
//  Created by Yogesh Rao on 21/02/23.
//

import Foundation
import RealmSwift

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
