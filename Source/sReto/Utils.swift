//
//  Utils.swift
//  sReto
//
//  Created by Julian Asamer on 07/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

func NSMakeRange(range: Range<Int>) -> NSRange {
    return NSMakeRange(range.startIndex, range.endIndex - range.startIndex)
}

// Returns the first element of a sequence
func first<S: SequenceType, E where E == S.Generator.Element>(sequence: S) -> E? {
    for element in sequence { return element }
    return nil
}

// Returns the second element of a sequence
func second<S: SequenceType, E where E == S.Generator.Element>(sequence: S) -> E? {
    var first = true
    for element in sequence { if first { first = false } else { return element } }
    return nil
}

func reduce<S: SequenceType, E where S.Generator.Element == E>(sequence: S, combine: (E, E) -> E) -> E? {
    if let first = first(sequence) {
        return reduce(sequence, first, combine)
    } else {
        return nil
    }
}

func pairwise<T>(elements: [T]) -> [(T, T)] {
    var elementCopy = elements
    elementCopy.removeAtIndex(0)
    return Array(Zip2(elements, elementCopy))
}

func sum<S: SequenceType where S.Generator.Element == Int>(sequence: S) -> Int {
    return reduce(sequence, 0, +)
}
func sum<S: SequenceType where S.Generator.Element == Float>(sequence: S) -> Float {
    return reduce(sequence, 0, +)
}
// Takes a key extractor that maps an element to a comparable value, and returns a function that compares to objects of type T via the extracted key.
func comparing<T, U: Comparable>(withKeyExtractor keyExtractor: (T) -> U) -> ((T, T) -> Bool) {
    return { a, b in keyExtractor(a) < keyExtractor(b) }
}

func equal<S: CollectionType, T where S.Generator.Element == T>(comparator: (T, T) -> Bool, s1: S, s2: S) -> Bool {
    return (countElements(s1) == countElements(s2)) && reduce(Zip2(s1, s2), true, { value, pair in value && comparator( pair.0, pair.1) })
}

// Returns the non-nil parameter if only one of them is nil, nil if both parameters are nil, otherwise the minimum.
func min<T: Comparable>(a: T?, b: T?) -> T? {
    switch (a, b) {
    case (.None, .None): return nil
    case (.None, .Some(let value)): return value
    case (.Some(let value), .None): return value
    case (.Some(let value1), .Some(let value2)): return min(value1, value2)
    }
}

func minimum<T>(a: T, b: T, comparator: (T, T) -> Bool) -> T { return comparator(a, b) ? a : b }
func minimum<T, S: SequenceType where S.Generator.Element == T>(sequence: S, comparator: (T, T) -> Bool) -> T? {
    if let first = first(sequence) {
        return reduce(sequence, first, { (a, b) -> T in return minimum(a, b, comparator) })
    }
    return nil
}

// Compares two sequences with comparable elements. 
// The first non-equal element that exists in both sequences determines the result.
// If no non-equal element exists (either because one sequence is longer than the other, or they are equal) false is returned.
func < <S: SequenceType, T: SequenceType where S.Generator.Element: Comparable, S.Generator.Element == T.Generator.Element>(a: S, b: T) -> Bool {
    if let (a, b) = first(lazy(Zip2(a, b)).filter({ pair in pair.0 != pair.1 })) {
        return a < b
    }
    
    return false
}

extension Dictionary {
    mutating func getOrDefault(key: Key, defaultValue: @autoclosure() -> Value) -> Value {
        if let value = self[key] {
            return value
        } else {
            let value = defaultValue()
            self[key] = value
            return value
        }
    }
}

struct Queue<T: AnyObject> {
    typealias Element = T
    var array: [T] = []
    
    var count: Int { get { return array.count } }
    
    mutating func enqueue(element: Element) {
       array.append(element)
    }
    
    mutating func dequeue() -> Element? {
        if array.count == 0 { return nil }
        return array.removeAtIndex(0)
    }
    
    func anyMatch(predicate: (Element) -> Bool) -> Bool {
        for element in array { if predicate(element) { return true } }
        
        return false
    }
    
    mutating func filter(predicate: (Element) -> Bool) {
        self.array = array.filter({ element in predicate(element) })
    }
}

extension Dictionary {
    func map<NewKey: Hashable, NewValue>(mapping: (Key, Value) -> (NewKey, NewValue)) -> [NewKey: NewValue] {
        var dictionary: [NewKey: NewValue] = [:]
        
        for (key, value) in self {
            let (newKey, newValue) = mapping(key, value)
            dictionary[newKey] = newValue
        }
        
        return dictionary
    }
    
    func mapValues<NewValue>(mapping: (Key, Value) -> NewValue) -> [Key: NewValue] {
        return self.map { return ($0, mapping($0, $1)) }
    }
}
