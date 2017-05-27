//
//  EventQueue.swift
//  TinyPocketCar
//
//  Created by Nathan Birkholz on 5/26/17.
//  Copyright © 2017 natebirkholz. All rights reserved.
//

import Foundation

struct EventQueue<T: Comparable, Equatable> {
    fileprivate var eventArray = [T] ()
    let capacity: Int
    fileprivate(set) var lastElement: T?

    init(withCapacity cap: Int) {
        capacity = cap
    }

    mutating func add(_ element: T) {
        lastElement = eventArray[0]
        eventArray.insert(element, at: 0)
        if eventArray.count > capacity + 1 {
            let removed = eventArray.remove(at: capacity)
            print("bye bye, \(removed)")
        }
    }

    mutating func clear() {
        lastElement = nil
        eventArray = [T]()
    }

    subscript(position: Int) -> T {
        get {
            return eventArray[position]
        }
    }
}

extension EventQueue: CustomStringConvertible {
    var description: String {
        let lastString: String
        if let last = lastElement {
            lastString = "\(last)"
        } else {
            lastString = "nil"
        }

        return "capacity: \(capacity), last: \(lastString), elements: \(eventArray)"
    }
}
