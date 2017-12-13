#!/bin/sh

[ $# -lt 3 ] && {
  echo 'pooooo'
  echo $1;
  echo "Usage: $0 <cloudformation-stack-name> <project: papi> <test-case> <region> <brand> <country> <yml_template> "
  exit 1;
}

stack_name=${1:-"jmeter-distributed"}
project=$2
test_case=$3
region=$4
brand=$5
country=$6
yml_template=${7:-"file://jmeter-distributed.yml"}

[ -z $region ] && {
  echo -e "\nSelect a region:\nSG - Singapore (JobStreet & JobsDB)\nAU - Sdyney (SEEK)\nBR - Brazil (Catho)\nNV - North Nigeria (OCC)"
  read region
}

[ -z $brand ] && { echo -e "\nSelect a brand:\nJobStreet, JobsDB, Catho, OCC, SEEK" ; read brand ; }

[ -z $country ] && {
  echo -e "\nSelect a country:\nMY - Malaysia\nSG - Singapore\nPH - Philippines\nID - Indonesia\nVN - Vietnam"
  echo -e "HK - Hong Kong\nTH - Thailand\nBR - Brazil\nMX - Mexico\nAU - Australia\nNZ - New Zealand"
  read country
}

case $region in
  SG) region="ap-southeast-1" ; parameters="parameters.json" ; break ;;
  AU) region="ap-southeast-2" ; parameters='file://parameters_au.json' ; break;;
  BR) region="ap-southeast-1" ; parameters="parameters_br.json" ; break ;;
  NV) region="ap-southeast-1" ; parameters="parameters_nv.json" ; break ;;
  *) region="ap-southeast-1" ; parameters="parameters.json" ; break ;;
esac

aws cloudformation create-stack --stack-name $stack_name --template-body $yml_template --capabilities CAPABILITY_NAMED_IAM --parameters $parameters --region $region
exit;
#replace parameters
sed -i "s/project_to_be_replaced/$project/g" $parameters
sed -i "s/tc_to_be_replaced/$test_case/g" $parameters
sed -i "s/brand_to_be_replaced/$brand/g" $parameters
sed -i "s/country_to_be_replaced/$country/g" $parameters

# timestamp
date_time=`date +%Y%m%d-%H%M%S`
sed -i "s/ts_to_be_replaced/$date_time/g" $parameters

case $project in
  cpp-papi) git_repo="https://github.com/seekinternational/papi.git" ; break ;;
  *) git_repo="https://github.com/seekinternational/papi.git"; break ;;
esac

if aws s3 ls s3://gdp-ta/JMeter/test-cases/$project/ 2>&1  #| grep -q $test_case
then
  # do nothing
  echo "found in s3... proceed..."
elif git clone $git_repo 2>&1
then
  echo "git clone project: $project - $git_repo"
  # upload to S3
  aws s3 cp ./$project/jmeter s3://gdp-ta/JMeter/test-cases/$project --recursive --region $region
  # delete folder
  rm -rf ./$project
else
  echo "exit here"
  exit;
fi

echo "Test is being executing, please wait..."
echo "Result will be uploaded to ..."

echo "Please check s3://$bucket_name/JMeter/result/$project/$date_time"

aws cloudformation create-stack --stack-name $stack_name --template-body $yml_template --capabilities CAPABILITY_NAMED_IAM --parameters $parameters --region $region
