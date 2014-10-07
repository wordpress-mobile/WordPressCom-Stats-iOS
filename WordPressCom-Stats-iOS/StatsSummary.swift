import Foundation

class StatsSummary {
    var views: NSNumber
    var visitors: NSNumber
    var likes: NSNumber
    var reblogs: NSNumber
    var comments: NSNumber
    
    init(views: NSNumber, visitors: NSNumber, likes: NSNumber, reblogs: NSNumber, comments: NSNumber) {
        self.views = views
        self.visitors = visitors
        self.likes = likes
        self.reblogs = reblogs
        self.comments = comments
    }
}