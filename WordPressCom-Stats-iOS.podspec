Pod::Spec.new do |s|
  s.name         = "WordPressCom-Stats-iOS"
  s.version      = "0.7.7"
  s.summary      = "Reusable component for displaying WordPress.com site stats in an iOS application."

  s.description  = <<-DESC
                   Reusable component for displaying WordPress.com site stats in an iOS application

                   * Requires an OAuth2 bearer token for WordPress.com generated currently by WordPress-Mobile/WordPress-iOS
                   DESC

  s.homepage     = "http://apps.wordpress.org"
  s.license      = "GPLv2"
  s.author             = { "Aaron Douglas" => "astralbodies@gmail.com" }
  # s.authors            = { "Aaron Douglas" => "astralbodies@gmail.com" }
  s.social_media_url   = "http://twitter.com/WordPressiOS"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/wordpress-mobile/WordPressCom-Stats-iOS.git", :tag => s.version.to_s }
  # s.source_files  = "WordPressCom-Stats-iOS", "WordPressCom-Stats-iOS/**/*.{h,m,swift}"
  # s.private_header_files = "WordPressCom-Stats-iOS/Private/*.h"
  s.exclude_files = "WordPressCom-Stats-iOS/Exclude"
  s.prefix_header_file = "WordPressCom-Stats-iOS/WordPressCom-Stats-iOS-Prefix.pch"

  s.requires_arc = true

  s.subspec 'UI' do |sp|
    sp.source_files = "WordPressCom-Stats-iOS/Common/*.{h,m,swift}", "WordPressCom-Stats-iOS/Private/*.{h,m,swift}", 'WordPressCom-Stats-iOS/UI/*.{h,m,swift}'
    sp.private_header_files = 'WordPressCom-Stats-iOS/Private/*.h'
    sp.dependency 'WordPressCom-Stats-iOS/Services'
    sp.resource_bundle = { 'WordPressCom-Stats-iOS' => ['WordPressCom-Stats-iOS/UI/*.storyboard', 'WordPressCom-Stats-iOS/UI/*.xib', 'WordPressCom-Stats-iOS/Resources/*.otf', 'WordPressCom-Stats-iOS/Resources/*.png'] }
  end
  
  s.subspec 'Services' do |sp|
    sp.source_files = "WordPressCom-Stats-iOS/Common/*.{h,m,swift}", "WordPressCom-Stats-iOS/Private/*.{h,m,swift}", 'WordPressCom-Stats-iOS/Services/*.{h,m,swift}'
    sp.private_header_files = 'WordPressCom-Stats-iOS/Private/*.h'
  end
  
  s.header_dir = 'WordPressComStatsiOS'
  s.module_name = 'WordPressComStatsiOS'
  s.dependency 'AFNetworking',	'~> 3.1.0'
  s.dependency 'CocoaLumberjack', '~> 2.2.0'
  s.dependency 'WordPress-iOS-Shared', '~> 0.5'
  s.dependency 'NSObject-SafeExpectations', '~> 0.0.2'
  s.dependency 'WordPressCom-Analytics-iOS', '~> 0.1.4'
end
