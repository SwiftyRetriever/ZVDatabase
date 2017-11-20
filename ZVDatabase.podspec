#
#  Be sure to run `pod spec lint ZVDatabase.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ZVDatabase"
  s.version      = "0.0.3"
  s.summary      = "a simple swift database"
  s.description  = <<-DESC
  					a simple swift database.
                   DESC
  s.homepage     = "https://github.com/zevwings/ZVDatabase"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "zevwings" => "zev.wings@gmail.com" }
  # s.social_media_url   = "http://twitter.com/zevwings"
  s.platform     = :ios, "8.2"
  s.source       = { :git => "https://github.com/zevwings/ZVDatabase.git", :tag => "#{s.version}" }
  s.source_files  = "ZVDatabase", "ZVDatabase/**/*.{c,h,m,swift}"
  s.exclude_files = "ZVDatabase/**/*.modulemap"

  # s.public_header_files = "Classes/**/*.h"

  s.libraries = "sqlite3"
  s.requires_arc = true
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libsqlite3" }

end
