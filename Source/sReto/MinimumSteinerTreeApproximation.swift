//
//  MinimumSteinerTreeApproximation.swift
//  sReto
//
//  Created by Julian Asamer on 16/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

struct MetricClosureEdgeAnnotation<V>: WeightedEdgeAnnotation {
    var path: [V] = []
    var weight: Double
    
    static func combine(edge1: MetricClosureEdgeAnnotation<V>, _ edge2: MetricClosureEdgeAnnotation<V>, _ separatingVertex: V) -> MetricClosureEdgeAnnotation<V> {
        return MetricClosureEdgeAnnotation(path: edge1.path + [separatingVertex] + edge2.path, weight: edge1.weight + edge2.weight)
    }
}

extension MetricClosureEdgeAnnotation: CustomStringConvertible {
    var description: String {
        return "(\(path): \(weight))"
    }
}

extension Graph {
    /**
    * Computes an approximation of a directed minimum steiner tree in this graph.
    * @param rootVertex The vertex at which the directed minimum steiner tree should be rooted.
    * @param includedVertices A set of vertices that should be included in the minimum steiner tree.
    * @return A tree representation of the computed tree.
    */
    func getSteinerTreeApproximation(rootVertex rootVertex: V, includedVertices: Set<V>) -> Tree<V> {
        return Graph.reconstruct(
            self.getMetricClosure(includedVertices).getMinimumAborescenceGraph(rootVertex)
        )
        .constructTree(rootVertex)
    }
    
    /**
    * Computes the metric closure with a given set of vertices over this graph.
    * @param vertices A set of vertices which should exist in the metric closure.
    * @return A Graph that uses MetricClosureEdgeAnnotations that store the paths in the original graph to allow later reconstruction.
    */
    func getMetricClosure(vertices: Set<V>) -> Graph<V, MetricClosureEdgeAnnotation<V>> {
        var metricClosure = self.mapEdges { MetricClosureEdgeAnnotation<V>(path: [], weight: $0.weight) }

        let eliminatedVertices = metricClosure.allVertices - vertices
        for eliminatedVertex in eliminatedVertices {
            let incomingEdges = metricClosure.getEdges(endingAtVertex: eliminatedVertex) ?? []
            let outgoingEdges = metricClosure.getEdges(startingAtVertex: eliminatedVertex) ?? []
            
            metricClosure.removeVertex(eliminatedVertex)
            for previousEdge in incomingEdges {
                for followingEdge in outgoingEdges {
                    if previousEdge.startVertex == followingEdge.endVertex { continue }
                    
                    if let shortestEdge = metricClosure.getShortestEdge(startingAtVertex: previousEdge.startVertex, endingAtVertex: followingEdge.endVertex) {
                        if shortestEdge.annotation.weight < previousEdge.annotation.weight + followingEdge.annotation.weight {
                            continue
                        }
                    }
                    
                    metricClosure.removeEdges(startingAtVertex: previousEdge.startVertex, endingAtVertex: followingEdge.endVertex)
                    
                    let combinedEdge = MetricClosureEdgeAnnotation.combine(previousEdge.annotation, followingEdge.annotation, eliminatedVertex)
                    metricClosure.addEdge(previousEdge.startVertex, followingEdge.endVertex, combinedEdge)
                }
            }
        }
                
        return metricClosure
    }
    /**
    * Reconstructs the original graph from a metric closure (i.e. a graph that contains all vertices that were used in the edges of the metric closure).
    * @param metricClosure a metric closure
    * @return The reconstructed graph
    */
    static func reconstruct<V>(metricClosure: Graph<V, MetricClosureEdgeAnnotation<V>>) -> Graph<V, DefaultEdge> {
        var result = Graph<V, DefaultEdge>()

        for (startVertex, edges) in metricClosure.adjacencyList {
            for (endVertex, edge) in edges {
                let fullPath = [startVertex] + edge.path + [endVertex]
                for (vertex1, vertex2) in pairwise(fullPath).filter({ !(result.contains(vertex: $0.0) && result.contains(vertex: $0.1)) }) {
                    result.addEdge(vertex1, vertex2, DefaultEdge())
                }
            }
        }

        return result
    }
    
    /**
    * Constructs a Tree representation from this graph, by exploring it recursively. May only be called on a graph that does not contain cycles.
    * @param startVertex The vertex at which to start exploring the graph.
    * @return A Tree representing the explored graph.
    */
    private func constructTree(startVertex: V) -> Tree<V> {
        return Tree(value: startVertex, subtrees: Set((self.getEdges(startingAtVertex: startVertex) ?? []).map { self.constructTree($0.endVertex) }))
    }
}

