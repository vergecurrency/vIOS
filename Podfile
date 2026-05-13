# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'
target 'VergeiOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Tor', '~> 409'



  # Pods for VergeiOS

  target 'VergeiOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'VergeiOSUITests' do
    # Pods for testing
  end

end

target 'VergeSiri' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VergeSiri

end

target 'VergeSiriUI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VergeSiriUI

end

target 'VergeWatch Extension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VergeWatch Extension

end

post_install do |installer|
  # Xcode 26 can resolve `-framework "tor"` to the generated `Tor.framework`
  # while building the Tor pod itself. Link the vendored lowercase framework
  # binary directly so the pod does not try to link with itself.
  installer.pods_project.targets.each do |target|
    next unless target.name == 'Tor'

    target.build_configurations.each do |config|
      config.build_settings.delete('OTHER_LDFLAGS')

      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig.gsub!(
        /OTHER_LDFLAGS = .*/,
        'OTHER_LDFLAGS = $(inherited) -l"z" "$(PODS_XCFRAMEWORKS_BUILD_DIR)/Tor/CTor/tor.framework/tor"'
      )
      File.write(xcconfig_path, xcconfig)
    end
  end
end
