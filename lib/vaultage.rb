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
        tempfiles    = []
        cryptedpaths = []

        vaultage_files.each_with_index do |files, index|
            tempfile = Tempfile.new(application)

            top.download(latest_release+"/"+files[0], tempfile.path+"."+vaultage_extension)

            tempfiles.push(tempfile);
            cryptedpaths.push(tempfile.path+"."+vaultage_extension);
        end

        system "vaultage decrypt --write --files="+cryptedpaths.join(',')

        vaultage_files.each_with_index do |files, index|
            top.upload(tempfiles[index].path, latest_release+"/"+files[1])
            tempfiles[index].unlink
        end
    end

    task :diff do
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

            tmp1 = Tempfile.new(application)
            tmp2 = Tempfile.new(application)

            # fetch encrypted file from git
            system "cd #{absolute_directory} && git show #{remote}/#{branch}:#{files[0].gsub(root_directory, '')} > #{tmp1.path}.gpg"
            # download decrypted file on remote server
            top.download(latest_release+"/"+files[1], tmp2.path)

            capifony_pretty_print("Diff between local (versionned) #{files[0]} and remote #{files[1]}")

            system "vaultage diff --files=#{tmp1.path}.gpg,#{tmp2.path}"
        end
    end
end
