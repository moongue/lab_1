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
	cat $DB > "$DATA_FOLDER/$(date +"%x_%X")-users.db.backup"
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
		help) echo "Help";;
	esac
done

