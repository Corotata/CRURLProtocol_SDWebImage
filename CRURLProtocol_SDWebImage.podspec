#
#  Be sure to run `pod spec lint BLAPIManagers.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CRURLProtocol_SDWebImage"
  s.version      = "1.0.0"
  s.summary      = "CRURLProtocol_SDWebImage."

  s.description  = <<-DESC
                    this is CRURLProtocol_SDWebImage
                   DESC

  s.homepage     = "https://github.com/Corotata/CRURLProtocol_SDWebImage"

  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "Corotata" => "corotata@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Corotata/CRURLProtocol_SDWebImage.git", :tag => s.version }
  s.source_files  = "CRURLProtocol_SDWebImage/Classes/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "SDWebImage"

end
