set :vaultage, false
set :vaultage_bin, "vaultage"

after "symfony:composer:install" do
    if vaultage
        vaultage.decrypt
    end
end

namespace :vaultage do
    task :decrypt do
        filesToDecrypt = [];

        for files in vaultage_files
            files.push(`openssl rand -base64 10`.strip);
            tmpName = "/tmp/"+application+"_parameters_"+files[2]+".yml.gpg"
            top.download(latest_release+files[0], tmpName)
            filesToDecrypt.push(tmpName)
        end

        system "vaultage decrypt --write --files="+filesToDecrypt.join(',')

        for files in vaultage_files
            top.upload("/tmp/"+application+"_parameters_"+files[2]+".yml", latest_release+files[1])
        end
    end
end
