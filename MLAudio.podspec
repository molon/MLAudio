Pod::Spec.new do |s|
s.name         = "MLAudio"
s.version      = "1.0.0"
s.summary      = "MLAudio"
s.homepage	   = "https://github.com/molon/MLAudio"
s.source 	   = {
:git => "https://github.com/molon/MLAudio.git",
:tag => "#{s.version}"
}

s.license      = { :type => 'MIT'}
s.author       = { "molon" => "dudl@qq.com" }

s.platform     = :ios, '7.0'
s.public_header_files = 'Classes/**/*.h'

s.source_files  = 'Classes/**/*.{h,m}'
s.vendored_frameworks = 'Classes/mp3_en_de/lame.framework'
s.vendored_libraries = 'Classes/amr_en_de/lib/*.{a}'
s.resource = "Classes/**/*.bundle"
s.frameworks = 'AVFoundation'
s.requires_arc  = true

s.dependency 'AFNetworking', '= 2.5.4'

s.prefix_header_contents = '
#ifdef DEBUG

#define DLOG(format, ...)                   \
NSLog(@"\n%s:%d\n%@",               \
__PRETTY_FUNCTION__, __LINE__,      \
[NSString stringWithFormat:format, ## __VA_ARGS__])

#else

#define DLOG(format, ...)

#endif'

end