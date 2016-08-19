#!/bin/bash

echo "Preparing to import OS OpenData products..."

fileBaseDir=/vagrant/source/os/
binDir=../../bin/linux

cd $fileBaseDir

for s in $binDir/gm-import-os*
do
	dos2unix $s
done

if [ -z $1 ]
then
	searchTerm="*/"
else
	searchTerm=$1
fi

echo "-----------------------------------"
echo "--> Extracting archives..."
echo "-----------------------------------"
for d in $searchTerm
do
	productName=${d%/}
	echo "Found product $productName..."
	if [ -e $binDir/gm-import-os-$productName.sh ]
	then
		echo " --> Found an import script"
		cd "$fileBaseDir/$d"
		echo " --> Proceeding to extract archives..."
		for z in *.zip
		do
			echo "     --> Extracting $z..."
			unzip -o "$z"
		done
		
		echo " --> Running product import script..."
		$fileBaseDir/$binDir/gm-import-os-$productName.sh $productName
		echo " --> Cleaning extracted files..."
		
		for e in */
		do
			echo "     --> Deleting directory $e..."
			rm -rf "$e"
		done
		for f in `ls -I*.zip -I*.sql`
		do
			echo "     --> Deleting file $f..."
			rm -rf "$f"
		done
		
		echo " --> Importing to SQL server..."
		for f in *.sql
		do
			echo "     --> Importing SQL file $f..."
			psql -Ugrough-map grough-map -h 127.0.0.1 -f $f > /dev/null 
		done
		
		echo " --> Removing SQL files..."
		for f in *.sql
		do
			echo "     --> Deleting SQL file $f..."
			rm -rf "$f"
		done
		
		cd $fileBaseDir
	else
		echo " --> Skipping as no import script exists"
	fi
done

echo "--> Import complete."
