# sign-ps-script
Script for creating a new cert on your local Windows machine and, with it, signing another script you wish to safely run within *All-Signed* restrictions. 

NOTE: Credit goes to [Adam the Automator](https://adamtheautomator.com/how-to-sign-powershell-script/){:target="_blank"} for the code that creates the self-signed cert, adding it to cert stores, testing the additions, and signing the input script.  

The premise is that Windows systems are by-default protected from external or internal malicious script execution with safeguard [Windows execution policies](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.3){:target="_blank"}, such as *All-Signed* or *Remote-Signed* - the aforementioned allowing only signed scripts to run on your machine. If you have a script you need to run on your system without potentially dangerous modifications to your execution policies (i.e. system-wide-allowing all scripts to run without restriction via ```Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine```), you can run this script to create a self-signed certificate in your machine to authenticate (sign) your local scripts to run safely. 

This helper script takes care of installing the certificate, checking its expiration, and signing your desired script. 

Once you download this helper script onto your Windows machine, you'd have to initially bypass the first run by following a few steps: 
1. Start a new PowerShell session as Administrator. 
2. Copy the following into your cmd line: ```Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process```. This ensures only the current PowerShell session is unrestricted to bypass the first helper script run to get the cert installed. 
3. Confirm "Yes". 
4. In this session, run the helper script with the user-prompted file path being the helper script. 
5. Exit the session. 

If successful, you should have some copies of the certificate ```ATA Authenticode``` installed in your "Local Computer" cert store. In addition, your helper script should now contain a digital signature at the end of the file. 

Just run this now-authorized helper script against any unsigned script. 

NOTE: if you modify a script after it's signed, just re-run the helper against the modified to re-sign it. It won't work otherwise. 
