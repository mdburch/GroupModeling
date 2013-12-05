#! /usr/bin/env python

# Constants for getting data from Parse	
APP_ID        = "ENTER YOUR APP ID HERE"
API_KEY       = "ENTER YOUR REST API KEY HERE"
API_VERSION   = '1'
PARSE_ADDRESS = 'api.parse.com'
PORT	      = 443
TABLE	      = 'EventLogger'
DATABASE_FILE = 'database.json'

# Constants for downloading the log files
BASE64	      = 'base64'
ENDING_HASH   = 'EndingHash'
EVENT_LOG     = 'EventLog'
GID	      = 'gid'
MODEL_FILE    = 'ModelFile'
RESULTS	      = 'results' 
URL	      = 'url'
UNKNOWN_MDL   = 'unknown.mdl'

import base64, hashlib, httplib, json, os, sys, urllib, urllib2
from collections import namedtuple
from array import *

# Make sure the user passed in a file name.
if len(sys.argv) <= 2:
	print "Please enter a file name and a path to dropbox"
	print "ex. ./downloadLogsForFile.py file.mdl ../Dropbox/"
	sys.exit()

fileName = str(sys.argv[1])

# Make sure the file name passed in is a file.
if not os.path.isfile(fileName):
	print "There is no file named: " + fileName
	sys.exit()

try:
	inputFile = file(fileName, 'rb').read()
except:
	print "Issue reading " + fileName
	sys.exit()

# Hash the file.
inputHash = hashlib.sha1()
inputHash.update(inputFile)


# Get the file contents to hash.
dropboxPath = str(sys.argv[2])

# Make sure the dropbox path at least exists.
if not os.path.exists(dropboxPath):
	print "The path " + dropboxPath + " does not exist. Please enter a different path."
	sys.exit()

# Make sure the dropbox path is a directory and not a file.
if not os.path.isdir(dropboxPath):
	print "The path " + dropboxPath + " is not a directory."
	sys.exit()

###############################################################################

# An array that will keep track of the files and hashes located in Dropbox
dropboxHashes = []

###############################################################################
# Hash all of the mdl or txt file in the path provided from the command line
print "Processing files in " + dropboxPath
for path, dirs, files in os.walk(dropboxPath):
	dirs[:] = [d for d in dirs if not d[0] == '.'] #remove hidden directories
	for filename in files:
        	fullpath = os.path.join(path, filename)
		if filename.endswith(".txt") or filename.endswith(".mdl"): 
			f = file(fullpath, 'rb').read()
	
			# Created the tuple that will contain the data
			HashData = namedtuple('HashData', ['name', 'hash'])
			m = hashlib.sha1()
			m.update(f)
			h = HashData(filename, base64.b64encode(m.digest()))
	
			# Add the hash to the table
			dropboxHashes.append(h)	
print "Processed " + str(len(dropboxHashes)) + " mdl or txt files in " + dropboxPath

###############################################################################
# Get GID from Parse with the ending hash value of the input file
connection = httplib.HTTPSConnection(PARSE_ADDRESS, PORT)

params = urllib.urlencode({"where": json.dumps({
	ENDING_HASH: base64.b64encode(inputHash.digest())}), "keys":"gid,EventLog"})
connection.connect()
connection.request('GET', '/' + API_VERSION + '/classes/' + TABLE + '?%s' % params,'', {
	"X-Parse-Application-Id": APP_ID,
	"X-Parse-REST-API-Key": API_KEY 
})
data = json.loads(connection.getresponse().read())

###############################################################################
# Get the history of the files given the GID.
try:
	results = data[RESULTS]
	globalID = results[0][GID]

	params = urllib.urlencode({"where": json.dumps({
		"gid": globalID}), "order":"createdAt", "keys":"EndingHash,EventLog,ModelFile"})
	connection.connect()
	connection.request('GET', '/' + API_VERSION + '/classes/' + TABLE + '?%s' % params,'', {
		"X-Parse-Application-Id": APP_ID,
		"X-Parse-REST-API-Key": API_KEY 
	})
	data = json.loads(connection.getresponse().read())
except:
	print "There was no matching record in the database"

###############################################################################
# Download the log and model files for everything using globalID
try:
	results = data[RESULTS]
	print "There are " + str(len(results)) + " records in the database linked to " + fileName
	for i, record in enumerate(results):
		print "Processing record id number " + str(i+1)
		
		# Get the log file url, model url, and ending hash
		logURL   = record[EVENT_LOG][URL]
		modelURL = record[MODEL_FILE][URL]
		endHash  = record[ENDING_HASH][BASE64]

		# Download the contents of the log and model file
		downloadedFile = urllib2.urlopen(logURL)
		log = downloadedFile.read()

		downloadedFile = urllib2.urlopen(modelURL)
		model = downloadedFile.read()

		# Create directory to store these files
		dir = "id" + str(globalID) + '/'
		if not os.path.exists(dir):
			os.makedirs(dir)

		modelFileName = UNKNOWN_MDL
		# Search the dropbox hashes for the file name
		for item in dropboxHashes:
			if item.hash == endHash:
				modelFileName =  item.name
				break	
		
		# Prefix for the file name.
		fileName = dir + 'id' + str(globalID) + '_' + str(i+1) + '_'
		
		
		# Open file with unique name and write the log file to it.	
		f = open(fileName +  modelFileName[:-4] + ".csv", 'w')
		f.write(log)

		# Open file with unique name and write the mdl file to it.	
		f = open(fileName+ modelFileName, 'w')
		f.write(model)


	print "Success! Data written to folder: " + dir
except:
	print "There was an issue writing data to the files"

