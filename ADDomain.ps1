configuration ADDomain             
{             
   param             
    (             
        [Parameter(Mandatory)]             
        [pscredential]$safemodeAdministratorCred,             
        [Parameter(Mandatory)]            
        [pscredential]$domainCred
        
                 
    )             
            
    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement, xNetworking, PSDesiredStateConfiguration, xRemoteDesktopAdmin, cChoco          
            
    Node $AllNodes.Where{$_.Role -eq "HADC"}.Nodename             
    {             
                        
        xComputer SetName { 
          Name = $Node.MachineName 
        }
        xIPAddress SetIP {
            IPAddress = $Node.IPAddress
            InterfaceAlias = $Node.InterfaceAlias
            SubnetMask = $Node.SubnetMask
            AddressFamily = $Node.AddressFamily
        }

        XDefaultGatewayAddress SetGateway {
           
           AddressFamily = $Node.AddressFamily
           InterfaceAlias = $Node.InterfaceAlias
           Address = $Node.DefaultGateway
          
        }

        xDNSServerAddress SetDNS {
            Address = $Node.DNSAddress
            InterfaceAlias = $Node.InterfaceAlias
            AddressFamily = $Node.AddressFamily
        }                    
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"             
        }            
            
        # Optional GUI tools            
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }            

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domaincred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        # No slash at end of folder paths            
        xADDomainController SecondDC             
        {             
            DomainName = $Node.DomainName            
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $safemodeAdministratorCred                   
            DependsOn ='[xComputer]SetName', '[xIPAddress]SetIP', '[WindowsFeature]ADDSInstall'           
        }            
       
        xRemoteDesktopAdmin RDP
       
        {
            Ensure = "Present"
            DependsOn = '[xADDomainController]SecondDC'
            UserAuthentication = 'Secure'
        } 
        
        xFirewall AllowRDP
        {
            Name = 'DSC - Remote Desktop Admin Connections'
            Group = "Remote Desktop"
            Ensure = 'Present'
            Enabled = 'True'
            Action = 'Allow'
            Profile = 'Domain','Private'
        }

        ### To install Chrome                  
       cChocoPackageInstaller installChrome
      
      {
        Name = "install googlechrome"
        DependsOn = "[cChocoInstaller]installChoco"
      }

        }
}
        # Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = "192.168.2.59"
            MachineName = 'DC2'             
            Role = "HADC"             
            DomainName = "cheltenham.com"
            IPAddress = '192.168.2.59'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.2.1'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '192.168.2.100', '192.168.2.59'             
            RetryCount = 20              
            RetryIntervalSec = 30 
            PSDscAllowDomainUser = $true           
            PsDscAllowPlainTextPassword = $true            
        }            
    )             
}             
            
ADDomain -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
        -Message "Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName cheltenham\administrator `
        -Message "Domain Admin Credential") 
   
            
# Make sure that LCM is set to continue configuration after reboot            
#Set-DSCLocalConfigurationManager -Path .\NewDomain –Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Credential cheltenham.com\administrator -Path .\ADDomain -Verbose     