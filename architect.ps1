<#
The ARCHITECT
script responsible for kicking off additional powershell scripts
for traffic gen

@khr0x40sh - http://khr0x40sh.wordpress.com
#>
Param(
$textfile = "sites.txt",
$min = 5,
$max = 15
);

if ($env:Processor_Architecture -ne "x86")   
{ write-warning 'Launching x86 PowerShell'
&"$env:windir\syswow64\windowspowershell\v1.0\powershell.exe" -exec bypass -noninteractive -noprofile -file $myinvocation.Mycommand.path 
exit
}

$PSSCriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
function ConvertTo-UnixTimestamp {
	$epoch = Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0	
 	$input | % {		
		$milliSeconds = [math]::truncate($_.ToUniversalTime().Subtract($epoch).TotalSeconds)
		Write-Output $milliSeconds
	}	
}
function randomInt {
Param(
$small = 0,
$large = 100
);
    $seed = Get-date | ConvertTo-UnixTimestamp
    $rand = new-object System.Random $seed
    $out = $rand.Next($small, $large)
    
    $out
}

$sites = Get-content $textfile
$proc = 0 
while ($true)
{
    $r2 = randomInt 0 $sites.Count+1
    
    Write-Host $sites[$r2]
    
    ####################
    #read page coinflip
    $coin = randomInt 0 5
    
    if ($coin -gt 1)
    {
        $click = $true
        #click through is true, no dwell on page
    }
    ####################
    
    
    #get-Sleep times
    $slp = randomInt $min $max
    $cmd = $PSScriptPath.ToString() + "\PowerSurfer.ps1"
    
    & $cmd $sites[$r2] 3 1
   
    #PowerSurfer $sites[$r2] 3 1
    
    if ($proc -gt 3)
    {
        Stop-process -Force -processname iexplore
        $proc = 0
    }
    
    Start-Sleep $slp
    $proc++
}