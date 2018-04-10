Pod::Spec.new do |s|
  s.name             = "Inspection"
  s.version          = "1.0.0"
  s.summary          = "Debug accessory tool for iOS."
  s.homepage         = "https://meniny.cn/"
  # s.screenshots      = "https://github.com/Meniny/Inspection/"
  s.license          = 'MIT'
  s.author           = { "Elias Abel" => "admin@meniny.cn" }
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.source           = { :git => "https://github.com/Meniny/Inspection.git", :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn/'
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.source_files     = 'Inspection/**/*.{swift,h,m}'
end
