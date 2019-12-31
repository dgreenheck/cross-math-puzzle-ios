//
//  CrossGrid.swift
//  CrossMathPuzzle
//
//  Created by Daniel Greenheck on 2/18/19.
//  Copyright © 2019 Max Q Software LLC. All rights reserved.
//

import Foundation
import UIKit

class PuzzleGrid {
    // --- Static variables ---
    static var MIN_SIZE: Int = 5
    static var MAX_SIZE: Int = 7
    static var DEFAULT_SIZE: Int = 5
    static var MAX_USER_VALUE: Int = 9
    
    // --- Instance variables ---
    var size: Int
    var grid: [[GridCell?]]
    
    init(size: Int, generateRandomGrid: Bool) {
        
        // Validate the size input
        if size < PuzzleGrid.MIN_SIZE {
            self.size = PuzzleGrid.MIN_SIZE
        }
        else if size > PuzzleGrid.MAX_SIZE {
            self.size = PuzzleGrid.MAX_SIZE
        }
        else {
            self.size = size
        }
        
        // Initialize empty 2D array of grid cells
        grid = [[GridCell?]](repeating: [GridCell?](repeating: nil, count: size), count: size)
        
        // Fill in the grid with cells of the correct type
        for row in 0..<size {
            for column in 0..<size {
                // Last row
                if row == (size-1) {
                    if column % 2 == 0 {
                        grid[row][column] = ResultsCell(value: 0)
                    }
                    else {
                        grid[row][column] = BlankCell()
                    }
                }
                // Last column
                else if column == (size-1) {
                    if row % 2 == 0 {
                        grid[row][column] = ResultsCell(value: 0)
                    }
                    else {
                        grid[row][column] = BlankCell()
                    }
                }
                // 2nd to last row
                else if row == (size-2) {
                    if column % 2 == 0 {
                        grid[row][column] = OperatorCell(mathOperator: .equals)
                    }
                    else {
                        grid[row][column] = BlankCell()
                    }
                }
                // 2nd to last column
                else if column == (size-2) {
                    if row % 2 == 0 {
                        grid[row][column] = OperatorCell(mathOperator: .equals)
                    }
                    else {
                        grid[row][column] = BlankCell()
                    }
                }
                // Cells with even row/column are numeric cells
                else if (row % 2 == 0) && (column % 2 == 0) {
                    grid[row][column] = NumericEntryCell(value: 0, userValue: nil)
                }
                // Cells adjacent to numeric cells are the math operators
                else if (row + column) % 2 != 0 {
                    grid[row][column] = OperatorCell(mathOperator: .add)
                }
                // All other cells are blank
                else {
                    grid[row][column] = BlankCell()
                }
            }
        }
        // Bottom-right cell is blank
        grid[size-1][size-1] = BlankCell()
        
        if generateRandomGrid {
            randomize()
        }
    }
    
    // Create a randomized grid
    func randomize() {
        // Randomly select truth values for numeric entry cells and
        // operators for math operator cells
        for row in 0..<size-2 {
            for column in 0..<size-2 {
                guard let cell = grid[row][column] else { continue }
                
                if let numericCell = cell as? NumericEntryCell {
                    // Randomly select a value between 1 and the max value
                    numericCell.value = Int.random(in: 1...PuzzleGrid.MAX_USER_VALUE)
                }
                else if let mathOperatorCell = cell as? OperatorCell {
                    // For large puzzles, only use addition operators
                    if size == PuzzleGrid.MAX_SIZE {
                        mathOperatorCell.mathOperator = .add
                    }
                    // For small puzzles, allow both addition and multiplication
                    else {
                        let i = Int.random(in: 1...2)
                        
                        // Randomly select an operator
                        switch(i) {
                        case 1: mathOperatorCell.mathOperator = .multiply
                        default: mathOperatorCell.mathOperator = .add
                        }
                    }
                }
            }
        }
        
        // Compute result for rows. Only even rows matter
        for row in stride(from: 0, to: size-1, by: 2) {
            var tempResult: Int = 0
            // Technically don't know the operator at this point,
            // but would rather default to addition than have an
            // optional operator and handle a nil value
            var op: MathOperator = MathOperator.add
            
            for column in 0..<(size-2) {
                guard let cell = grid[row][column] else { continue }
                
                // Number
                if let numericCell = cell as? NumericEntryCell {
                    // If first column, store value
                    if column == 0 {
                        tempResult = numericCell.value
                    }
                    // Otherwise compute math operation
                    else {
                        switch(op) {
                        case.multiply:
                            tempResult *= numericCell.value
                            break
                        // Default to addition
                        default:
                            tempResult += numericCell.value
                            break
                        }
                    }
                }
                else if let mathOperatorCell = cell as? OperatorCell {
                    op = mathOperatorCell.mathOperator
                }
            }
            
            // Store result in the cell
            if let resultCell = grid[row][size-1] as? ResultsCell {
                resultCell.value = tempResult
            }
        }
        
        // Compute result for columns. Only even rows matter
        for column in stride(from: 0, to: size-1, by: 2) {
            var tempResult: Int = 0
            // Technically don't know the operator at this point,
            // but would rather default to addition than have an
            // optional operator and handle a nil value
            var op: MathOperator = MathOperator.add
            
            for row in 0..<(size-2) {
                guard let cell = grid[row][column] else { continue }
                
                // Number
                if let numericCell = cell as? NumericEntryCell {
                    // If row column, store value
                    if row == 0 {
                        tempResult = numericCell.value
                    }
                        // Otherwise compute math operation
                    else {
                        switch(op) {
                        case.multiply:
                            tempResult *= numericCell.value
                            break
                        // Default to addition
                        default:
                            tempResult += numericCell.value
                            break
                        }
                    }
                }
                else if let mathOperatorCell = cell as? OperatorCell {
                    op = mathOperatorCell.mathOperator
                }
            }
            
            // Store result in the cell
            if let resultCell = grid[size-1][column] as? ResultsCell {
                resultCell.value = tempResult
            }
        }
    }
}

protocol GridCell {
    func toString() -> String
}

class NumericEntryCell: GridCell {
    let MIN_VALUE = 0
    let MAX_VALUE = 9
    
    // The correct value the user is trying to guess
    var value: Int
    // The user's guess
    var userValue : Int? {
        didSet {
            guard let pendingValue = userValue else {return}
            
            // Check bounds on value
            if pendingValue > MAX_VALUE || pendingValue < MIN_VALUE {
                userValue = oldValue
            }
        }
    }
    
    init(value: Int, userValue: Int?) {
        self.value = value
        self.userValue = userValue
    }
    
    func toString() -> String {
        // If no value in cell yet, return empty string
        guard let value = userValue else {return ""}
        
        return String(value)
    }
}

class ResultsCell: GridCell {
    var value : Int
 
    init(value : Int) {
        self.value = value
    }
    
    func toString() -> String {
        return String(value)
    }
}

class OperatorCell: GridCell {
    var mathOperator: MathOperator
    
    init(mathOperator: MathOperator) {
        self.mathOperator = mathOperator
    }
    
    func toString() -> String {
        return String(mathOperator.rawValue)
    }
}

class BlankCell: GridCell {
    func toString() -> String {
        return ""
    }
}

enum MathOperator: Character {
    case add = "+", multiply = "×", equals = "="
}
