configuration InstallPKG {
    
    Import-DscResource -ModuleName cChoco  
    
    Node $ComputerName {

       cChocoInstaller installChoco
      {
        InstallDir = "c:\choco"
      }

        cChocoPackageInstaller installChrome
      {
        Name = "googlechrome"
        DependsOn = "[cChocoInstaller]installChoco"
        Source = "https://chocolatey.org/api/v2/"
        Version = "50.0.2661.94"
      }
    }
}
$computername = '192.168.2.59'
InstallPKG -OutputPath .\Documents\Powershell\LABBuild

Start-DscConfiguration -Path .\Documents\Powershell\LABBuild -ComputerName $computername -Verbose -Wait -Force -Credential cheltenham\administrator
