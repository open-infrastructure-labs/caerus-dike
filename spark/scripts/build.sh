#!/bin/bash

set -e
#set -x
echo "Building option: [$1]"

# Start fresh, so remove the spark home directory.
echo "Removing $SPARK_HOME"
rm -rf $SPARK_HOME

# Build Spark
cd $SPARK_SRC
if [ ! -d $SPARK_BUILD ]; then
  echo "Creating Build Directory"
  mkdir $SPARK_BUILD
fi
if [ ! -d $SPARK_BUILD/spark-events ]; then
  mkdir $SPARK_BUILD/spark-events
fi

# Only build spark if it was requested, since it takes so long.
if [ "$1" == "spark" ]; then
  pushd build
  # Download and Install Spark.
  if [ ! -f $SPARK_PACKAGE ]; then
    echo "Downloading Spark: $SPARK_PACKAGE_URL"
    wget $SPARK_PACKAGE_URL
  else
    echo "$SPARK_PACKAGE already exists, skip download."
  fi
  # Extract our built package into our install directory.
  echo "Extracting $SPARK_PACKAGE to $SPARK_HOME"
  tar -xzf $SPARK_PACKAGE -C /build \
    && mv $SPARK_BUILD/$SPARK_PACKAGE_FOLDER $SPARK_HOME
  popd
else
  echo "Building spark"
  rm $SPARK_SRC/spark-*SNAPSHOT*.tgz || true
  ./dev/make-distribution.sh --name custom-spark --pip --tgz
  # Install Spark.
  # Extract our built package into our install directory.
  echo "Extracting $SPARK_PACKAGE.tgz -> $SPARK_HOME"
  sudo tar -xzf "$SPARK_SRC/$SPARK_PACKAGE.tgz" -C $SPARK_BUILD \
  && mv $SPARK_BUILD/$SPARK_PACKAGE $SPARK_HOME
fi

# Download jar dependencies needed for using S3
# We do this to avoid using the --packages argument to spark-submit.
# Instead we will use --jars /build/extra_jars/*
# This avoids the extra time to run ivy for all dependencies.
#
SPARK_DOWNLOADS=${SPARK_BUILD}/downloads
if [ ! -d $SPARK_DOWNLOADS ]; then
  echo "Creating Downloads Directory"
  mkdir $SPARK_DOWNLOADS
fi
cd $SPARK_DOWNLOADS
if [ ! -f "aws-java-sdk.zip" ]; then
    echo "Downloading aws-java-sdk.zip.  Please be patient."
    wget -nv http://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip
    wget -nv https://repo1.maven.org/maven2/org/apache/commons/commons-csv/1.8/commons-csv-1.8.jar
    mkdir $SPARK_BUILD/extra_jars || true
    cp ./commons-csv*.jar $SPARK_BUILD/extra_jars
else
    echo "Using existing aws-java-sdk.zip"
fi

unzip -n -q aws-java-sdk.zip \
  && cp ./aws-java-sdk-*/third-party/lib/*.jar $SPARK_BUILD/extra_jars \
  && cp ./aws-java-sdk-*/lib/aws*.jar $SPARK_BUILD/extra_jars \
  && rm -rf ./aws-java-sdk-*
if [ ! -f "spark-sql-macros_2.12.10_0.1.0-SNAPSHOT.jar" ]; then
  wget -nv https://github.com/hbutani/spark-sql-macros/releases/download/v0.1.0/spark-sql-macros_2.12.10_0.1.0-SNAPSHOT.jar
fi
if [ ! -f "h2-1.4.200.jar" ]; then
    echo "downloading h2-1.4.200.jar"
    wget -nv https://repo1.maven.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200.jar
fi



