//
//  Tree.swift
//  sReto
//
//  Created by Julian Asamer on 15/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/** 
* This class represents a general tree. Each tree has any number of subtrees.
* A tree that has no subtrees is a leaf. The size of a tree is the size of all of its children plus one. 
* Each tree has an associated value. */
class Tree<T: Hashable> {
    /** The tree's associated value */
    let value: T
    /** The tree's subtrees */
    let subtrees: Set<Tree<T>> = []
    /** The tree's size */
    var size: Int { get { return reduce(subtrees.map({ $0.size }), 1, +) } }
    /** Whether the tree is a leaf */
    var isLeaf: Bool { get { return subtrees.count == 0 } }
    
    /** Constructs a new tree given a value and a set of subtrees. */
    init(value: T, subtrees: Set<Tree<T>>) {
        self.value = value
        self.subtrees = subtrees
    }
}

extension Tree: Hashable {
    var hashValue: Int { get { return self.value.hashValue } }
}

/** Two trees are equal if their values and subtrees are equal.*/
func ==<T: Equatable>(tree1: Tree<T>, tree2: Tree<T>) -> Bool {
    return tree1.value == tree2.value && tree1.subtrees == tree2.subtrees
}

extension Tree: Printable {
    var description: String { get { return "{value: \(value), children: \(subtrees)}" } }
}