$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pathname'
require 'utility'
require 'trollop'

class Geeklets

  def initialize
    @geeklet_scripts = {}
    cwd = File.dirname(__FILE__)
    children = Pathname.new(cwd).children
    children.reject! { |child| !child.directory? }
    children.each do |child_dir|
      geeklet_name = child_dir.basename.to_s
      geeklet_file = geeklet_name.downcase
      begin
        require "#{geeklet_name}/#{geeklet_file}"
        @geeklet_scripts[geeklet_name] = eval("#{geeklet_name}.new")
      rescue
        puts "Problem loading #{geeklet_name} geeklet."
        next
      end
    end
  end

  def show_usage
    puts "Usage: geeklets <geeklet-script> [relevant-parameters-for-script]"
    puts 
  end
  
  def show_known_scripts
    puts "These are the currently known geeklet scripts:"
    puts
    @geeklet_scripts.keys.sort.each { |key| puts "\t#{key}" }
    puts
  end
  
  def run(params)
    if params.empty?
      show_usage
      show_known_scripts
    else
      geeklet = params.shift
      if @geeklet_scripts.include?(geeklet)
        @geeklet_scripts[geeklet].run(params) 
      else
        puts "I do not know how to run the #{geeklet} geeklet."
        show_known_scripts
      end
    end
  end

end