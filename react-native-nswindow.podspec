require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-nswindow"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.license      = package["license"]
  s.authors      = { "Jim Lake" => "jim@blueskylabs.com" }
  s.homepage     = "https://github.com/jim-lake/react-native-nswindow"
  s.source       = { :git => "https://github.com/jim-lake/react-native-nswindow.git", :tag => s.version }

  s.osx.deployment_target = "14.0"
  s.source_files = "macos/**/*.{h,mm}"

  install_modules_dependencies(s)
end
