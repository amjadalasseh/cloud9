#!/bin/sh

[ $# -ne 7 ] && {
  echo "Usage: $0 <bucket-name> <brand> <country> <project> <test-case> <bucket-region> <timestamp> "
  exit 1;
}

bucket_name=${1:-"gdp-ta"}
brand=$2
country=$3
project=$4
test_case=$5
bucket_region=$6
timestamp=$7

# Step 1: get test cases from s3 / github
bucket_path=s3://$bucket_name/JMeter
s3_test_case_path=$bucket_path/test-cases
ec2_dir=/home/ubuntu/JMeter

#download from s3
aws s3 cp $s3_test_case_path/$project $ec2_dir --recursive --region $bucket_region

# Step 2: change test case config
dos2unix ./env.sh
chmod +x ./env.sh
./env.sh $brand $country $test_case

# Step 3: Run test
sudo mkdir results
sudo chmod 777 results
cd results
/home/ubuntu/apache-jmeter-3.2/bin/jmeter -n -t $ec2_dir/$test_case -l result-jtl -e -o result-report -j jmeter.log

# Step 4: upload result to s3
aws s3 cp . $bucket_path/results/$project/$timestamp --recursive --region $bucket_region
