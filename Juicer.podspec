Pod::Spec.new do |spec|
  spec.name                   = "Juicer"
  spec.version                = "0.0.1"
  spec.summary                = "Juicer is a generic animation framework for macOS & iOS & tvOS written in Swift"
  spec.description            = <<-DESC
  Juicer is a generic animation framework for macOS & iOS & tvOS written in Swift... Juice it or lose it!
                   DESC
  spec.homepage               = "https://github.com/Hi-Rez/Juicer"
  spec.license                = { :type => "MIT", :file => "LICENSE" }
  spec.author                 = { "Reza Ali" => "reza@hi-rez.io" }
  spec.social_media_url       = "https://twitter.com/rezaali"
  spec.source                 = { :git => "https://github.com/Hi-Rez/Juicer.git", :tag => spec.version.to_s }

  spec.osx.deployment_target  = "10.10"
  spec.ios.deployment_target  = "4.0"
  spec.tvos.deployment_target = "9.0"

  spec.source_files           = "Source/*.h", "Source/**/*.{h,m,swift}"
  spec.module_name            = "Juicer"
  spec.swift_version          = "5.1"
  spec.dependency             'Easings'
end
