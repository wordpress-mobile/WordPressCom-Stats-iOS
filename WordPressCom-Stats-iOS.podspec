Pod::Spec.new do |s|
  s.name         = "WordPressCom-Stats-iOS"
  s.version      = "0.4.10"
  s.summary      = "Reusable component for displaying WordPress.com site stats in an iOS application."

  s.description  = <<-DESC
                   Reusable component for displaying WordPress.com site stats in an iOS application

                   * Requires an OAuth2 Token for WordPress.com generated currently by WordPress-Mobile/WordPress-iOS
                   DESC

  s.homepage     = "http://apps.wordpress.org"
  s.license      = "GPLv2"
  s.author             = { "Aaron Douglas" => "astralbodies@gmail.com" }
  # s.authors            = { "Aaron Douglas" => "astralbodies@gmail.com" }
  s.social_media_url   = "http://twitter.com/WordPressiOS"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/wordpress-mobile/WordPressCom-Stats-iOS.git", :tag => s.version.to_s }
  # s.source_files  = "WordPressCom-Stats-iOS", "WordPressCom-Stats-iOS/**/*.{h,m,swift}"
  s.exclude_files = "WordPressCom-Stats-iOS/Exclude"
  s.prefix_header_file = "WordPressCom-Stats-iOS/WordPressCom-Stats-iOS-Prefix.pch"

  s.requires_arc = true

  s.subspec 'UI' do |sp|
    sp.source_files = 'WordPressCom-Stats-iOS/UI'
    sp.dependency 'WordPressCom-Stats-iOS/Services'
    sp.resource_bundle = { 'WordPressCom-Stats-iOS' => ['WordPressCom-Stats-iOS/**/*.storyboard', 'WordPressCom-Stats-iOS/**/*.xib', 'WordPressCom-Stats-iOS/**/*.otf', 'WordPressCom-Stats-iOS/**/*.png'] }
  end
  
  s.subspec 'Services' do |sp|
    sp.source_files = 'WordPressCom-Stats-iOS/Services'
  end
  
  s.dependency 'AFNetworking',	'~> 2.6.0'
  s.dependency 'CocoaLumberjack', '2.0.0'
  s.dependency 'WordPress-iOS-Shared', '~> 0.4'
  s.dependency 'NSObject-SafeExpectations', '0.0.2'
  s.dependency 'WordPressCom-Analytics-iOS', '~>0.0.37'
end
