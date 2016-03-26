#
# Be sure to run `pod lib lint Oatmeal.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |s|
  s.name             = "Oatmeal"
  s.version          = "0.3.1"
  s.summary          = "Oatmeal is a refreshing Swift Framework to make bootstrapping your apps much easier."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "Oatmeal is a refreshing Swift Framework to make bootstrapping your apps much easier. Mmmkay?"

s.homepage            = "http://getoatmeal.com"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "mikenolimits" => "empathynyc@gmail.com" }
  s.source           = { :git => "https://github.com/OatmealCode/Oatmeal.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mikenolimits'

s.ios.platform = :ios, "9.0"
s.osx.platform = :osx, "10.10"
s.tvos.platform = :tvos, "9.0"

s.ios.deployment_target = '8.0'
s.osx.deployment_target = '10.9'
s.tvos.deployment_target = '9.0'

  s.source_files = 'Pod/Classes/**/*.swift'
#s.resource_bundles = {
#  'Oatmeal' => ['Pod/Assets/*.png']
# }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Alamofire'
   s.dependency 'AlamofireImage'
   s.dependency 'SwiftyJSON'
   s.dependency 'Carlos'
end
