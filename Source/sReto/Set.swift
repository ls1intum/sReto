//
//  Set.swift
//  sReto
//
//  Created by Julian Asamer on 15/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* This class represents a Set using Swift language features and is a type-safe counterpart to NSSet and NSMutableSet.
*
* A set is an unordered collection of elements that contains each element only once.
* Sets are optimized to test for the membership of an element quickly.
* For this purpose, elements contained in a set need to be Hashable.
*
* Sets can be constructed using array literals (e.g. `let set: Set = ["a", "b", "c"]`), and support multiple common operators to modify elements.
*/
public struct Set<T : Hashable> {
    typealias Element = T
    
    private var internalDictionary: Dictionary<T, ()> = [:]
    
    /** The number of elements in this set. */
    var count: Int {
        return internalDictionary.count
    }
    /** Whether the set is empty or not. */
    var isEmpty: Bool {
        return self.count == 0
    }
    
    public var hashValue: Int {
        return reduce(internalDictionary.keys, 0) { $0.hashValue ^ $1.hashValue }
    }
    init() {}
    private init(internalDictionary: [T: ()]) {
        self.internalDictionary = internalDictionary
    }
    /** Constructs a Set from any given sequence. */
    init<S: SequenceType where S.Generator.Element == T>(_ sequence: S) {
        var g = sequence.generate() // TODO: using a normal for in loop crashes the compiler.
        while let element: T = g.next() {
            internalDictionary[element] = ()
        }
    }
    /** Constructs a Set from an NSSet. */
    init(nsset: NSSet) {
        for value in nsset {
            internalDictionary[value as T] = ()
        }
    }
    /** Maps the set's values. See Array's map. */
    func map<U: Hashable>(transform: (T) -> U) -> Set<U> {
        return Set<U>(internalDictionary: self.internalDictionary.map( { key, value in (transform(key), value) }))
    }
    /** Filters the set using a given predicate. See Array's filter. */
    func filter(condition: (T) -> Bool) -> Set<T> {
        var result: Set<T> = []
        
        for (member, _) in internalDictionary {
            if condition(member) {
                result += member
            }
        }
        
        return result
    }
    /** Tests whether a given element is a memeber of this set. */
    func contains(element: T) -> Bool {
        return internalDictionary[element] != nil
    }
    /** Tests whether a all elements in a given array are all members of this set. */
    func contains(elements: [T]) -> Bool {
        return elements.map { self.contains($0) }.reduce(true, { a, b in return a && b } )
    }
    
    // for-in
    public func generate() -> IndexingGenerator<Array<T>> {
        return ([] + internalDictionary.keys).generate()
    }
}

/** Allows the construction of sets using array literals. */
extension Set : ArrayLiteralConvertible {
    public init(arrayLiteral elements: Element...) {
        var ret: Dictionary<T, ()> = [:]
        for e in elements {
            ret[e] = ()
        }
        
        self.internalDictionary = ret
    }
}

extension Set : Printable, DebugPrintable {
    public var description: String {
        return ([] + internalDictionary.keys).description
    }
    
    public var debugDescription: String {
        return ([] + internalDictionary.keys).debugDescription
    }
}

public func ==<T>(a: Set<T>, b: Set<T>) -> Bool {
    for (k, _) in a.internalDictionary {
        if b.internalDictionary[k] == nil {
            return false
        }
    }
    for (k, _) in b.internalDictionary {
        if a.internalDictionary[k] == nil {
            return false
        }
    }
    return true
}

extension Set : Equatable {}
extension Set : SequenceType {}
extension Set : Hashable {}

/** Adds an element to a set. */
@transparent func +=<T>(inout s: Set<T>, i: T) {
    s.internalDictionary[i] = ()
}
/** Removes an element from a set. */
@transparent func -=<T>(inout s: Set<T>, i: T) {
    s.internalDictionary[i] = nil
}
/** Adds a sequence of elements to a set. */
func +=<T, S : SequenceType where S.Generator.Element == T>(inout lhs: Set<T>, rhs: S) {
    for i in rhs {
        lhs += i
    }
}
/** Adds a set to a set. */
func +<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return union(lhs, rhs)
}
/** Removes a Set from a Set. */
func -<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    var ret = Set<T>()
    for i in lhs {              // in lhs
        if rhs.internalDictionary[i] == nil {       // not in rhs
            ret += i
        }
    }
    return ret
}
/** Computes the union of two sets. */
func union<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    var ret = Set<T>()
    for i in lhs {
        ret += i
    }
    for i in rhs {
        ret += i
    }
    return ret
}
/** Computes the intersection of two sets. */
func intersect<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    var ret = Set<T>()
    for i in lhs {              // in lhs
        if rhs.internalDictionary[i] != nil {       // not in rhs
            ret += i
        }
    }
    return ret
}

struct SetGenerator<Key: Hashable> : GeneratorType {
    var _base: DictionaryGenerator<Key, ()>;
    mutating func next() -> Key? { return self._base.next()?.0 }
}
