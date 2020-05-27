Pod::Spec.new do |s|
    
    s.name                       = 'JhtBannerScrollView'
    s.version                    = '1.0.6'
    s.summary                    = 'banner/广告页/循环滚动广告图片/无限循环自动滚动卡片'
    s.homepage                   = 'https://github.com/jinht/BannerScrollView'
    s.license                    = { :type => 'MIT', :file => 'LICENSE' }
    s.author                     = { 'Jinht' => 'jinjob@icloud.com' }
    s.social_media_url           = 'https://blog.csdn.net/Anticipate91'
    s.platform                   = :ios
    s.ios.deployment_target      = '8.0'
    s.source                     = { :git => 'https://github.com/jinht/BannerScrollView.git', :tag => s.version }
    s.ios.vendored_frameworks    = 'JhtBannerScrollView_SDK/JhtBannerScrollView.framework'
    s.frameworks                 = 'UIKit'
    s.dependency		 'SDWebImage'

end
