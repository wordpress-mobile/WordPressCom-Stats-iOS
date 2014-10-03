import Foundation

public class StatsServiceRemote {
    var oauth2Token: String
    var siteId: Int
    var siteTimeZone: NSTimeZone
    
    //- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone

    public init(oauth2Token:String, siteId:Int, siteTimeZone:NSTimeZone) {
        self.oauth2Token = oauth2Token
        self.siteId = siteId
        self.siteTimeZone = siteTimeZone
    }
    
    public func fetchStatsSummary() {
        request(Method.GET, "", parameters: nil, encoding: ParameterEncoding.URL)
        
//        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
//        manager.responseSerializer = AFJSONResponseSerializer()
//        manager.requestSerializer.setValue("Bearer \(self.oauth2Token)", forHTTPHeaderField: "Authorization")

    }
    
}