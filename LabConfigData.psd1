@{
    AllNodes = @(

        @{
            Nodename = "192.168.2.100"
            MachineName = 'DC'
            Role = "Primary DC"
            DomainName = "sva-dscdom.nttest.microsoft.com"
            PSDscAllowPlainTextPassword = $true
            IPAddress = '192.168.2.100'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.2.1'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '127.0.0.1', '192.168.2.100'
            RetryCount = 20 
            RetryIntervalSec = 30 
            PSDscAllowDomainUser = $true           
           
        },

        @{
            Nodename = "use IP or DNS if Possible"
            Role = "Replica DC"
            DomainName = "sva-dscdom.nttest.microsoft.com"
            PSDscAllowPlainTextPassword = $true
            IPAddress = '192.168.2.100'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.2.1'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '127.0.0.1', '192.168.2.100'
            RetryCount = 20 
            RetryIntervalSec = 30 
            PSDscAllowDomainUser = $true           
            
        }
    )
}
