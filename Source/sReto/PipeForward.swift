//
//  PipeForward.swift
//  sReto
//
//  Created by Julian Asamer on 15/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* The pipe forward operator allows to inverse the order of function/parameter list.
* Eg., f(x) can be replaced with x |> f. This can increase code readability.
*/

infix operator |> { associativity left }
func |> <T,U>(lhs : T, rhs : T -> U) -> U {
    return rhs(lhs);
}

// Curried adapter function for Swift Standard Library's filter() function
func filter<S :SequenceType>(includeElement: (S.Generator.Element) -> Bool)(source: S) -> [S.Generator.Element] {
    let e: [S.Generator.Element] = source.filter(includeElement)
    return e
}

// Curried adapter function for Swift Standard Library's sorted() function
func sorted<S : SequenceType>(predicate: (S.Generator.Element, S.Generator.Element) -> Bool)(source: S) -> [S.Generator.Element] {
    return source.sort(predicate)
}

// Curried adapter function for Swift Standard Library's map() function
func map<C : SequenceType, T>(transform: (C.Generator.Element) -> T)(source: C) -> [T] {
    return source.map(transform)
}

// Curried adapter function for Swift Standard Library's reduce() function
func reduce<S: SequenceType, U>(initial: U, combine: (U, S.Generator.Element) -> U)(sequence: S) -> U {
    return sequence.reduce(initial, combine: combine)
}

// version of enumerate that works with forward piping
func seqEnumerate<S: SequenceType>(sequence: S) -> AnySequence<(index: Int, element: S.Generator.Element)> {
    return AnySequence(sequence.enumerate())
}
