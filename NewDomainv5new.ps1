configuration NewDomain             
{             
   param             
    (             
        [Parameter(Mandatory)]             
        [pscredential]$safemodeAdministratorCred,             
        [Parameter(Mandatory)]            
        [pscredential]$domainCred,
        [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
                 
    )             
            
    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement, xNetworking, PSDesiredStateConfiguration, xRemoteDesktopAdmin           
            
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename             
    {             
                        
        xComputer SetName { 
          Name = $Node.MachineName 
        }
        xIPAddress SetIP {
            IPAddress = $Node.IPAddress
            InterfaceAlias = $Node.InterfaceAlias
            #DefaultGatewayAddress = $Node.DefaultGateway
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
            
        # No slash at end of folder paths            
        xADDomain FirstDS             
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $safemodeAdministratorCred                   
            DependsOn ='[xComputer]SetName', '[xIPAddress]SetIP', '[WindowsFeature]ADDSInstall'           
        }            
        xRemoteDesktopAdmin RDP
       
        {
            Ensure = "Present"
            DependsOn = '[xADDomain]FirstDS'
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

        xADUser FirstUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            UserName = "Penelope"
            Password = $NewADUserCred
            Ensure = "Present"
            DependsOn = "[xADDomain]FirstDS"
         }

    }           
}            
            
# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = "192.168.2.100"
            MachineName = 'DC'             
            Role = "Primary DC"             
            DomainName = "cheltenham.com"
            IPAddress = '192.168.2.100'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.2.1'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '127.0.0.1', '192.168.2.100'             
            RetryCount = 20              
            RetryIntervalSec = 30 
            PSDscAllowDomainUser = $true           
            PsDscAllowPlainTextPassword = $true            
        }            
    )             
}             
            
NewDomain -ConfigurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
        -Message "New Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName cheltenham\administrator `
        -Message "New Domain Admin Credential") `
    -NewADUserCred (Get-Credential -UserName '(Password Only)' `
        -Message "New User Password")               
            
# Make sure that LCM is set to continue configuration after reboot            
#Set-DSCLocalConfigurationManager -Path .\NewDomain –Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Credential localhost\administrator -Path .\NewDomain -Verbose           
