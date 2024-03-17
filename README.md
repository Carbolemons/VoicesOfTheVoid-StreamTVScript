# Twitch Livestream -> VotV TV

This is a little finicky but requires low effort to get livestreams on the TV. 
Scripts for Linux (BASH) and (Powershell)
Script for Windows (Powershell)

## **Requirements**
Windows or Linux, does not matter. What does matter. You need to install [`ffmpeg`](https://ffmpeg.org/) so it can be used by the command line environment 


## **How To**
Place the script file `livestream.ps1` in your `/AppData/Local/VotV/Assets/tv` folder
Remove all other `.mp4` files from this folder
 - Open the script file, and edit the `URL=` variable to whichever twitch livestreamer you like
 - Open Voices of the Void and Load into a save
 - Open and refresh the TV
 - Set the TV to `Sequence`
 - Shift + Right click in the `/AppData/Local/VotV/Assets/tv` folder
	 - Open in Powershell
    - `./livestream` in the powershell terminal
 - Wait 60 seconds, and then play `stream001.mp4`
 - Enjoy :)
       
## **What it does/How it works**
Voices of the void will _not_ automatically refresh the television, nor the file that is currently being played. 
The game also hates when the current file it's playing gets overwritten

So: I capture 30 seconds of stream, save it to an mp4, kick off a job to reencode the capturing so there isnt any junk whilst capturing the next 30 seconds
I write these segments to the tv folder, and then it continuously updates these segements as you watch the stream. 

When voices of the void gets back in the playlist, it will re-read the file - thus, uninterrupted broadcast
