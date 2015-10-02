Pod::Spec.new do |s|
  s.name         = 'sReto'
  s.version      = '1.2.0'
  s.summary      = 'P2P Framework for realtime collaboration in Swift'
  s.homepage     = 'https://github.com/ls1intum/sReto'
  s.license      = 'MIT'
  s.author             = { 'Chair for Applied Software Engineering' => 'ios@in.tum.de' }
  s.social_media_url   = 'https://twitter.com/ls1intum'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source       = { :git => 'https://github.com/ls1intum/sReto.git', :tag => s.version }

  s.ios.frameworks     = 'CFNetwork', 'Security'
  s.osx.frameworks     = 'CoreServices', 'Security'
  s.libraries          = "icucore"
  
  
  
  s.subspec 'no-arc' do |n|
    n.source_files = 'Source/sReto/DNSSD/*'
    n.requires_arc = false
  end

  s.subspec 'arc' do |a|
  	a.source_files  = 'Source/**/*.{h,c,m,swift}'
  	a.exclude_files = 'Source/sReto/DNSSD/*', 'Source/sRetoTests/*'
  	a.requires_arc = true
  	a.dependency 'sReto/no-arc'
  end

end
