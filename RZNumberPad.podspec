Pod::Spec.new do |s|
  s.name             = "RZNumberPad"
  s.version          = "0.1.0"
  s.summary          = "Never write a custom number pad from scratch again"
  s.description      = <<-DESC
                       Create customized number pads with ease, and link output directly to UITextFields.
                       DESC
  s.homepage         = "https://github.com/Raizlabs/RZNumberPad"
  s.license          = 'MIT'
  s.author           = { "Rob Visentin" => "rob.visentin@raizlabs.com" }
  s.source           = { :git => "https://github.com/Raizlabs/RZNumberPad.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.frameworks = 'UIKit'

  s.source_files = 'RZNumberPad'
end
