import Foundation

struct StatsItemAction {
    var url: NSURL?
    var label: String?
    var icon: UIImage?
    var defaultAction: Bool = false
}

class StatsItem {
    var value: NSNumber
    var label: String
    var icon: UIImage?
    var actions: Array<StatsItemAction>
    var children: Array<StatsItem>
    
    init(value: NSNumber, label: String, icon: UIImage?, actions: Array<StatsItemAction>, children: Array<StatsItem>) {
        self.value = value
        self.label = label
        self.icon = icon
        self.actions = actions
        self.children = children
    }
}