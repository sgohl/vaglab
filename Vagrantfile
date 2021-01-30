$provision = <<END
sed -i "/^127.0.0.1.*$HOSTNAME/d" /etc/hosts
for i in 1 2 3; do echo "11.11.11.1$i centos$i" >> /etc/hosts ; done

sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg

# unix task-spooler (ts)
cd /usr/src ; curl -s http://vicerveza.homeunix.net/~viric/soft/ts/ts-1.0.tar.gz | tar zxvf - && cd ts* && make && make install ; mv /usr/local/bin/ts /usr/bin/

source /vagrant/.env
END

Vagrant.configure(2) do |config|

  config.vm.provider "virtualbox" do |vb|
    vb.customize ['storagectl', :id, '--name', 'sata', '--add', 'sata', '--controller', 'IntelAHCI']
  end

  (1..3).each do |i|
    config.vm.define "centos#{i}" do |pcs|
       pcs.vm.box = "boxomatic/centos-8-stream"
       pcs.vm.hostname = "centos#{i}"
       pcs.vm.network "private_network", ip: "11.11.11.1#{i}"

       pcs.vm.provider :virtualbox do |c|
         c.customize ["modifyvm", :id, "--memory", "1024"]
         c.customize ["modifyvm", :id, "--cpus", "1"]
         c.customize ["modifyvm", :id, "--name", "centos#{i}"]

         disk = "centos#{i}.vdi"
         unless File.exist?(disk)
           c.customize ['createhd', '--filename', "centos#{i}.vdi", '--variant', 'Standard', '--size', 6000]
         end

         c.customize ['storageattach', :id, '--storagectl', 'sata', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "centos#{i}.vdi"]
       end
    end
  end       

  config.vm.provision "shell", run: "once", inline: $provision

end
