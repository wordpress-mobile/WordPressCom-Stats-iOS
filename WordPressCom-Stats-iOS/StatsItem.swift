import Foundation

class StatsItem {
    var value: NSNumber?
    var label: String?
    var icon: UIImage?
    var actions: Array<AnyObject>?
    var children: Array<StatsItem>?
    
    init() {
        
    }
}