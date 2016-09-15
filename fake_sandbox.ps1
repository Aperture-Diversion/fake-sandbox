# Simulate fake processes of analysis sandbox/VM  software that some malware will try to evade.
# This just spawns ping.exe with different names (wireshark.exe, vboxtray.exe, ...)
# 
# 
# *------------------------------------------------------------------------------------------------------------------*
# | This is the updated version with no CPU load at all. I will also add some more fake processes in future updates. |
# | Maintained by Phoenix1747, get updates and fixes on https://www.github.com/aperture-diversion/fake-sandbox/ .    |
# *------------------------------------------------------------------------------------------------------------------*
#
# Usage (CMD): Powershell.exe -executionpolicy remotesigned -File "C:\Full\Path\To\File\fake-sandbox.ps1" -action {start,stop}

param([Parameter(Mandatory=$true)][string]$action)

# Your processes come here:
$fakeProcesses = @("wireshark.exe", "vmacthlp.exe", "VBoxService.exe", "VBoxTray.exe", "procmon.exe", "ollydbg.exe", "vmware-tray.exe", "idag.exe", "ImmunityDebugger.exe")

# If you type in "start" it will run this:
if ($action -ceq "start") {
    # We will store our renamed binaries into a temp folder
    $tmpdir = [System.Guid]::NewGuid().ToString()
    $binloc = Join-path $env:temp $tmpdir

    # Creating temp folder
    New-Item -Type Directory -Path $binloc
    $oldpwd = $pwd
    Set-Location $binloc

    foreach ($proc in $fakeProcesses) {
        # Copy ping.exe and rename binary to fake one
        Copy-Item c:\windows\system32\ping.exe "$binloc\$proc"

        # Start infinite ping process (invalid ip) that pings every 3600000 ms (1 hour)
        Start-Process ".\$proc" -WindowStyle Hidden -ArgumentList "-t -w 3600000 -4 1.1.1.1"
        write-host "[+] Process $proc spawned"
    }

    Set-Location $oldpwd
	write-host ""
	write-host "Press any key to close..."
	cmd /c pause | out-null
}
# If you type in "stop" it will run this:
elseif ($action -ceq "stop") {
    write-host ""
	foreach ($proc in $fakeProcesses) {
        Stop-Process -processname "$proc".Split(".")[0]
        write-host "[+] Killed $proc"
    }
	write-host ""
	write-host "Press any key to close..."
	cmd /c pause | out-null
}
# Else print this:
else {
	write-host ""
    write-host "Bad usage: You need to use either 'start' or 'stop' for this to work!" -foregroundcolor Red
	write-host "Press any key to close..."
	cmd /c pause | out-null
	
}
