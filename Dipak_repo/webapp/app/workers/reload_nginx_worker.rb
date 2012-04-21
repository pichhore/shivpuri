class ReloadNginxWorker
    @queue = :reload_nginx_worker
    def self.perform()
      system "sudo /etc/init.d/nginx reload "
    end 
end
