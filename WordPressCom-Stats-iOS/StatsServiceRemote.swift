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
    
    public func fetchStatsSummary() {
        request(Method.GET, "\(stringStatsUrl)/summary", parameters: nil, encoding: ParameterEncoding.URL)
        .response { (request, response, JSON, error) -> Void in
            println(request)
            println(JSON)
        }
        
//        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
//        manager.responseSerializer = AFJSONResponseSerializer()
//        manager.requestSerializer.setValue("Bearer \(self.oauth2Token)", forHTTPHeaderField: "Authorization")

    }
    
}