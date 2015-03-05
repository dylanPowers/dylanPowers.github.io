#!/bin/sh

build_tarball=build/web.tar
server_addr=home.dylankpowers.com
ssh_port=48924

echo "Publishing to IPNS"

tar -cf $build_tarball -C build web

temp_dir=/tmp/dkp-build.$RANDOM
ssh -p $ssh_port $server_addr "mkdir --parents $temp_dir"
scp -P $ssh_port $build_tarball $server_addr:$temp_dir/web.tar

printf "\nAdding files to IPFS...this may take awhile. Go take a snack break\n"
ssh -p $ssh_port $server_addr \
  "tar -xf web.tar -C $temp_dir && \
   ipfs add --recursive --quiet $temp_dir/web > $temp_dir/hashes && \
   tail -n 1 $temp_dir/hashes | ipfs name publish"

if [ $? -ne 0 ]; then
  echo "IPFS publish failed"
else
  echo "IPFS publish succeeded!"
fi