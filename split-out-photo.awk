# vCard photo parsing script
#
# takes a vCard contact file and exports the photo into a vcard.extension file
#
# Author: 
#	John Drinkwater, john@nextraweb.com
# Contains code from http://www.turtle.dds.nl/b64dec.awk,
#  copyright Peter van Eerten, licenced under the GPL
#
# Licence:
#	AGPL v3
#
# run as: awk -f split-out-photo.awk vcardfile.vcf

# TODOs
# needs to listen to PHOTO line, i.e., encoding and filetype

###

function decodebase64(stuff) {

BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

result = ""
while (length(stuff) > 0){
	# Now find numerical position in BASE64 string
	byte1 = index(BASE64, substr(stuff, 1, 1)) - 1
	if (byte1 < 0) byte1 = 0
	byte2 = index(BASE64, substr(stuff, 2, 1)) - 1
	if (byte2 < 0) byte2 = 0
	byte3 = index(BASE64, substr(stuff, 3, 1)) - 1
	if (byte3 < 0) byte3 = 0
	byte4 = index(BASE64, substr(stuff, 4, 1)) - 1
	if (byte4 < 0) byte4 = 0
	# Reconstruct ASCII string
	result = result sprintf( "%c", lshift(and(byte1, 63), 2) + rshift(and(byte2, 48), 4) )
	result = result sprintf( "%c", lshift(and(byte2, 15), 4) + rshift(and(byte3, 60), 2) )
	result = result sprintf( "%c", lshift(and(byte3, 3), 6) + byte4 )
	# Decrease incoming string with 4
	stuff = substr(stuff, 5)
}
return result;
}

###


BEGIN {
	FS = ";"
	gotphoto = 0
	nomphoto = 0
}

/BEGIN:VCARD/ {
	contactn = ""
	contactfn = ""
}

/PHOTO/ {
# got a contact, start variables anew
	gotphoto = 1
	nomphoto = 1
	photo = ""
	$0 = ""
}

// {
# store each line temporarily
	if ( gotphoto == 1 && nomphoto == 1 ) {
		photo = photo $0
	}

	# contains =, fin!
	if ( $0 ~ /=/ ) {
		nomphoto = 0
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

	# strip potential spaces
	gsub(/ /, "", photo)

	if ( length(contactis) > 0 ) {
		if ( gotphoto == 1 ) {
			print "Found " contactis ", and it contains a photo, exporting file."
			photodecoded = decodebase64( photo )
			print photodecoded > contactis ".jpg"
		} else {
			print "Found " contactis ", but it does not contain a photo."
		}
	}
}

