function Get-LocalAdmins {
    [CmdletBinding()]
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $ComputerName,
        [Parameter()]
        [pscredential]
        $Credential = (import-clixml C:\users\de03930\cred.xml),
        [Parameter()]
        [switch]
        $listgroups
    )
    #Test with Get-LocalAdmins -ComputerName az-dci-d01.intranet.secura.net
    begin {
        if((get-wmiobject -class win32_computersystem).partofdomain -eq "True")
        {
            write-host "$"
            foreach($computer in $computername)
            {
                if((Test-NetConnection $computer -InformationLevel Quiet) -eq "True")
                {
                    write-host "Computer $computer is reachable via ping." -ForegroundColor Green
                }
                else {
                    write-host "Computer $computer is not reachable via ping." -ForegroundColor Red 
                }
            }
    
        }
    }
    
    process {
        if($listgroups)
        {
            Invoke-Command -ScriptBlock {Get-LocalGroupMember administrators} -ComputerName $computername -Credential $Credential | select-object PSComputerName, Name, SID, PrincipalSource | ft
        }
        else {
            foreach($computer in $computername)
            {
                $group = (Invoke-Command -ScriptBlock {Get-LocalGroupMember administrators} -ComputerName $computername -Credential $Credential | select-object PSComputerName, Name, SID, PrincipalSource)
                
                $adgroup = ($group | Where-Object {$_.name -match "G-"})

                $adgroup2 = [string]($adgroup.name).trimstart("SECURA-AD\")

                $groups = $adgroup2.Split(" ")

                foreach($g in $groups)
                {
                   
                    write-host "$g has the following members: `n============================================="
                    (get-adgroup $g) | Get-ADGroupMember | select name, samaccountname | ft
                    
                    
                }

            }
            

        }
    }
    
    end {
        
    }
}