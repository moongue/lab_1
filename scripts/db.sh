#!/usr/bin/env bash

LATIN_REGEX='[A-Za-z]'
DATA_FOLDER='../data'
DB="$DATA_FOLDER/users.db"

checkIsNotEmptyAndLatinValue() {
	echo "$1" | grep -P -q $LATIN_REGEX
	if [ $? -eq 0 ]; then
		return 1
	fi

	echo "The value must be not empty and latin only"
	return 0
}

checkDBFileExist() {
	if [ ! -e "$DB" ]; then
		read -p "users.db not found do you want to create?(Y/y) " -n 1 -r
		echo ""
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			echo "Programm can't execute without users.db"
   			return 0
		fi
		touch $DB
	fi
	chmod ugo=rwx $DB
	return 1
}

add() {
	# Ask until get valid username
	echo -n "Username: "
	read username
	while checkIsNotEmptyAndLatinValue $username; do
		echo -n "Username: "
	        read username
	done
	
	# Ask until get valid role
	echo -n "Role: "
	read role
	while checkIsNotEmptyAndLatinValue $role; do
		echo -n "Role: "
		read role
	done

	echo "$username, $role" >> $DB
	echo "$username, $role - successfully added" 
}

backup() {
	# Copy DB file content into new backup file
	cat $DB > "$DATA_FOLDER/$(date +"%x_%X")-users.db.backup"
}

restore() {
	# Takes last backup file and replace users.db file
	local lastBackup=$(ls -t ../data/ | grep .\*\.backup | head -1)
	
	if [ $lastBackup ]; then
		cat "$DATA_FOLDER/$lastBackup" > $DB
	else
		echo "No backup file found"
	fi
}

findByUsername() {
	read -p "Username: " username
	local username=$(echo $username | tr '[:upper:]' '[:lower:]')
	local isFound=0
	while IFS= read -r line; do
		# Get first work from line without coma
 		local dbUsername=$(echo $line | tr ", " "\n" | head -1 | tr '[:upper:]' '[:lower:]')
		if [ $username == $dbUsername ]; then
			echo "$line"
			isFound=1
		fi	
	done < $DB
	[ $isFound -eq 0 ] && echo "User not found"
}

list() {
	local isReverse=$([ "$1" == "--inverse" ]; echo $?)
	local counter=1;
	local lines=$(cat $DB)
	local runCommand=cat
	local operator=-	

	if [ $isReverse -eq 0 ]; then
		runCommand=tac
		counter=$(cat $DB | wc -l)
	fi
	
	while IFS= read -r line; do
		echo "$counter. $line"
		
		if [ $isReverse -eq 0 ]; then
			counter=$((counter-1))
		else
			counter=$((counter+1))
		fi
	done <<< $($runCommand $DB)
}	

for arg in $@;
do
	case $arg in
		add) 
			checkDBFileExist && exit 1
			add;;
		backup)
			checkDBFileExist && exit 1
			backup;;
		restore)
			checkDBFileExist && exit 1
			restore;;
		find)
			checkDBFileExist && exit 1
			findByUsername;;
		list)
			checkDBFileExist && exit 1
			list $2;;
		help) echo "Help";;
	esac
done

