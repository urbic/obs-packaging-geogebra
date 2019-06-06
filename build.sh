#!/bin/sh
name=geogebra
sources_updated=false

rm -rf obs

git clone --depth=1 https://github.com/geogebra/geogebra.git ${name}-SNAPSHOT

pushd ${name}-SNAPSHOT || exit
	git_hash_old=$(git log -1 --pretty=%h)
	git pull
	git_hash=$(git log -1 --pretty=%h)
	#[ "$git_hash" = "$git_hash_old" ] && sources_updated=true
	git_stamp=$(git log -1 --pretty=git%ct.%h)
	version="$(perl -ne 's/^.*? VERSION_STRING = "([\.\d]*?)";$/$1/ && print' common/src/main/java/org/geogebra/common/GeoGebraConstants.java)+${git_stamp}"
	git config tar.tar.xz.command 'xz -c'
	git archive --prefix "${name}-${version}/" -o ../."${name}-${version}".tar.xz HEAD
popd
rm -f sources/${name}-*.tar.xz
mv ."${name}-${version}".tar.xz sources/"${name}-${version}".tar.xz

#[ ${sources_updated} = true ] && echo UPDATED
#osc vc -m "Update to v${version}" ${name}.changes

container=build-${name}-$(echo "$version" |tr '+' _)

docker build -t opensuse/build-${name} .
docker run --name=${container} opensuse/build-${name} make NAME=${name} VERSION=${version}
docker cp ${container}:/build/obs .
docker container rm ${container}
