//
//  StateSequence.swift
//  sReto
//
//  Created by Julian Asamer on 21/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/** 
* The iterateMapping function creates a sequence by applying a mapping to a state an arbitrary number of times.
* For example, iterateMapping(initialState: 0, { $0 + 1 }) constructs an infinite list of the numbers 0, 1, 2, ...
*/
func iterateMapping<E>(#initialState: E, #mapping: (E) -> E?) -> MappingSequence<E> {
    return MappingSequence(initialState: initialState, mapping: mapping)
}
struct MappingGenerator<E>: GeneratorType {
    typealias Element = E
    var state: E?
    let mapping: (E) -> E?
    
    init(initialState: E, mapping: (E) -> E?) {
        self.state = initialState
        self.mapping = mapping
    }
    
    mutating func next() -> Element? {
        let result = self.state
        if let state = self.state { self.state = self.mapping(state) }
        return result
    }
}

struct MappingSequence<E>: SequenceType {
    let initialState: E
    let mapping: (E) -> E?
    
    func generate() -> MappingGenerator<E> {
        return MappingGenerator(initialState: self.initialState, mapping: self.mapping)
    }
}
