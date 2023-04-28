function New-ShortLink {

    [cmdletbinding(DefaultParameterSetName = 'all')]

    param(
        [string]
        $url,
        [string]$Slashtag,
        [string]$title = $url
    )

    $api_key = "71211243754b4449a8856830ce89bd16"

    $headers = @{}
    $headers.add("accept", "application/json")
    $headers.add("content-type", "application/json")
    $headers.add("apikey", $api_key)


    $postParamz = @{domain = @{
            fullName = "dereks.info" 
        }
        destination        = $url
        title              = $title 
        slashtag           = $slashtag 
    }

    $body = $postParamz | ConvertTo-Json

    $response = Invoke-WebRequest -uri "https://api.rebrandly.com/v1/links" -Method POST -Headers $headers -ContentType 'application/json' -Body $body
    return $response.Content | convertfrom-json
}

