Pod::Spec.new do |s|
  s.name         = 'sReto'
  s.version      = '1.1.0'
  s.summary      = 'P2P Framework for realtime collaboration in Swift'
  s.homepage     = 'https://github.com/ls1intum/sReto'
  s.license      = 'MIT'
  s.author             = { 'Chair for Applied Software Engineering' => 'ios@in.tum.de' }
  s.social_media_url   = 'https://twitter.com/ls1intum'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'

  s.source       = { :git => 'https://github.com/ls1intum/sReto.git', :tag => s.version }

  s.source_files  = 'Source', 'Source/**/*.swift'

  s.requires_arc = true
end
