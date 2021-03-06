Param($Environment=$null,

    [parameter(Mandatory=$false)]               
    [ValidateNotNullOrEmpty()]    
    [String] $BuildFilePath = "..")

###$ErrorActionPreference ="Stop"
$CURRENTDIR=pwd
"current directory is $CURRENTDIR"
trap {write-host "error"+ $error[0].ToString() + $error[0].InvocationInfo.PositionMessage  -Foregroundcolor Red; cd "$CURRENTDIR"; read-host 'There has been an error'; break}
#REMOVE
#$Environment="developmentVM"
if ($CURRENTDIR -eq "C:\Windows\system32")
{
    cd c:\svc\shared\trunk\scripts
}

$DeploymentFile="$Global_ManifestFile"
If (test-path $DeploymentFile) 
{

    $xml = [xml](get-content $DeploymentFile)
    Write-Host "deployment file found"
    If($Environment -eq $null)
    {
        
        Write-Host "No Environment passed in"
        "Enrironment not passed in, ask the user"
        
        $Environment =& Get-EnvironmentFromUser $xml
    }
    $K2EnvironmentLibrary= $Environment
	"==================$K2EnvironmentLibrary"
    $K2Host= $xml.environments.$Environment.K2Host
    $K2HostPort= $xml.environments.$Environment.K2HostPort      
    
    
}
else
{
    IF($K2Host -eq $null){$K2Host= Read-Host "What is the k2server name? Leave blank to use default of 'localhost'"}
    If($K2EnvironmentLibrary -eq $null) {$K2EnvironmentLibrary = Read-Host "What is the K2 Environment Library? Leave blank to use default of 'Development'"}
    IF($K2HostPort  -eq $null) {$K2HostPort=Read-Host "What is the host port for k2 server host? Leave blank to use default of '5555'"}
}

###If(!$Global_MsbuildPathSMO) {$Global_MsbuildPathSMO="$BuildFilePath\K2\SmO\obj\Debug\Deployment\PostScanning.SmO.msbuild"}
If(!$MsbuildPathSMO) {$MsbuildPathSMO= resolve-path "$BuildFilePath\Deployment\SmO\K2DeploymentPackage.msbuild"}
If(!$MsbuildPathWF) {$MsbuildPathWF= resolve-path "$BuildFilePath\Deployment\WF\K2DeploymentPackage.msbuild"}
IF($K2Host -eq $null){$K2Host="localhost"}
IF($K2HostPort  -eq $null) {$K2HostPort="5555"}
IF($K2EnvironmentLibrary -eq $null) {$K2EnvironmentLibrary="IsoDev"}

###Wait util the server is up
Test-K2Server

#Copy-Item ".\K2 ServiceBroker Deployment Utility\MSBuild Folder\*" $Global_MsbuildPath -recurse -force -EA "Continue"
"****************************************************"
& $Global_FrameworkPath35\MSBUILD $MsbuildPathSMO /p:Environment=$K2EnvironmentLibrary
###& c:\WINDOWS\Microsoft.NET\Framework64\v3.5\MSBUILD $MsbuildPathSMO /p:Environment=$K2EnvironmentLibrary
& $Global_FrameworkPath35\MSBUILD $MsbuildPathWF /p:Environment=$K2EnvironmentLibrary

$message= "======Finished Deploying K2 packages for SmO and WF======"
If($DoNotStop){Write-Host $message} else {Read-Host $message}
