//
//  Set.swift
//  sReto
//
//  Created by Julian Asamer on 15/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

extension Set {
        
    /** Tests whether a all elements in a given array are all members of this set. */
    func contains(elements: [Element]) -> Bool {
        return elements.map { self.contains($0) }.reduce(true, combine: { a, b in return a && b } )
    }
}

/** Adds an element to a set. */
@transparent func +=<Element>(inout set: Set<Element>, element: Element) {
    set.insert(element)
}
/** Removes an element from a set. */
@transparent func -=<T>(inout set: Set<T>, i: T) {
    set.remove(i)
}
/** Adds a sequence of elements to a set. */
func +=<Element, S : SequenceType where S.Generator.Element == Element>(inout lhs: Set<Element>, rhs: S) {
    lhs = lhs.union(rhs)
}
/** Adds a set to a set. */
func +<Element>(lhs: Set<Element>, rhs: Set<Element>) -> Set<Element> {
    return lhs.union(rhs)
}
/** Removes a Set from a Set. */
func -<Element>(lhs: Set<Element>, rhs: Set<Element>) -> Set<Element> {
    return lhs.subtract(rhs)
}
