//
//  GraphTests.swift
//  sReto
//
//  Created by Julian Asamer on 20/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import XCTest

import Foundation


class GraphTests: XCTestCase {
    func testBasicGraphOperations() {
        var graph = Graph<String, DefaultEdge>()
        graph.addVertex("A")
        
        XCTAssert(graph.allVertices.contains("A"), "Vertex not added")
        
        graph.addEdge("A", "B", DefaultEdge(weight: 1))
        
        XCTAssert(graph.allVertices.contains(["A", "B"]), "Edges end not added")
        
        graph.removeVertex("B")
        let a = "A"
        
        XCTAssert(graph.allVertices.contains(["A"]), "Vertex removed")
        XCTAssert(!graph.allVertices.contains(["B"]), "Vertex not removed")
        XCTAssert((graph.getEdges(startingAtVertex: "A")?.count ?? 0) == 0, "Edge not removed: edges \(graph.getEdges(startingAtVertex: a))")
        XCTAssert(graph.getEdges(startingAtVertex: "B") == nil, "Edges not nil")
        
        graph.addEdge("A", "B", DefaultEdge(weight: 1))
        graph.removeEdges(startingAtVertex: "A", endingAtVertex: "B")
        
        XCTAssert(graph.getEdges(startingAtVertex: "A")?.count == .Some(0), "Edge not removed")
        
        graph.addEdge("A", "B", DefaultEdge(weight: 1))
        graph.addEdge("A", "C", DefaultEdge(weight: 1))
        graph.removeEdges(startingAtVertex: "A")
        XCTAssert(graph.allVertices.contains(["A", "B", "C"]), "Vertex removed")
        XCTAssert(graph.getEdges(startingAtVertex: "A")?.count == .Some(0), "Edges not removed")
    }
    
    func testDijkstraTrivial() {
        let graph = Graph<String, DefaultEdge>(["A": []])
        if let (path, length) = graph.shortestPath("A", end: "A") {
            XCTAssert(length == 0, "Length is not 0")
            XCTAssert(path == ["A"], "Path incorrect")
        } else {
            XCTAssert(false, "No path found.")
        }
    }
    
    func testDijkstraTrivial2() {
        let graph = Graph<String, DefaultEdge>(["A": [("B", DefaultEdge(weight: 1))]])
        print(graph.allVertices)
        if let (path, length) = graph.shortestPath("A", end: "B") {
            XCTAssert(length == 1, "Length is not 1")
            XCTAssert(path == ["A", "B"], "Path incorrect")
        } else {
            XCTAssert(false, "No path found.")
        }
    }
    
    func testDijkstraSimpleGraph() {
        let graph = Graph<String, DefaultEdge>([
                "A": [("B", DefaultEdge(weight: 1))],
                "B": [("C", DefaultEdge(weight: 1))],
                "C": [("A", DefaultEdge(weight: 1))],
                "D": []
            ]
        )
        
        if let (path, length) = graph.shortestPath("A", end: "C") {
            XCTAssert(length == 2, "Length is not 2")
            XCTAssert(path == ["A", "B", "C"], "Path incorrect")
        } else {
            XCTAssert(false, "No path found.")
        }
        
        XCTAssert(graph.shortestPath("A", end: "D") == nil, "Found non-existant path")
        
        let (predecessors, distances) = graph.shortestPaths("A")
        XCTAssert(predecessors == ["B": "A", "C": "B"], "Incorrect predecessors")
        XCTAssert(distances == ["A": 0, "B": 1.0, "C": 2.0], "Incorrect distances (\(distances))")
    }
}
