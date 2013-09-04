set :vaultage, false
set :vaultage_bin, "vaultage"
set :vaultage_extension, "gpg"
set :branch, "master"

after "symfony:composer:install" do
    if vaultage
        vaultage.decrypt
    end
end

namespace :vaultage do
    task :decrypt do
        randomstr  = `openssl rand -base64 10`.strip
        localfiles = []

        vaultage_files.each_with_index do |files, index|
            tmp = "/tmp/#{application}_parameters_#{randomstr}#{index}.yml.#{vaultage_extension}"
            top.download(latest_release+"/"+files[0], tmp)
            localfiles.push(tmp)
        end

        system "vaultage decrypt --write --files="+localfiles.join(',')

        vaultage_files.each_with_index do |files, index|
            top.upload("/tmp/#{application}_parameters_#{randomstr}#{index}.yml", latest_release+"/"+files[1])
        end
    end

    task :diff do
        randomstr  = `openssl rand -base64 10`.strip

        vaultage_files.each_with_index do |files, index|
            directory = File.dirname(files[0])

            if (directory.scan(/^vendor.*/).size != 0)
                if (!defined? vendor_dirs)
                    vendor_dirs = `find vendor -iname '.git' | sed -e 's/\.git//'`.strip.split("\n")
                end

                for vendor_dir in vendor_dirs
                    if (directory.index(vendor_dir) == 0)
                        root_directory = vendor_dir
                        break
                    end
                end

                if (!defined? root_directory)
                    raise 'Cannot fetch base directory of parameter #{files[0]}. May be file does not exists ? Or directory is not a git repository.'
                end

                from_vendor = true
            else
                root_directory = ''
                from_vendor = false
            end

            absolute_directory = Dir.getwd+"/"+root_directory

            if (from_vendor === false && `cd #{absolute_directory} && git remote | grep capistrano`.strip != 'capistrano')
                system "cd #{absolute_directory} && git remote add capistrano #{repository}"
            end

            remote = from_vendor ? "composer" : "capistrano"
            system "cd #{absolute_directory} && git fetch #{remote}"

            tmp1 = "/tmp/#{application}_parameters_1_#{randomstr}#{index}.yml.gpg"
            tmp2 = "/tmp/#{application}_parameters_2_#{randomstr}#{index}.yml"

            # fetch encrypted file from git
            system "cd #{absolute_directory} && git show #{remote}/#{branch}:#{files[0].gsub(root_directory, '')} > #{tmp1}"
            # download decrypted file on remote server
            top.download(latest_release+"/"+files[1], tmp2)

            capifony_pretty_print("Diff between local (versionned) #{files[0]} and remote #{files[1]}")

            system "vaultage diff --files=#{tmp1},#{tmp2}"
        end
    end
end
