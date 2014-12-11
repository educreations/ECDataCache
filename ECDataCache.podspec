Pod::Spec.new do |s|
  s.name = 'ECDataCache'
  s.version = '0.0.2'
  s.summary = 'A generic NSData cache for storing data to disk, which is backed by NSCache for in-memory data.'
  s.homepage = 'https://github.com/educreations/ECDataCache'
  s.license = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.author = 'Chris Streeter', 'chris@educreations.com'
  s.source = {
    :git => 'https://github.com/educreations/ECDataCache.git',
    :tag => "#{s.version}"
  }
  s.platform = :ios, '5.0'
  s.source_files = 'ECDataCache.{h,m}'
  s.frameworks = 'UIKit'
  s.requires_arc = false
end
