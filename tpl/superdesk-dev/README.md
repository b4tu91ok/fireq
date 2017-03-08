###[Prepare LXC](../../docs/lxc.md)

## Install a {{name}} in LXC container
```sh
lxc={{scope}} path=~/{{name}}
# create clean directory
mkdir $path && cd $path
# it mounts next directories inside the container
# - current directory $(pwd) to /opt/superdesk
# - /var/cache/fireq for pip, npm, dpkg caches and logs
(echo name=$lxc mount_src=$(pwd); curl -s https://raw.githubusercontent.com/superdesk/fireq/master/files/{{name}}-dev/lxc-init) | sudo bash
(echo host=$lxc; curl -s https://raw.githubusercontent.com/superdesk/fireq/master/files/{{name}}-dev/install) | ssh root@$lxc

# open http://$lxc in browser to access superdesk

# current directory is mounted inside the container,
# some files could be created by root during installation, so
sudo chown -R <your_user> .
ls -l ./client-core # superdesk-client-core
ls -l ./server-core # superdesk-core
ls -l /var/cache/fireq/log/sd/ # logs
```

### Inside the container
```sh
ssh root@{{scope}}
ll /etc/supervisor/conf.d/ # supervisor configs
supervisorctl status
supervisorctl status client # it's "grunt server"
supervisorctl restart all
supervisorctl restart rest wamp capi

cat /etc/{{name}}.sh # config
env | sort # print all env variables
ll /opt/superdesk/env # virtualenv
source /opt/{{name}}/bin/activate # active by default, loads env variables

ll /etc/nginx/conf.d/ # nginx configs
ll /var/log/superdesk # logs
```

## We can create separate LXC container for tests
```sh
lxc={{scope}}test path=~/{{name}}
(echo name=$lxc mount_src=$path; curl -s https://raw.githubusercontent.com/superdesk/fireq/master/files/{{name}}-dev/lxc-init) | sudo bash
(echo host=$lxc testing=1; curl -s https://raw.githubusercontent.com/superdesk/fireq/master/files/{{name}}-dev/install) | ssh root@$lxc

# and run tests like this
cd ~/superdesk/client-core
protractor protractor.conf.js --baseUrl http://{{scope}}test --params.baseBackendUrl http://{{scope}}test/api
```

## Using just for services
```sh
ssh root@{{scope}}
systemctl disable supervisor nginx
systemctl stop supervisor nginx

# and use "sd" as host for mongo, elasticsearch, redis
```