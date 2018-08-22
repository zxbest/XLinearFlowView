Pod::Spec.new do |s|
  s.name             = 'XLinearFlowView'
  s.version          = '1.0.0'
  s.summary          = 'For views, those have or not same width, displayed in linear flow mode.'
  
  s.description      = <<-DESC
views which have same width or not, can be displayed in this view. And drag&drop animation were enabled.
展示不等宽的元素，按流式布局排版，并提供拖拽动画
  DESC
  
  s.homepage         = 'https://github.com/zxbest/XLinearFlowView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'for' => 'wu.xinting@hotmail.com' }
  s.source           = { :git => 'https://github.com/zxbest/XLinearFlowView.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  
  s.source_files = 'XLinearFlowView/*.{h,m}'
  
  s.public_header_files = 'XLinearFlowView/*.h'
  s.frameworks = 'UIKit'
end
