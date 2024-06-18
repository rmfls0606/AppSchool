import UIKit
import Combine

Just(42)
    
    .print()
    .sink{ value in
        print("Received : \(value)")
        
    }
