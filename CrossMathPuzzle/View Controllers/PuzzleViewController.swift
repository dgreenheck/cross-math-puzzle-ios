//
//  PuzzleViewController.swift
//  CrossMathPuzzle
//
//  Created by Daniel Greenheck on 2/18/19.
//  Copyright © 2019 Max Q Software LLC. All rights reserved.
//

import UIKit

class PuzzleViewController: UIViewController {
    // Default number of rows/columns in puzzle when the view controller is first initialized
    
    // Adding comment to test Git integration
    
    var puzzle: PuzzleGrid?
    @IBOutlet weak var puzzleStackView: UIStackView!
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(PuzzleViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        // Create view controls for the puzzle
        createPuzzleGridView()
    }
    
    @IBAction func didTapView(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func createNumericEntryCell(numericEntryCell: NumericEntryCell) -> UITextField {
        let cellTextField = UITextField()
        
        // Border style must be none or height will not size appropriately
        cellTextField.borderStyle = .none
        // Only allow numeric entry
        cellTextField.keyboardType = .numberPad
        
        if let userValue = numericEntryCell.userValue {
            cellTextField.text = String(userValue)
        }
        else {
            cellTextField.text = ""
        }
        cellTextField.font = UIFont.systemFont(ofSize: 18)
        cellTextField.textAlignment = .center
        
        cellTextField.backgroundColor = UIColor.green
        
        // *** Set constraints ***
        cellTextField.widthAnchor.constraint(equalToConstant: 48).isActive = true
        cellTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        return cellTextField
    }
    
    func createMathOperatorCell(mathOperator: MathOperator) -> UILabel {
        let cellLabel = UILabel()
        
        cellLabel.text = String(mathOperator.rawValue)
        cellLabel.textAlignment = .center
        cellLabel.backgroundColor = UIColor.lightGray
        
        // *** Set constraints ***
        cellLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        cellLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        return cellLabel
    }
    
    func createResultCell(resultCell: ResultsCell) -> UILabel {
        let cellLabel = UILabel()
        
        cellLabel.text = String(resultCell.value)
        cellLabel.textAlignment = .center
        cellLabel.backgroundColor = UIColor.orange
        
        // *** Set constraints ***
        cellLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        cellLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        return cellLabel
    }
    
    func createBlankGridCell() -> UILabel {
        let cellLabel = UILabel()
        
        cellLabel.text = ""
        cellLabel.backgroundColor = UIColor.black
        
        // *** Set constraints ***
        cellLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        cellLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        return cellLabel
    }
    
    func createPuzzleGridView() {
        guard let puzzle = puzzle else { return }
        
        // Reset the main puzzle stack view by removing all existing controls
        for view in puzzleStackView.subviews{
            view.removeFromSuperview()
        }
        
        for i in 0..<puzzle.size {
            // Create a row of cells in the puzzle grid view
            let rowStackView: UIStackView!
            rowStackView = UIStackView(arrangedSubviews: [])
            rowStackView.axis = .horizontal
            rowStackView.alignment = .center
            rowStackView.distribution = .equalCentering
            rowStackView.spacing = 2
            
            for j in 0..<puzzle.size {
                guard let cell = puzzle.grid[i][j] else { continue }
                
                // For numeric fields, use text fields to allow user to enter in a guess.
                var cellContents : UIView
                if let entryCell = cell as? NumericEntryCell {
                    cellContents = createNumericEntryCell(numericEntryCell: entryCell)
                }
                else if let mathOperatorCell = cell as? OperatorCell {
                    cellContents = createMathOperatorCell(mathOperator: mathOperatorCell.mathOperator)
                }
                else if let resultCell = cell as? ResultsCell {
                    cellContents = createResultCell(resultCell: resultCell)
                }
                else {
                    cellContents = createBlankGridCell()
                }
                
                rowStackView.addArrangedSubview(cellContents)
            }
            
            puzzleStackView.addArrangedSubview(rowStackView) //extendedNavView is configured inside Storyboard
            rowStackView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
        
        
    }

    @IBAction func newPuzzleButtonClicked(_ sender: Any) {
        let largePuzzle = Bool.random()
        
        if largePuzzle {
            puzzle = PuzzleGrid(size: PuzzleGrid.MAX_SIZE, generateRandomGrid: true)
        }
        else {
            puzzle = PuzzleGrid(size: PuzzleGrid.DEFAULT_SIZE, generateRandomGrid: true)
        }
        
        createPuzzleGridView()
    }
    
    @IBAction func showSolutionClicked(_ sender: Any) {
        guard let puzzle = puzzle else { return }
        
        // For each numeric entry cell, set the corresponding UITextField's text
        // value to the true value of the cell
        for row in 0..<puzzle.size {
            for column in 0..<puzzle.size {
                // Get the UITextField corresponding to the puzzle cell at [row,column]
                guard let cell = puzzle.grid[row][column] as? NumericEntryCell else { continue }
                guard let rowStackView = puzzleStackView.subviews[row] as? UIStackView else { continue }
                guard let cellTextField = rowStackView.subviews[column] as? UITextField else {continue}
                
                cellTextField.text = String(cell.value)
            }
        }
    }
    
    @IBAction func checkAnswerClicked(_ sender: Any) {
        guard let puzzle = puzzle else { return }
        
        // For each numeric entry cell, set the corresponding UITextField's text
        // value to the true value of the cell
        for row in 0..<puzzle.size {
            for column in 0..<puzzle.size {
                // Get the UITextField corresponding to the puzzle cell at [row,column]
                guard let cell = puzzle.grid[row][column] as? NumericEntryCell else { continue }
                guard let rowStackView = puzzleStackView.subviews[row] as? UIStackView else { continue }
                guard let cellTextField = rowStackView.subviews[column] as? UITextField else {continue}
                
                // If entered value does not match underlying model, alert user
                // that their solution is incorrect
                if(cellTextField.text != String(cell.value)) {
                    let alert = UIAlertController(title: "Incorrect Solution", message: "Your solution is incorrect!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    // Exit function
                    return
                }
            }
        }
        
        // If no mismatch was detected, display alert congratulating user
        let alert = UIAlertController(title: "Congratulations!", message: "Your solution is correct!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
