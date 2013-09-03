require 'capistrano'
require 'capistrano/maintenance'
require 'colored'
require 'fileutils'
require 'inifile'
require 'yaml'
require 'zlib'
require 'ruby-progressbar'

module RezzzaCapistranoTools
    def self.load_into(configuration)
        configuration.load do

            load_paths.push File.expand_path('../', __FILE__)
            load 'vaultage'
        end
    end
end

if Capistrano::Configuration.instance
  RezzzaCapistranoTools.load_into(Capistrano::Configuration.instance)
end
