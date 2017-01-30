//
//  Copyright © 2015 Egghead Games LLC. All rights reserved.
//

import UIKit

@objc enum Difficulty: Int {
    case Easy = 1, Medium, Hard
}

@objc enum GameState: Int {
    case NotStarted = 0, Started, Solved
}


class ACPuzzleCell: UICollectionViewCell {
    
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var mNumberLabel: UILabel!
    @IBOutlet weak var mStateImageView: UIImageView!
    @IBOutlet weak var mItemButton: UIButton!

    private let difficultyImages: [String] = ["puzzle_difficulty_easy", "puzzle_difficulty_medium", "puzzle_difficulty_hard"]
    private let startedImages: [String] = ["puzzle_state_processing_easy", "puzzle_state_processing_medium", "puzzle_state_processing_hard"]
    private let solvedImages: [String] = ["puzzle_state_solved", "puzzle_state_perfect"]
    
    func setGameItemState(status: GameState, difficulty: Difficulty, number: Int, isPerfect: Bool) {

        self.mNumberLabel.text = "\(number)"
        switch status {
        case .NotStarted:
            self.mStateImageView.image = UIImage(named: difficultyImages[difficulty.rawValue - 1])
        case .Started:
            self.mStateImageView.image = UIImage(named: startedImages[difficulty.rawValue - 1])
        case .Solved:
            self.mStateImageView.image = UIImage(named: solvedImages[isPerfect ? 1 : 0])
        }
    }
}
