configuration ADF             
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
            DependsOn ='[WindowsFeature]ADDSInstall'           
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
 		    DomainName = "$Node.DomainName"
 		    UserName  = "admantonio"
 		    DependsOn = "[xADDomain]FirstDS"
 		    DisplayName = "Antonio Cheltenham"
 		    Enabled     = $true
 		    Ensure      = "Present"
 		    GivenName   = "Antonio"
 		    Surname     = "Cheltenham"
 	    }
 
        
    }           
}            
                     
            
ADFS -configurationData $ConfigData `
    -safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
        -Message "New Domain Safe Mode Administrator Password") `
    -domainCred (Get-Credential -UserName cheltenham\administrator `
        -Message "New Domain Admin Credential") `
    -NewADUserCred (Get-Credential -UserName '(Password Only)' `
        -Message "New User Password")               
            
# Make sure that LCM is set to continue configuration after reboot            
#Set-DSCLocalConfigurationManager -Path .\NewDomain –Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Credential localhost\administrator -Path .\ADFS -Verbose           
