Pod::Spec.new do |s|

  s.name         = "NexmoStitchObjC"
  s.version      = "0.0.1"
  
  s.summary      = "Stitch enables communications across multiple channels including in-app messaging and in-app voice over IP"

  s.homepage     = "https://github.com/Vonage/Conversation_SDK_ObjectiveC"
  s.license      = { :type => 'New BSD License', :file => 'LICENSE' }
  s.author       = { "Vonage" => "vonage@vonage.com"}


  s.ios.deployment_target = "10.0"

  s.source       = { :git => "git@github.com:Vonage/Conversation_SDK_ObjectiveC.git", :tag => "develop" }

  s.requires_arc = true
  s.source_files  = "NexmoConversationObjC/*.{h,m,mm}", "NexmoConversationObjC/**/*.{h,m,mm}"

# TODO:
  s.frameworks = "Foundation", "AudioToolbox", "AVFoundation", "CFNetwork", "CoreAudio", "CoreFoundation", "CoreTelephony"

# TODO:
  s.dependency 'VPSocketIO'

end
