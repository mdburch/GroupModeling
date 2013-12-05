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
LOG_DIRECTORY = './Event_Logs/'
MODEL_FILE    = 'ModelFile'
NAME	      = 'name'
RESULTS	      = 'results'
UNKNOWN_MDL   = 'unknown.mdl' 
URL	      = 'url'

import base64, hashlib, httplib, json, os, sys, urllib, urllib2
from collections import namedtuple
from array import *

# Make sure the user passed in a file name.
if len(sys.argv) <= 1:
	print "Please enter a path to Dropbox"
	print "ex. ./downloadLogs.py ../Dropbox/"
	sys.exit()

# Get the file contents to hash.
dropboxPath = str(sys.argv[1])

# Make sure the dropbox path at least exists.
if not os.path.exists(dropboxPath):
	print "The path " + dropboxPath + "does not exist. Please enter a different path."
	sys.exit()

# Make sure the dropbox path is a directory and not a file.
if not os.path.isdir(dropboxPath):
	print "The path " + dropboxPath + " is not a directory."
	sys.exit()

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
# Get data from Parse and store in result.
print "Retrieving data from the database"
connection = httplib.HTTPSConnection(PARSE_ADDRESS, PORT)

params = urllib.urlencode({"order":"gid,createdAt", "keys":"UserID,EndingHash,gid,EventLog,ModelFile"})
connection.connect()
connection.request('GET', '/' + API_VERSION + '/classes/' + TABLE + '?%s' % params,'', {
	"X-Parse-Application-Id": APP_ID,
	"X-Parse-REST-API-Key": API_KEY 
})
data = json.loads(connection.getresponse().read())

# Create the log directory if it does not exist
if not os.path.exists(LOG_DIRECTORY):
	os.makedirs(LOG_DIRECTORY)

# write the data in the table to a text file.
with open(LOG_DIRECTORY + DATABASE_FILE, 'w') as outfile:
	json.dump(data, outfile, sort_keys=True, indent=4, separators=(',',': '))
print "Finished retrieving data from the database"

###############################################################################
# Download the log and model files
# Get the table of data   
results = data[RESULTS]
print "There are " + str(len(results)) + " records in the database"

id = results[0][GID]
fileCount = 1		#Keeps track of the number of files we have parsed for the current GID.

# Iterate over all of the records in the table
for i, record in enumerate(results):
	print "Processing record id number " + str(i+1)
	# Track when we read in another id
	if record[GID] != id:
		id = record[GID]
		fileCount = 1

	# Get the log file url, model url, and ending hash
	logURL   = record[EVENT_LOG][URL]
	modelURL = record[MODEL_FILE][URL]
	endHash  = record[ENDING_HASH][BASE64]
	
	# Download the contents of the log located at the url
	downloadedLogFile = urllib2.urlopen(logURL)
	log = downloadedLogFile.read()

	# Download the contents of the model located at the url
	downloadedModelFile = urllib2.urlopen(modelURL)
	model = downloadedModelFile.read() 

	# Create the directory for each global id if it does not exist
	fileDir = LOG_DIRECTORY + 'id' + str(id) + '/'
	if not os.path.exists(fileDir):
		os.makedirs(fileDir)

	# Prefix name of the log and model file.
	fileName = 'id' + str(id) + '_' + str(fileCount) + '_'

	# Get the model file name if it exists to append to the end
	modelFileName = UNKNOWN_MDL

	# Search the dropbox hashes for the file name
	for item in dropboxHashes:
		if item.hash == endHash:
			modelFileName =  item.name
			break	

	# Open file with unique name and write the log file to it.	
	f =  open(fileDir + fileName + modelFileName[:-4] + '.csv', 'w')
	f.write(log)


	# Open file with unique name and write the mdl/txt file to it.
	f = open(fileDir + fileName + modelFileName, 'w')
	f.write(model)

	fileCount+=1

print "Completed! Results written to folder " + LOG_DIRECTORY
