set :apc_keys_clear, []

before "deploy:create_symlink" do
    if (apc_keys_clear.kind_of?(Array) == true && apc_keys_clear.count > 0)
        case apc_clear_security
        when "none"
            options = nil;
        when "http_basic"
            options = "--user #{apc_clear_security_user}:#{apc_clear_security_pass}"
        else
            raise "apc_clear_security must be “none“ or “http_basic“"
        end

        capifony_pretty_print("Clearing APC cache.")

        command = "curl #{options} \"#{apc_clear_host}?keys=#{apc_keys_clear.join(',')}\" -o /dev/null"
        result  = system "#{command}"
        if (false == result)
            raise "Error when clearing the cache with command: '#{command}'"
        end
    end
end
