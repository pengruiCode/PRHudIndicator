

Pod::Spec.new do |s|

  s.name         = "PRHudIndicator"
  s.version      = "0.0.2"
  s.summary  	 = '多动能指示器'
  s.homepage     = "https://github.com/pengruiCode/PRHudIndicator.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = {'pengrui' => 'pengruiCode@163.com'}
  s.source       = { :git => 'https://github.com/pengruiCode/PRHudIndicator.git' }
  s.platform 	 = :ios, "8.0"
  s.source_files  = "PRHudIndicator/**/*.{h,m}"
  s.requires_arc = true
  s.description  = <<-DESC
			多动能指示器
                   DESC

 end
