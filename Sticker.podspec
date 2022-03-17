
Pod::Spec.new do |spec|
  spec.static_framework = true
  spec.name         = "Sticker"
  spec.version      = "1.0.8"
  spec.summary      = "Sticker Module"

  spec.description  = <<-DESC
  Sticker integration
                   DESC
 spec.homepage     = "https://github.com/huseyinkapi/Sticker"
 spec.author             = "Huseyin"
 spec.ios.deployment_target = "12.0"
 spec.source       = { :git => "https://github.com/huseyinkapi/Sticker.git", :tag => "#{spec.version}" }
 spec.exclude_files = "Exclude"

 spec.swift_version = '5'

 spec.source_files  = "Sticker/**/*.{h,m,swift}"
 spec.resources = "Sticker/**/*.{png,storyboard,xcassets,xib,json,bundle}"
 spec.public_header_files = 'Sticker/**/*.h'

 
 # public dependencies
 spec.dependency "Kingfisher"
 spec.dependency "FlexColorPicker"
end
