##DSC LCM Push Configuration

 [DSCLocalConfigurationManager ()]
Configuration LCMPUSH
{      
        Node $Computername
       {
               SEttings
              {
                     AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
                     RefreshMode = 'Push'
            RebootNodeIfNeeded = $True   
              }
       }
}

$Computername = '192.168.2.59'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath c:\DSC\LCM

Set-DscLocalConfigurationManager -Computername $computername -Path c:\DSC\LCM -credential localhost\administrator -verbose 