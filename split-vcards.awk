# vCard parsing script
#
# takes a compound vCard contact file and splits it into little files
# named after the contact name
#
# Author: 
#	John Drinkwater, john@nextraweb.com
#
# Licence:
#	AGPL v3
#
# run as: awk -f make-single.awk vcardfile.vcf

BEGIN {
	FS = ";"
}

/BEGIN:VCARD/ {
# got a contact, start variables anew
	contact = ""
	contactn = ""
	contactfn = ""
}

// {
# store each line temporarily
	if (length(contact) == 0) {
		contact = $0
	} else {
		contact = contact "\n" $0
	}
}

/^N:/ {
# got a vcard multi/part name, favoured
	familyname = ""
	familyname = substr($1, 3 )
	contactn = $2 " " familyname
}

/^FN:/ {
# got a vcard precomposed name
	contactfn = substr( $0, 4 )
}


/END:VCARD/ {
	# print contact
	# go to check FN or N here to see if any were set
	contactis = ""
	if ( contactn ) {
		contactis = contactn
	} else  {
		if ( contactfn ) {
			contactis = contactfn
		} else {
			# fail
		}
	}

	sub(/^ */, "", contactis)
	sub(/ *$/, "", contactis)

	if ( length(contactis) > 0 ) {
		print "Found " contactis ", writing file"
		print contact > contactis
	}
}
