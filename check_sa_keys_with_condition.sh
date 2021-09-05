#!bin/sh
ROLE="roles/owner"
for PROJECT in $(\
  gcloud projects list \
  --format="value(projectId)" )
do
    gcloud iam service-accounts list --project=$PROJECT --format=json --flatten=email | sed 's/[]"",""[]//g' > svc
    for email in `cat svc`; do
    echo "----------------------------------------------"
    echo $email
    keyType=`gcloud iam service-accounts keys list --iam-account=$email --format=json --managed-by=user | jq '.[] | .keyType'`
    #echo $keyType
    if [[ -z $keyType ]]; then
    echo "This service account has only SYSTEM MANAGED keys"
    else
    echo "USER_MANAGED"
    keyName=`gcloud iam service-accounts keys list --iam-account=$email --format=flattened --managed-by=user --format='value(name)'`
    validAfterTime=`gcloud iam service-accounts keys list --iam-account=$email --format=flattened --managed-by=user --format='value(validAfterTime)'`
    echo $keyName
    echo $validAfterTime
    key_date1=(`echo $validAfterTime |cut -b-10`)
        #key_date1=$(date -d ${key_date} +"%Y/%m/%d" | cut -b-10)
        echo "key_date:" $key_date1
    now=$(date -u +"%Y-%m-%d")
    echo "today:" $now
        #echo "key_age"$(`($now - $key_date) / 86400 `)
        #difference= $(date --date="${now} - ${key_date1}" +"%Y-%m-%d")
    difference=$((($(date -u -d $now +%s) - $(date -u -d $key_date1 +%s)) / 86400))
        #echo $difference
    check='90'
    difference=91 #(change the values to test)
    if [ $difference -le '90' ] && [ $difference -le '85' ] && [ $difference -gt '80' ]
    then
        echo "phase-1 check"
        echo "svc account $email key needs to be rotated since the key age is $difference"
        owner=`(gcloud projects get-iam-policy ${PROJECT} \
        --flatten="bindings[].members[]" \
        --filter="bindings.role=${ROLE}" \
        --format="value(bindings.members)" | grep user |awk -F ':' '{print $2}')`
        echo $owner | tr " " "\n"
        printf "\n"

    fi

    if [ $difference -gt '85' ] && [ $difference -le '90' ]
    then
        echo "phase-2 check"
        echo "svc account $email key needs to be rotated since the key age is $difference"
        owner=`(gcloud projects get-iam-policy ${PROJECT} \
        --flatten="bindings[].members[]" \
        --filter="bindings.role=${ROLE}" \
        --format="value(bindings.members)" | grep user |awk -F ':' '{print $2}')`
        echo $owner | tr " " "\n"
        printf "\n"
    fi
    if [ $difference -gt '90' ]
    then
        echo "phase-3 check"
        echo "svc account $email key needs to be rotated since the key age is $difference"
        owner=`(gcloud projects get-iam-policy ${PROJECT} \
        --flatten="bindings[].members[]" \
        --filter="bindings.role=${ROLE}" \
        --format="value(bindings.members)" | grep user |awk -F ':' '{print $2}')`
        echo $owner| tr " " "\n"
        printf "\n"

    fi
    if [ $difference -le '80' ]
    then
        echo "default"
        echo "no changes since the key age is $difference"
    fi
    fi
    done
done
