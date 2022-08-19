#!/usr/bin/env bash

FILENAME=pipeline-$(date +"%X_%x").json
FILE_PATH=""
BRANCH="main"
OWNER=""
SOURCE_CHANGES=false
ENVS=""

while true; do
	case "$1" in
 	--branch ) 			      BRANCH=$2;  shift ;;
	--owner ) 				OWNER=$2; shift ;;
	--configuration ) 			ENVS=$2;  shift ;;
	--poll-for-source-changes )  SOURCE_CHANGES=true; shift ;;
	*.json ) 			   FILE_PATH=$1;  shift ;;
	-- ) 					shift;    break ;;
	* ) 					  	  break ;;
	esac
done

while true; do
	case "$2" in
	--branch ) 			       BRANCH=$3; shift ;;
	--owner ) 				OWNER=$3; shift ;;
	--configuration ) 			 ENVS=$4; shift ;;
	--poll-for-source-changes )  SOURCE_CHANGES=true; shift ;;
 	*.json ) 			    FILE_PATH=$2; shift ;;
	-- ) 					   shift; break ;;
	* )						  break ;;
	esac
done

while true; do
	case "$3" in
	--branch ) 			      BRANCH=$4; shift ;;
	--owner ) 			       OWNER=$4; shift ;;
	--configuration ) 			ENVS=$4; shift ;;
	--poll-for-source-changes ) SOURCE_CHANGES=true; shift ;;
	*.json) 			   FILE_PATH=$3; shift ;;
	-- ) 					  shift; break ;;
	* ) 						 break ;;
	esac
done

while true; do
	case "$4" in
	--branch ) 			      BRANCH=$5; shift ;;
	--owner ) 			       OWNER=$5; shift ;;
	--configuration ) 			ENVS=$5; shift ;;
	--poll-for-source-changes ) SOURCE_CHANGES=true; shift ;;
	*.json) 			   FILE_PATH=$4; shift ;;
 	-- ) 					  shift; break ;;
 	* ) 						 break ;;
	esac
done

~/../../sbin/ldconfig -p | grep jq
if ! [ $?  -eq 0 ]; then
	echo Error: JQ not found
	exit 1
fi

if [[ $FILE_PATH = "" ]]; then
	echo Error: path not found
	exit 1
fi


if [[ $OWNER = "" || $ENVS = "" ]]
then
	jq 'del(.metadata) | .pipeline.version +=1' profile.json > $FILENAME

	echo Error: --owner and --configuration not specified
	exit 1
fi

jq --arg branch "$BRANCH" --arg changes "$SOURCE_CHANGES" --arg owner "$OWNER" --arg config "$ENVS" 'del(.metadata) | .pipeline.version +=1 | .pipeline.stages[0].actions[0].configuration.Branch = $branch  | .pipeline.stages[0].actions[0].configuration.Owner = $owner | .pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $changes | .pipeline.stages[].actions[].configuration.EnvironmentVariables = $config' ${FILE_PATH} > $FILENAME

