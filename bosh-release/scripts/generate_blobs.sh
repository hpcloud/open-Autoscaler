#!/bin/bash -e

base_dir=$(cd "$(dirname "$0")"; pwd)
release_dir="$base_dir/../"
blobs_dir="$base_dir/../blobs"
download_dir="$base_dir/../downloads"

openjdk_artifact="openjdk-1.8.0_60.tar.gz"
tomcat_artifact="apache-tomcat-8.0.32.tar.gz"
erlang_artifact="otp_src_R16B03-1.tar.gz"
spidermonkey_artifact="js185-1.0.0.tar.gz"
python_artifact="Python-2.7.6.tgz"
icu_artifact="icu4c-52_1-src.tgz"
couchdb_artifact="apache-couchdb-1.6.1.tar.gz"

autoscaler_api_artifacts="api.war"
autoscaler_server_artifacts="server.war"
autoscaler_servicebroker_artifacts="servicebroker.war"

mkdir -p $download_dir
cd $download_dir

echo "Download autoscaler artifacts "
cp $release_dir/../api/target/api*.war ./$autoscaler_api_artifacts
cp $release_dir/../server/target/server*.war ./$autoscaler_server_artifacts
cp $release_dir/../servicebroker/target/servicebroker*.war ./$autoscaler_servicebroker_artifacts

echo "Download required depencies "
set -x
if [ ! -f $openjdk_artifact ]; then
	curl -OL http://download.run.pivotal.io/openjdk/trusty/x86_64/$openjdk_artifact
fi

if [ ! -f $tomcat_artifact ]; then
	curl -OL http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/$tomcat_artifact
fi

if [ ! -f $erlang_artifact ]; then
	curl -OL http://erlang.org/download/$erlang_artifact
fi

if [ ! -f $spidermonkey_artifact ]; then
	curl  -OL https://ftp.mozilla.org/pub/js/$spidermonkey_artifact
fi

if [ ! -f $python_artifact ]; then
	curl -OL https://www.python.org/ftp/python/2.7.6/$python_artifact
fi

if [ ! -f $icu_artifact ]; then
	curl -OL http://download.sourceforge.net/project/icu/ICU4C/52.1/$icu_artifact
fi

if [ ! -f $couchdb_artifact ]; then
	curl -OL http://mirrors.gigenet.com/apache/couchdb/source/1.6.1/$couchdb_artifact
fi
set +x

cd $release_dir
rm -rf $blobs_dir/*

echo "Add blobs for autoscaler artifacts"
bosh add blob $download_dir/$autoscaler_api_artifacts  autoscaler
bosh add blob $download_dir/$autoscaler_server_artifacts  autoscaler
bosh add blob $download_dir/$autoscaler_servicebroker_artifacts  autoscaler


echo "Add blobs for depencies "
bosh add blob $download_dir/$openjdk_artifact  openjdk
bosh add blob $download_dir/$tomcat_artifact apache-tomcat

bosh add blob $download_dir/$erlang_artifact couchdb/erlang
bosh add blob $download_dir/$spidermonkey_artifact couchdb/spidermonkey
bosh add blob $download_dir/$python_artifact  couchdb/python
bosh add blob $download_dir/$icu_artifact couchdb/icu
bosh add blob $download_dir/$couchdb_artifact couchdb
