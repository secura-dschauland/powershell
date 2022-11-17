function unlock-ismail {
    # Pass unlock to unlock the ad account - without it, the function just checks to see
    param(
        [Parameter()]
        [switch]
        $unlock
    )

    if((get-aduser -filter * -properties lockedout | where{$_.name -match "ismail al bulushi - admin"} | select givenname, surname, lockedout).lockedout -eq "True" -and $unlock)
    {   
        if(get-childitem -Path c:\users\de03930 | where{$_.Name -eq "cred.xml"})
        {
            (get-aduser -filter * -properties lockedout | where{$_.name -match "ismail al bulushi - admin"})| Unlock-ADAccount -Credential (Import-Clixml C:\users\de03930\cred.xml)

            "Ismail has been unlocked as of $(get-date) here is proof: $(get-aduser -filter * -properties lockedout | where{$_.name -match "ismail al bulushi - admin"} | select samaccountname, givenname, surname, lockedout)"
        }
        else{
             "You do not have a cred available to use this powershell... sorry."
        }

    }
    elseif((get-aduser -filter * -properties lockedout | where{$_.name -match "ismail al bulushi - admin"}).lockedout)
    {
        "You didnt specify to unlock :) - Ismail's 9ID is locked as of $(get-date)"
        get-aduser -Filter * -Properties lockedout | where {$_.name -match "ismail al bulushi - admin"}| select samaccountname, surname, givenname, lockedout
    }
    else {
        "Current Status: Unlocked! as of $(get-date)"
        get-aduser -filter * -properties lockedout | where{$_.name -match "ismail al bulushi - admin"} | select samaccountname, givenname, surname, lockedout
    }
        
}

# make this worko
#get-aduser -filter * -Properties lockedout | where {$_.name -match "al bulushi - admin"} |Unlock-ADAccount -Credential (Import-Clixml C:\users\de03930\cred.xml)