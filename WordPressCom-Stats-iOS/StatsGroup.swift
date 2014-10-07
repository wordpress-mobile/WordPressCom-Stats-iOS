import Foundation

class StatsGroup {
    var items: Array<StatsItem>
    var titlePrimary: String
    var titleSecondary: String
    var icon: UIImage?
    
    init(items: Array<StatsItem>, titlePrimary: String, titleSecondary: String, icon: UIImage?) {
        self.items = items
        self.titlePrimary = titlePrimary
        self.titleSecondary = titleSecondary
        self.icon = icon
    }
}