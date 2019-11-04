# If you need help with the podspec file check the cocoapods guide 
# about podspec files here: https://guides.cocoapods.org/syntax/podspec.html

Pod::Spec.new do |spec|

# Platform settings
spec.platform = :ios
spec.ios.deployment_target = "11.0"

# Pod settings:
spec.name = "MACore"
spec.version = "0.1.7"
spec.summary = "A core framework making it easier working with styling and firebase."
spec.author = { "Martin Lindhof Simonsen" => "martin@makeable.dk" }
spec.source = { :git => "https://github.com/makeabledk/ma-core-ios.git", :tag => "#{spec.version}" }
spec.homepage = "https://www.makeable.dk"
spec.requires_arc = true
spec.license = { :type => "MIT", :file => "LICENSE.txt" }
spec.static_framework = true

# Subspecs:
	spec.subspec 'UI' do |uisubspec|
		uisubspec.source_files = "MACore/Source/UI/*.swift"

		uisubspec.subspec 'Styles' do |stylessubspec|
			stylessubspec.source_files = "MACore/Source/UI/Styles/*.swift"
		end
	end

	spec.subspec 'Media' do |mediasubspec|
		mediasubspec.dependency "MACore/UI"
		mediasubspec.dependency "SDWebImage"
		mediasubspec.source_files = "MACore/Source/Media/*.swift"
	end

	spec.subspec 'Database' do |databasesubspec|
		databasesubspec.dependency "CodableFirebase"
		databasesubspec.dependency "Firebase/Core"
		databasesubspec.dependency "Firebase/Firestore"
    databasesubspec.source_files = "MACore/Source/Database/*.swift"
	end
end
