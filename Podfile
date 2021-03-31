install! 'cocoapods',
         :generate_multiple_pod_projects => true,
         :incremental_installation => true,
         :preserve_pod_file_structure => true

install! 'cocoapods', :disable_input_output_paths => true

use_frameworks!

target 'Juicer macOS' do
  platform :osx, '10.15'
  pod 'Easings'
  pod 'Satin'
end

target 'Juicer iOS' do
  platform :ios, '13.0'
  pod 'Easings'
  pod 'Satin'
end

target 'Juicer tvOS' do
  platform :tvos, '13.0'
  pod 'Easings'
  pod 'Satin'
end
