//
//  DelayedExecutor.swift
//  sReto
//
//  Created by Julian Asamer on 15/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* A RepeatedExecutor executes an action repeatedly with a certain delay. On demand, the action can also be triggered immediately or after a short delay.
* */
class RepeatedExecutor {
    let regularDelay: Timer.TimeInterval
    let shortDelay: Timer.TimeInterval
    let dispatchQueue: dispatch_queue_t
    
    var action: (()->())? = nil
    var isStarted: Bool = false
    weak var timer: Timer?
    
    /**
    * Constructs a new RepeatableExecutor.
    *
    * @param actüion The action to execute.
    * @param regularDelay The delay in which the action is executed by default.
    * @param shortDelay The delay used when runActionInShortDelay is called.
    * @param executor The executor to execute the action with.
    * */
    init(regularDelay: Timer.TimeInterval, shortDelay: Timer.TimeInterval, dispatchQueue: dispatch_queue_t) {
        self.regularDelay = regularDelay
        self.shortDelay = shortDelay
        self.dispatchQueue = dispatchQueue
    }
    /**
    * Starts executing the action in regular delays.
    * */
    func start(action: ()->()) {
        if self.isStarted {
            return
        }
        
        self.action = action
        self.isStarted = true
        self.resume()
    }
    /**
    * Stops executing the action in regular delays.
    * */
    func stop() {
        if !self.isStarted { return }

        self.action = nil
        self.isStarted = false
        self.interrupt()
    }
    
    /**
    * Runs the action immediately. Resets the timer, the next execution of the action will occur after the regular delay.
    * */
    func runActionNow() {
        self.resetTimer()
        self.action?()
    }
    
    /**
    * Runs the action after the short delay. After this, actions are executed in regular intervals again.
    * */
    func runActionInShortDelay() {
        self.interrupt()
        self.timer = Timer.delay(
            self.shortDelay,
            dispatchQueue: self.dispatchQueue,
            action: {
                () -> () in
                self.action?()
                self.resume()
            }
        )
    }

    private func interrupt() {
        self.timer?.stop()
        self.timer = nil
    }
    
    private func resume() {
        if !self.isStarted {
            return
        }
        
        self.timer = Timer.repeatAction(
            interval: self.regularDelay,
            dispatchQueue: self.dispatchQueue,
            action: {
                (timer, executionCount) -> () in
                self.action?()
                return
            }
        )
    }
    
    private func resetTimer() {
        self.interrupt()
        self.resume()
    }
}