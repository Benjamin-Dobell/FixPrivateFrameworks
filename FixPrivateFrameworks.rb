#!/usr/bin/env ruby

if __FILE__ == $0
	app_path = ARGV[0]
	bin_name = ARGV[1]
	
	bin_path = "#{app_path}/Contents/MacOS/#{bin_name}"
	bin_dependencies = `otool -L #{bin_path} | grep ".framework"`.lines.map { |line|
		line.split(' ').first
	}.reject { |dependency|
		dependency.start_with? "/"
	}
	
	framework_dir = "#{app_path}/Contents/Frameworks"
	
	Dir.entries(framework_dir).each { |framework|
		if framework.include? ".framework"
			framework_bin_name = framework.split('.').first
			framework_bin_path = "#{framework_dir}/#{framework}/#{framework_bin_name}"
		
			framework_id = bin_dependencies.select { |bin_dependency|
				bin_dependency.start_with? framework
			}.first
		
			`install_name_tool -id @executable_path/../Frameworks/#{framework_id} #{framework_bin_path}`
		
			framework_dependencies = `otool -L #{framework_bin_path}`.lines.map { |line|
				line.split(' ').first
			}.reject { |dependency|
				dependency.start_with? "/"
			}
		
			framework_dependencies.each { |dependency|
				`install_name_tool -change #{dependency} @executable_path/../Frameworks/#{dependency} #{framework_bin_path}`
			}
		end
	}
	
	bin_dependencies.each { |dependency|
		`install_name_tool -change #{dependency} @executable_path/../Frameworks/#{dependency} #{bin_path}`
	}
end
