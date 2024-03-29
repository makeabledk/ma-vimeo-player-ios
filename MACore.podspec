# If you need help with the podspec file check the cocoapods guide 
# about podspec files here: https://guides.cocoapods.org/syntax/podspec.html

Pod::Spec.new do |spec|

# Platform settings
spec.platform = :ios
spec.ios.deployment_target = "11.0"

# Pod settings:
spec.name = "MAVimeoPlayer"
spec.version = "0.0.14"
spec.summary = "A framework helping to play vimeo videos in iOS apps"
spec.author = { "Christian Petersen" => "christian@makeable.dk" }
spec.source = { :git => "https://github.com/makeabledk/ma-vimeo-player-ios.git", :tag => "#{spec.version}" }
spec.homepage = "https://www.makeable.dk"
spec.requires_arc = true
spec.license = { :type => "MIT", :file => "LICENSE.txt" }
spec.static_framework = true

spec.source_files = "POC_NativeVideoPlayer/MAVimeoPlayer/*.swift"
spec.ios.resource_bundle = { 'MAVimeoPlayer' => 'POC_NativeVideoPlayer/MAVimeoPlayer/*.{xcassets,xib,storyboard}' }

spec.dependency "PlayerKit"
spec.dependency "SnapKit", "~> 5.0.0"
spec.dependency "VimeoNetworking"
end
