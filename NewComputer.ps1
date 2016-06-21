Configuration NewComputer
{
 Import-DscResource -ModuleName xComputerManagement, xNetworking, PSDesiredStateConfiguration           
            
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename   

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



    }
}

## Load the Node Config into a Variable
$config = Invoke-Expression (Get-content .\LabConfigData.psd1 -Raw)  
## Create .mof file with Config data as variable defined 
NewComputer -configurationData $config

## Push the configuration if #DNS is not set up use IP Address 
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "DC1" -Path .\AssertHADC -Credential 



 	
