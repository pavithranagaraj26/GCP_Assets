#gcloud asset search-all-resources --asset-types="cloudresourcemanager.googleapis.com/Project"  <project>
# gcloud beta projects list --format="value(projectId)" > list
# echo $project
for project in `cat list`;
do
    echo "$project check..."
    echo "=========================="
    api_check=`gcloud services list --enabled --project=$project --format="value(NAME)" | grep compute.googleapis.com`
    if [[ `echo $api_check | grep "compute.googleapis.com"` ]]
    then
        vm=`gcloud compute instances list --project=$project --format="value('NAME')" | wc -l`
        if [ $vm != 0 ];
        then
        echo "$project , $vm" >> vm.csv
        else
        pass
        fi
    fi
done
