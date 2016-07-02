#
#  Be sure to run `pod spec lint ZVDatabase.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ZVDatabase"
  s.version      = "0.0.1"
  s.summary      = "a simple swift database"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
    a simple swift database - -.
                   DESC
  s.homepage     = "https://github.com/zevwings/ZVDatabase"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "zevwings" => "zev.wings@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/zevwings/ZVDatabase.git", :commit => "0a0fe668fe76bcc944eb26b07b0f47180c2f8af4" }
  s.source_files  = "ZVDatabase/*.h", "ZVDatabase/*.swift"
  s.library   = "sqlite3"
  s.requires_arc = true

end
