import Foundation

public class StatsServiceRemote {
    let baseUrl = "https://public-api.wordpress.com/rest/v1.1"
    let stringStatsUrl: String
    var oauth2Token: String
    var siteId: Int
    var siteTimeZone: NSTimeZone
    
    //- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone

    public init(oauth2Token:String, siteId:Int, siteTimeZone:NSTimeZone) {
        self.oauth2Token = oauth2Token
        self.siteId = siteId
        self.siteTimeZone = siteTimeZone
        self.stringStatsUrl = "\(self.baseUrl)/sites/\(self.siteId)/stats"
    }
    
    public func fetchStatsSummary(success: (summary: StatsSummary, error: NSError?) -> ()) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.allZeros)
        manager.requestSerializer.setValue("Bearer \(self.oauth2Token)", forHTTPHeaderField: "Authorization")
        
        manager.GET("\(stringStatsUrl)/summary",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, JSON: AnyObject!) -> Void in
                println(JSON)
                let statsSummary = StatsSummary(views: 1, visitors: 1, likes: 1, reblogs: 1, comments: 1)
                success(summary: statsSummary, error: nil)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
            }
        )
        
    }
    
}