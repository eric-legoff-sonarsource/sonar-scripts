#!/bin/bash

export SQ_HOST_URL=$1
export PROJECT_KEY=$2
export PAGE_SIZE=500


get_components(){
    echo $(curl -s "$SQ_HOST_URL/api/components/tree?component=$PROJECT_KEY&ps=$PAGE_SIZE&p=$1" | jq -r '.paging.total, .components[].language' | grep -v null )
}

res=$(get_components 1)
arr=($res)
total=${arr[0]}
page=$(((total / PAGE_SIZE)+1))
rest=("${arr[@]:1}") 
langs=$(echo "${rest[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

#we may have pagination
while [  $page -gt 1 ]; do
             res=$(get_components $page)
             arr=($res)
             rest=("${arr[@]:1}")
             others=$(echo "${rest[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
             langs+=( "${langs[@]}" "${others[@]}" )             
             let page=page-1 
         done

#remove duplicates
langs=$(echo "${langs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

##iterate aover used languages
for l in $langs; do 
    #get quality profile for a language in use
    curl -s "$SQ_HOST_URL/api/qualityprofiles/search?project=$PROJECT_KEY&language=$l" | jq '.profiles[] |  "\(.name) [\(.languageName)]"'    
done


