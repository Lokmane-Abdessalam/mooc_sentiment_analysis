#!/bin/bash

set -e

SPARK_VERSION="4.2.0"
SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop3"
SPARK_URL="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz"
SPARK_HOME="/usr/local/spark"

echo "=== Installing Apache Spark ${SPARK_VERSION} ==="

echo "Removing old Spark installation..."
rm -rf "${SPARK_HOME}"

echo "Downloading Spark ${SPARK_VERSION}..."
cd /tmp
wget -q "${SPARK_URL}"

echo "Extracting Spark..."
mkdir -p "${SPARK_HOME}"
tar -xzf "${SPARK_PACKAGE}.tgz" \
    --strip-components=1 \
    -C "${SPARK_HOME}"

echo "Cleaning up..."
rm -f "${SPARK_PACKAGE}.tgz"

echo "Configuring Spark..."
echo 'export SPARK_HOME=/usr/local/spark' > /etc/profile.d/spark.sh
echo 'export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH' >> /etc/profile.d/spark.sh
echo 'export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.9-src.zip' >> /etc/profile.d/spark.sh

chmod +x /etc/profile.d/spark.sh

echo "=== Spark installation completed ==="
"${SPARK_HOME}/bin/spark-submit" --version

echo "install python packages"
pip install translators emot bs4 nltk langdetect