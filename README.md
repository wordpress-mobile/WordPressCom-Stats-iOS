**🚨 Deprecation Notice: 🚨** As of 8-May-2017 this project has been deprecated and will no longer be updated. The code is here for historical purposes only. The WordPressCom-Stats-iOS project [was merged into the main WordPress-iOS project](https://github.com/wordpress-mobile/WordPress-iOS/issues/7120) as a dynamic framework. Please report any stats-related issues to the main [WordPress-iOS repo](https://github.com/wordpress-mobile/WordPress-iOS/issues).

![WordPress Logo](http://s.w.org/about/images/logos/wordpress-logo-hoz-rgb.png)

# WordPressCom-Stats-iOS

![WordPressCom-Stats-iOS Screenshot](https://cldup.com/CwXYN563C2.png)

## Introduction

WordPressCom-Stats-iOS is a reusable component used in the [WordPress iOS app](https://github.com/wordpress-mobile/WordPress-iOS) to show stats for sites hosted on WordPress.com.  You can use the UIViewController subclass inside of your own applications or use one of the services to pull stats for your own use.

## How to get started
You can install the stats component in your app via [CocoaPods](http://cocoapods.org):

```ruby
platform :ios, '10.0'
pod 'WordPressCom-Stats-iOS'
```

Or, you can just try out the demo by using the CocoaPods try command:

```ruby
pod try WordPressCom-Stats-iOS
```

## Requirements

WordPressCom-Stats-iOS requires iOS 7.0 or higher and ARC. It depends on the following Apple frameworks:

* Foundation.framework
* UIKit.framework
* CoreGraphics.framework

and the following CocoaPods:

* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)
* [NSObject+SafeExpectations](https://github.com/wordpress-mobile/NSObject-SafeExpectations)
* [WordPress-iOS-Shared](https://github.com/wordpress-mobile/WordPress-iOS-Shared)
* [WordPressCom-Analytics-iOS](https://github.com/wordpress-mobile/WordPressCom-Analytics-iOS)

See the [podspec](https://github.com/wordpress-mobile/WordPressCom-Stats-iOS/blob/develop/WordPressCom-Stats-iOS.podspec) for more details.

## Usage

There are three things that you need to do in order to use WordPressCom-Stats-iOS in your app.

1. Create a UIViewController subclass that extends ```WPStatsViewController```.  (Optionally you may choose to use composition and have your UIViewController contain an instance of WPStatsViewController and add as a subview.  Take a look at the demo project for an example.)

        #import <UIKit/UIKit.h>
        #import <WordPressCom-Stats-iOS/WPStatsViewController.h>

        @interface WPViewController : WPStatsViewController <WPStatsViewControllerDelegate>

        @end

2. Obtain an OAuth2 token from WordPress.com.  Currently the authentication mechanism to WordPress.com is not part of a reusable library.  You will need to obtain this manually by following (these directions)[https://developer.wordpress.com/docs/oauth2/].  The easiest way to snag the OAuth2 token is by setting a breakpoint in the WordPress-iOS application after generating a token.

3. Obtain the site/blog ID for the site you wish to view stats for.

4. Pass the site ID and OAuth2 token to either the init method or set as parameters before displaying the view from the controller.

For more details, you can review the [StatsDemo](https://github.com/wordpress-mobile/WordPressCom-Stats-iOS/tree/develop/StatsDemo) project included in this repo.

## Other Resources

#### Developer blog & Handbook

Blog: http://make.wordpress.org/mobile

Handbook: http://make.wordpress.org/mobile/handbook/

#### Style guide

https://github.com/wordpress-mobile/WordPress-iOS/wiki/WordPress-for-iOS-Style-Guide

#### To report an issue (for the stats component only)

https://github.com/wordpress-mobile/WordPressCom-Stats-iOS/issues?state=open

#### Source Code

GitHub: https://github.com/wordpress-mobile/WordPressCom-Stats-iOS/

#### How to Contribute

http://make.wordpress.org/mobile/handbook/pathways/ios/how-to-contribute/

## Future Enhancements

* Replace networking stack with WordPressComApi shared pod

## License

WordPressCom-Stats-iOS is available under the MIT license. See the [LICENSE](https://raw.githubusercontent.com/wordpress-mobile/WordPressCom-Stats-iOS/develop/LICENSE) file for more info.
