#!/bin/bash

# Searches into a tree of folders specified by a root folder ($BIBLIO_PATH)
#and reads with pdfinfo the information about each pdf file, storing that information
#as bibtex entries (all bibtex entries have the same type $ENTRY_TYPE)

BIBLIO_PATH="~/Biblio" # default root path
BIB_FILE="biblio_full.bib"
URL_PREFIX="http://localhost"
ARTICLE_FIELDS="author title journal year month volume number pages keywords"
BOOK_FIELDS="title publisher year editor author"
ENTRY_TYPE="ARTICLE"
FIELDS=$ARTICLE_FIELDS
COUNT=0
E_SUCCESS=0

writeBibTeXEntry ()
{
	YEAR=`pdfinfo "$1" | grep "CreationDate" | cut -d':' -f4 | cut -d' ' -f2`
	echo "@$ENTRY_TYPE{`echo $YEAR | cut -c 3-`," >> $BIBLIO_PATH/$BIB_FILE #bibtexkey (last two digits of the year)
	for field in $FIELDS
	do
		if [ $field == "year" ]
		then
			echo -e "\tyear = {$YEAR}," >> $BIBLIO_PATH/$BIB_FILE
			continue
		fi
		if [ $field == "pages" ]
		then
			echo -e "\tpages = {}," >> $BIBLIO_PATH/$BIB_FILE
			continue
		fi
		FIELD=`pdfinfo "$1" | grep -i $field | cut -d':' -f2 | sed -e 's/^[ \t]*//'`
		echo -e "\t$field = {$FIELD}," >> $BIBLIO_PATH/$BIB_FILE
	done
	echo -e "\turl = {$URL_PREFIX/$1}\n}" >> $BIBLIO_PATH/$BIB_FILE
	let "COUNT += 1"
}

processPDFfiles ()
{
	for file in $1/*
	do
		if [ -f "$file" ] && [ `basename "$file" | sed -n 's/\(^.[^$]*\)\(.\{3\}$\)/\2/p' | tr "[:upper:]" "[:lower:]"` == "pdf" ]
		then
			writeBibTeXEntry "$file"
		else
			if [ -d "$file" ]
			then
				echo "Scanning folder $file"
				processPDFfiles "$file"
			fi
		fi
	done
}

# ------------------------------- main program --------------------------------------------

# the argument is a pdf file
if [ -f "$1" ] && [ `basename "$1" | sed -n 's/\(^.[^$]*\)\(.\{3\}$\)/\2/p' | tr "[:upper:]" "[:lower:]"` == "pdf" ]
then
	BIBLIO_PATH="/tmp"
	writeBibTeXEntry "$1"
	cat $BIBLIO_PATH/$BIB_FILE
	rm -f $BIBLIO_PATH/$BIB_FILE
	exit $E_SUCCESS
fi

# the argument is the root folder for pdf files
if [ -d $1 ]
then
	BIBLIO_PATH=$1
fi

# second argument, if any the entry type to use for each pdf file
if [ $# == 2 ]
then
	if [ $2 == "ARTICLE" ] || [ $2 == "article" ]
	then
		ENTRY_TYPE="ARTICLE"
		FIELDS=$ARTICLE_FIELDS
	fi
	if [ $2 == "BOOK" ] || [ $2 == "book" ]
	then
		ENTRY_TYPE="BOOK"
		FIELDS=$BOOK_FIELDS
	fi
fi

echo "Scanning from root folder $BIBLIO_PATH"
rm -f $BIBLIO_PATH/$BIB_FILE #remove old bib file since we will append to the end of the file
URL_PREFIX="$URL_PREFIX/`pwd | cut -d/ -f4-`"
processPDFfiles $BIBLIO_PATH
echo -e "Done\nNumber of processed files: $COUNT"
