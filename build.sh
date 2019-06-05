#!/bin/sh
name=geogebra

rm ${name}-*.tar.xz
rm -rf obs

pushd ${name}-SNAPSHOT || exit
	git_hash_old=$(git log -1 --pretty=%h)
	git pull
	git_hash=$(git log -1 --pretty=%h)
	#[ "$git_hash" = "$git_hash_old" ] && exit
	git_stamp=$(git log -1 --pretty=git%ct.%h)
	version="$(perl -ne 's/^.*? VERSION_STRING = "([\.\d]*?)";$/$1/ && print' common/src/main/java/org/geogebra/common/GeoGebraConstants.java)+${git_stamp}"
	git config tar.tar.xz.command 'xz -c'
	git archive --prefix "${name}-${version}/" -o ../"${name}-${version}".tar.xz HEAD
popd

echo $name >NAME
echo $version >VERSION

container=build-${name}-$(echo "$version" |tr '+' _)

docker build -t opensuse/build-${name} .
docker run --name=${container} opensuse/build-${name}
docker cp ${container}:/build/obs .
docker container rm ${container}
