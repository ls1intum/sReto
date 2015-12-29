//
//  PriorityQueue.swift
//  sReto
//
//  Created by Julian Asamer on 19/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
A naive implementation of a PriorityQueue.
Keeps an array of elements that are is sorted by priority.
The only fast operation is removeMinimum.
Insert and update updatePriority are both O(n).
*/
struct SortedListPriorityQueue<T: Hashable> {
    var elements: [(Double, T)] = []
    
    // Binary search for the appropiate index for the value
    private func searchIndex(start: Int, end: Int, value: Double) -> Int {
        if start == end {
            return start
        } else {
            let middle = start + (end - start)/2
            
            if value >= elements[middle].0 {
                return searchIndex(start, end: middle, value: value)
            } else {
                return searchIndex(middle+1, end: end, value: value)
            }
        }
    }
    
    mutating func insert(element: T, priority: Double) {
        let index = searchIndex(0, end: self.elements.count, value: priority)
        elements.insert( (priority, element), atIndex: index)
    }
    mutating func removeMinimum() -> T? {
        if let result = elements.last {
            elements.removeLast()
            return result.1
        }
        
        return nil
    }
    // There's no faster way to do remove with this kind of implementation.
    mutating func remove(element: T) {
        elements = elements.filter({ $0.1 != element })
    }
    mutating func updatePriority(element: T, priority: Double) {
        self.remove(element) // Oh noes.
        self.insert(element, priority: priority)
    }
}
