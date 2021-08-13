rem Howlers Server Startup Script (training server) v 1.2
rem always run as admin or it will not have proper control over the ports
rem dependencies (as written, those with * can be removed by removing lines below):
rem Open Beta Server for DCS
rem SRS server * 
rem Discord *
rem Discord Send Webhook *
rem Tacview locally installed *
rem a Google Drive Local mirror on the server (could also be a dropbox) *

@echo off
rem you will need to setup your own discord webhooks (or rem the webhook lines below
rem ours are all named after squadron dogs
set benWebHook="https://discordapp.com/api/INSERTBENWEBHOOKHERE"
set ollieWebHook="https://discordapp.com/api/INSERTOLLIEWEBHOOKHERE"
set daisyWebHook="https://discordapp.com/api/INSERTDAISYWEBHOOKHERE"
set delaytime_1=13800
set delaytime_2=600
:looptop
cls
rem copy mission scripting file - need to figure out how to do this as admin
rem copies uses a desanitized version of the mission scripting file to make sure that it doesn't revert during a DCS update
del "C:\Program Files\Eagle Dynamics\DCS World OpenBeta Server\Scripts\MissionScripting.lua"
rem change this path to wherever you want to keep such a file
copy C:\Users\mtill\Documents\HowlerServerScripts\MissionScripting.lua "C:\Program Files\Eagle Dynamics\DCS World OpenBeta Server\Scripts"
rem shut down ports (per Hoggit recommendation about server crashes when players connect too soon)
echo Beginning restart
netsh advfirewall firewall delete rule name = "Port 10308 TCP" dir=in protocol=TCP localport=10308
netsh advfirewall firewall delete rule name = "Port 10308 UDP" dir=in protocol=UDP localport=10308
echo Ports disabled
rem start SRS and DCS
start "" "C:\Program Files (x86)\SRS\SR-Server.exe"
timeout /t 10 /nobreak
start "" "C:\Program Files\Eagle Dynamics\DCS World OpenBeta Server\bin\DCS_updater.exe"
timeout /t 60 
netsh advfirewall firewall add rule name = "Port 10308 TCP" dir=in action=allow protocol=TCP localport=10308
netsh advfirewall firewall add rule name = "Port 10308 UDP" dir=in action=allow protocol=UDP localport=10308
echo DCS ports enabled
timeout /t 10
start "" "C:\Program Files\DiscordSendWebhook\DiscordSendWebhook.exe" -m "Server is available." -w %benWebHook%
cls 
rem wait until timer is up to restart
set mytime=%time%
echo Last restart at %mytime%
timeout /t %delaytime_1%
rem send message to discord that server is restarting in 10 minutes
start "" "C:\Program Files\DiscordSendWebhook\DiscordSendWebhook.exe" -m "Server is restarting in 10 minutes." -w %benWebHook%
timeout /t %delaytime_2%
cls
rem server and port kill
echo Restarting
start "" "C:\Program Files\DiscordSendWebhook\DiscordSendWebhook.exe" -m "Restarting server." -w %benWebHook%
taskkill /IM "DCS.exe" /F
taskkill /IM "SR-Server.exe" /F
echo DCS and SRS Terminated
netsh advfirewall firewall delete rule name = "Port 10308 TCP" dir=in protocol=TCP localport=10308
netsh advfirewall firewall delete rule name = "Port 10308 UDP" dir=in protocol=UDP localport=10308
echo Ports Disabled
timeout /t 30 /nobreak
rem tacview data processing
for /f %%f in ('dir /b C:\Users\mtill\Documents\Tacview') do (
echo Exporting flight log for [%%f]...
"C:\Program Files (x86)\Tacview\Tacview.exe" -Open:"C:\Users\mtill\Documents\Tacview\%%f" -ExportFlightLog:"C:\Users\mtill\Documents\Tacview\%%f.csv" -Quiet -Quit
timeout /t 5 /nobreak
copy C:\Users\mtill\Documents\Tacview\%%f.csv "C:\Users\mtill\Documents\All Event Logs"
move C:\Users\mtill\Documents\Tacview\*.csv "C:\Users\mtill\Google Drive\VFA469\Tacview Files"
move C:\Users\mtill\Documents\Tacview\*.zip.acmi "C:\Users\mtill\Google Drive\VFA469\Tacview Files"
del C:\\Users\mtill\Documents\Tacview\*.*
forfiles /p "C:\Users\mtill\Google Drive\VFA469\Tacview Files"  /m *.*  /c "cmd /c del @path" /d -5
rem message to discord that tacview has uploaded
start "" "C:\Program Files\DiscordSendWebhook\DiscordSendWebhook.exe" -m "The TacView recording and Event Log from the previous training session have been moved to the Google Drive folder.  Files will be deleted in 4 days." -w %ollieWebHook%
goto :looptop