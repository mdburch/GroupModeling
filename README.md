GroupModeling
=============

This iOS application allows users to create causal loop diagram models using system dynamics concepts.  This app was designed as a method for Group Model Building.


In order to use the app you will need the following accounts:

*Parse (http://parse.com).
  -An AppID ClientKey and REST API Key will be created that will be used in the AppDelegate and the provided Python files.
  -This is used to store metrics on events that occur when a user is interacting with the user interface.
  -This comes in handy if you intend on using the Python scripts provided in this repo. (https://parse.com/docs/rest)
  -For more information on how to set this up visit https://parse.com/apps/quickstart . 
  

*Dropbox Chooser (https://www.dropbox.com/developers/dropins/chooser/ios).  
  -Dropbox chooser will give you a url-scheme that you will need to update in your Project Navigator.
  -This is used to access a user's Dropbox account to open up saved files. 
  -Saving files to Dropbox is used through a UIDocumentInteractionController as the Dropbox Saver had not been implemented at the time of implementation.

Note: This app has been tested on iOS 5 and iOS6. This app has not been tested or used with iOS 7.  Additionally, this app has not been submitted to the iTunes store for approval.
