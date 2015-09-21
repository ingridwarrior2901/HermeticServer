Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "HermeticServer"
s.summary = "HermeticServer lets a user capture request."
s.requires_arc = true

s.version = "0.1.0"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "Jaime Leon" => "jaime.leon@globant.com" }
s.homepage = "https://github.com/JaimeYesidLeonParada/HermeticServer"

s.source = { :git => "https://github.com/JaimeYesidLeonParada/HermeticServer.git", :tag => "#{s.version}"}

s.framework = "UIKit"
s.dependency 'OHHTTPStubs'
s.source_files = "HermeticServer/HermeticServerManager/OHHTTPManager.swift"
s.resources = "HermeticServer/HermeticServerManager/**/*.{png,jpeg,jpg,storyboard,xib,plist}"

end