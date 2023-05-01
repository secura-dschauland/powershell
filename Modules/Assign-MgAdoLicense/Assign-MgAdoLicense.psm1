# this script will assign users to groups in Azure AD that give them licensing for ADO :D
function Assign-MgAdoLicense {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $UserNames,
        [Parameter(parametersetname = 'ado',
            helpMessage = "Use the -basic switch to add a user to the group for a basic ADO license")]
        [switch]
        $Basic,
        [Parameter(parametersetname = 'ado',
            helpMessage = "Use the -visualstudio switch to add a user to the group for a VisualStudio ADO license")]
        [switch]
        $VisualStudio,
        [Parameter(parametersetname = 'ado',
            helpMessage = "Use the -testplans switch to add a user to the group for a basic+testplans ADO license")]
        [switch]
        $TestPlans,
        [Parameter(parametersetname = 'ado',
            helpMessage = "Use the -stakeholder switch to add a user to the group for a stakeholder ADO license")]
        [switch]
        $Stakeholder,
        [Parameter(parametersetname = 'ado',
            helpMessage = "Use the -useAdmins switch to add a users admin ID to the group specified for an ADO license")]
        [switch]
        $useAdmins
    )
    
    begin {
        # if ( get-module -listavailable -name Connect-DSGraph) {
        if (!($(get-date) -gt $env:TokenDate) -and -not([string]::IsNullOrEmpty($env:Tokendate))) {
            write-verbose "The current Date $(Get-date) is less than the last Token Date $env:tokendate - token valid"
            write-verbose "Proceeding... graph Auth Completed"
            
        }
        else {
            write-verbose "The Current Date $(get-date) is greater than the last token date $env:tokendate - token invalid"
            write-verbose "Check for module - if not installed... install it, then reset the Env Var"
            if ($null = get-module -ListAvailable -name Connect-DSGraph) {
                Import-Module Connect-DSGraph
                $env:TokenDate = ""
                Connect-DSGraph
            }
            else {
                Connect-DSGraph
            }
        }

        #}
        #else {
            
        #    import-module Connect-DSGraph
        #}
        

        $mggroups = get-mggroup -all 
        $StakeholderGroup = $mggroups | where { $_.Displayname -match "DevOps-StakeHolder" }
        $BasicGroup = $mggroups | where { $_.Displayname -match "DevOps-Basic" -and $_.DisplayName -ne "G-ACS-Azure-Devops-Basic+TestPlans" }
        $VisualStudioGroup = $mggroups | where { $_.Displayname -match "DevOps-VisualStudio" }
        $Basic_TestGroup = $mggroups | where { $_.Displayname -match "TestPlans" }           
        
    }
    
    process {
        foreach ($username in $usernames) {
            $usermsg = [string]$username
            write-verbose "Getting Azure AD Object ID for $usermsg - please hold." 
        }

        $userObj = @()

        if (!($useAdmins)) {
            foreach ($user in $usernames) {
                $userObj += (get-mguser -all | where-object { $_.DisplayName -match $user -and $_.displayname -notmatch "Admin" })
            }            
        }
        else {
            foreach ($user in $usernames) {
                $userObj += (get-mguser -all | where-object { $_.DisplayName -match $user -and $_.displayname -match "Admin" })
            }   
        }

        if ($Basic) {
            $group = $BasicGroup
        }
        elseif ($TestPlans) {
            $group = $Basic_TestGroup
        }
        elseif ($VisualStudio) {
            $group = $VisualStudioGroup
        }
        elseif ($Stakeholder) {
            $group = $StakeholderGroup
        }
        else {
            write-host "No selection for an ADO License group was made: valid switch options are -Basic, -TestPLans, -VisualStudio, -Stakeholder."
        }

        foreach ($obj in $userObj) {
            write-verbose "Check if $($obj.displayname) exists in $($group.displayname) using $($obj.id)"
            $allMembers = get-mggroupmember -groupid $group.id -all 

            if (!($($obj.id) -in $allMembers.id)) {
                write-verbose "Will Add $($obj.displayname) to $($group.displayname) using $($obj.id)"
                new-mggroupmember -groupid $($group.id) -DirectoryObjectiD $($obj.id)
                write-verbose "User Added to $($group.displayname)"
            } 
            else {
                write-verbose "User Object already exists in this group"
                continue
            }
            
        }

    }
    
    end {
        
    }
}