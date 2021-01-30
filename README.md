# vagrant testlab (centos 8 stream)

```
vagrant up

vagrant ssh centos1
vagrant ssh centos2
vagrant ssh centos3
```

This repo will be accessible within (and synced across all) vagrant machines at
`/vagrant` so you can use the scripts in `parts/` 

make sure to `sudo -i` to become root when needed.

Enable parts scripts in `.env` for automated installation (see top of Vagrantfile)
