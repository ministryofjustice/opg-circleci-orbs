#!/usr/bin/env bash
set -eo pipefail

ACTION=${1:?}
# save value stored in file to a local env var
CIRCLE_COMPARE_URL=$(cat CIRCLE_COMPARE_URL.txt)

COMMIT_RANGE=$(echo ${CIRCLE_COMPARE_URL:?} | sed 's:^.*/compare/::g')

echo "Commit range: ${COMMIT_RANGE:?}"

for ORB in src/*/; do
  orbname=$(basename ${ORB:?})
  if [[ $(git diff $COMMIT_RANGE --name-status | grep "${orbname:?}") ]];then

    if [[ $ACTION == "dev_release" ]];then
      (ls ${ORB:?}orb.yml && echo "orb.yml found, attempting to publish...") || echo "No orb.yml file was found - the next line is expected to fail."
      circleci orb publish ${ORB}orb.yml ministyofjustice/${orbname}@dev:${CIRCLE_BRANCH:?}-${CIRCLE_SHA1:?} --token ${CIRCLECI_API_TOKEN:?}
    elif [[ $ACTION == "patch_release" ]];then
      echo "promoting circleci/${orbname}@dev:${CIRCLE_BRANCH}-${CIRCLE_SHA1} as patch release"
      circleci orb publish promote ministyofjustice/${orbname}@dev:${CIRCLE_BRANCH}-${CIRCLE_SHA1} patch --token $CIRCLECI_API_TOKEN
    fi

  else
    echo "${orbname:?} not modified; no need to promote"
  fi
  echo "------------------------------------------------------"
done


