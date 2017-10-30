target 'Stadiometer' do
  use_frameworks!

  pod 'AcknowList'
  pod 'AdFooter', git: 'https://github.com/tnantoka/AdFooter.git'
  pod 'PKHUD', git: 'https://github.com/pkluz/PKHUD.git'

  target 'StadiometerTests' do
    inherit! :search_paths
  end
end

plugin 'cocoapods-keys', project: 'Stadiometer', keys: %w[
  AdMobApplicationID
  AdMobBannerUnitID
]

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r 'Pods/Target Support Files/Pods-Stadiometer/Pods-Stadiometer-acknowledgements.plist', 'Stadiometer/Pods-acknowledgements.plist', remove_destination: true
end
