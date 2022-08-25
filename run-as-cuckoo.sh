#!/bin/sh

printf "\n>>> Creating virtualenv...\n\n"
virtualenv ~/cuckoo
. ~/cuckoo/bin/activate

printf "\n>>> Installing python packages\n\n"
pip install --no-cache-dir setuptools \
    cryptography==2.9.2 \
    pyrsistent==0.16.1 \
    m2crypto==0.37.1 \
    psycopg2 \
    bottle

printf "\n>>> Installing cuckoo & vmcloak...\n\n"
pip install --no-cache-dir cuckoo vmcloak
pip uninstall -y werkzeug
pip install --no-cache-dir werkzeug==0.16.1

printf "\n>>> Creating vboxnet0 interface...\n\n"
vmcloak-vboxnet0

printf "\n>>> Creating Windows base image...\n\n"
vmcloak init --verbose --win7x64 win7x64Base --cpus 2 --ramsize 2048

printf "\n>>> Creating cuckoo image from base file...\n\n"
vmcloak clone win7x64Base win7x64cuckoo

printf "\n>>> Installing packages in cuckoo image...\n\n"
vmcloak install win7x64cuckoo adobepdf pillow dotnet java flash vcredist vcredist.version=2015u3 wallpaper win7x64cuckoo ie11

printf "\n>>> Creating snapshots...\n\n"
vmcloak snapshot --count 4 win7x64cuckoo cuckoo 192.168.56.101

printf "\n>>> Initializing cuckoo...\n\n"
cuckoo init

printf "\n>>> Settings configurations...\n\n"
mv ~/.cuckoo/conf/ ~/.cuckoo/conf.old
cp -R ./conf ~/.cuckoo/conf
