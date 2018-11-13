Pod::Spec.new do |s|

  s.name         = "StitchCore"
  s.version      = "0.1"
  s.summary      = "Stitch core enables communications across multiple channels including in-app messaging and in-app voice over IP"

  s.homepage     = "https://github.com/Vonage/stitch_iOS.git"
  s.license      = { :type => 'New BSD License', :file => 'LICENSE' }
  s.author       = { "Vonage" => "vonage@vonage.com"}

  s.platform     =  :ios, "10.0"

  s.source       = { :git => "git@github.com:Vonage/stitch_iOS.git", :tag => "develop" }

  s.requires_arc = true
  s.source_files = "StitchCore/*.{h,m,mm}", "StitchCore/**/*.{h,m,mm}"

  s.frameworks = "CoreData", "Foundation", "UIKit", "MediaPlayer", "AudioToolbox", "AVFoundation", "CFNetwork", "CoreAudio", "CoreFoundation", "CoreTelephony", "SystemConfiguration", "CoreGraphics", "OpenGLES", "CoreVideo", "CoreMedia", "QuartzCore"

  s.dependency 'MiniRTC_Release', '0.01.78'

end
