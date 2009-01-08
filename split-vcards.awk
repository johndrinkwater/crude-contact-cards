#	Compound vCard parsing script
#	takes a compound vCard contact file and splits it into little files
#	named after the contact name of the card
#	
#	Copyright (C) 2009 John Drinkwater
#	Licence: AGPL v3
#	
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU Affero General Public Licence as
#	published by the Free Software Foundation, either version 3 of the
#	Licence, or (at your option) any later version.
#	
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU Affero General Public Licence for more details.
#	
#	You should have received a copy of the GNU Affero General Public Licence
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# run as: awk -f split-vcards.awk vcardfile.vcf

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
	gsub(//, "", contact)

	if ( length(contactis) > 0 ) {
		print "Found " contactis ", writing file"
		print contact > contactis
	}
}
