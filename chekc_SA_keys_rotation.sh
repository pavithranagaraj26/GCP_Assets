gcloud iam service-accounts list --project=<project> --format=json --flatten=email | sed 's/[]"",""[]//g' > svc
for email in `cat svc`;
    echo $email
    key_date=`gcloud iam service-accounts keys list --iam-account=$email --format=json --format='value(validAfterTime)'`
    key_date1=(`echo $key_date |cut -b-10`)
    #key_date1=$(date -d ${key_date} +"%Y/%m/%d" | cut -b-10)
    echo "key_date": $key_date1
    now=$(date -u +"%Y-%m-%d")    now1= $(date -d ${now} +"%Y-%m-%d")    echo "today" $now    #echo "key_age"$(`($now - $key_date) / 86400 `)
    echo $((($now1 - $key_date1) / 86400 )) days
    difference= $(date --date="${now} - ${key_date1}" +"%Y-%m-%d")
    echo difference
