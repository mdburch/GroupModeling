GroupModeling
=============

This iOS application allows users to create causal loop diagram models using system dynamics concepts.  This app was designed as a method for Group Model Building. Please view the README_Files folder for information on how data stored in the Parse database is set up what metrics I gather.  More information on the Python scripts can be found in the PythonScripts folder.


In order to use the app you will need the following accounts:

<b>Parse (http://parse.com)</b>
  <ul>
    <li>An AppID ClientKey and REST API Key will be created that will be used in the AppDelegate and the provided Python files.</li>
    <li>This is used to store metrics on events that occur when a user is interacting with the user interface.</li>
    <li>This comes in handy if you intend on using the Python scripts provided in this repo. (https://parse.com/docs/rest)</li>
    <li>For more information on how to set this up visit https://parse.com/apps/quickstart . </li>
  </ul>
  

<b>Dropbox Chooser (https://www.dropbox.com/developers/dropins/chooser/ios)</b>
  <ul>
    <li>Dropbox chooser will give you a url-scheme that you will need to update in your Project Navigator.</li>
    <li>This is used to access a user's Dropbox account to open up saved files. </li>
    <li>Saving files to Dropbox is used through a UIDocumentInteractionController as the Dropbox Saver had not been implemented at the time of implementation.</li>
  </ul>

Note: This app has been tested on iOS 5 and iOS6. This app has not been tested or used with iOS 7.  Additionally, this app has not been submitted to the iTunes store for approval.

Please view the license before using this code. The only code not authored by Matt Burch (mdburch) is the MFSideMenu which can be used in accordance with the licese found here (https://github.com/mikefrederick/MFSideMenu).  
