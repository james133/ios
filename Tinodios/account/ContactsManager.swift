//
//  ContactsManager.swift
//  Tinodios
//
//  Copyright © 2019 Tinode. All rights reserved.
//

import Foundation
import TinodeSDK

class ContactsManager {
    public static var `default` = ContactsManager()

    private let queue = DispatchQueue(label: "co.tinode.contacts")
    private let userDb: UserDb!
    init() {
        self.userDb = BaseDb.getInstance().userDb!
    }
    public func processSubscription(sub: SubscriptionProto) {
        queue.sync {
            processSubsciptionInternal(sub: sub)
        }
    }
    private func processSubsciptionInternal(sub: SubscriptionProto) {
        guard let subId = sub.uniqueId else { return }
        let userId = userDb.getId(for: subId)
        if (sub.deleted) != nil {
            // Subscription deleted. Delete the user.
            if userId >= 0 {
                userDb.deleteRow(for: userId)
            }
        } else {
            if userId >= 0 {
                // Existing contact.
                // TODO: the assert should go away. This code is in active development.
                // We need to catch potential issues with it.
                assert(userDb.update(
                    userId: userId,
                    updated: sub.updated,
                    serializedPub: sub.serializePub()))
            } else {
                // New contact.
                userDb.insert(sub: sub)
            }
        }
    }
}