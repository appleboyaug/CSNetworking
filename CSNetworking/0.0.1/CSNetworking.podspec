Pod::Spec.new do |s|
s.name         = "CSNetworking"
s.version      = "0.0.1"
s.summary      = "网络请求模块"
s.homepage     = 'https://github.com/appleboyaug/CSNetworking.git'
s.license      = {
:type => 'YueKe',
:text => 'Shanghai Caishi Information Technology Co., Ltd.'
}
s.author       = 'Yuan'
s.platform     = :ios, "7.0"
s.source       = { :git => 'https://github.com/appleboyaug/CSNetworking.git' }
s.source_files = "CSTools/CSNetworking/*.{h,m}"
s.requires_arc = true
s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
s.dependency 'AFNetworking'
s.framework = 'Security'
end