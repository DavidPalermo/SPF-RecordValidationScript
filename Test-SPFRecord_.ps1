
function Main
{
#SPF Record variables
$SPFDomain = 'healthwise.org'
$counter = 0
$SPFList = New-Object System.Collections.ArrayList
$SPFList = (Resolve-DnsName $SPFDomain -Type TXT -Server 8.8.8.8).strings.Split(" ")| where{$_ -like 'include:*'} | foreach-object -process { $_.Replace('include:','')} 
$SPFCharCount = (Resolve-DnsName $SPFDomain -Type TXT -Server 8.8.8.8).strings.ToCharArray().count

#Mail variables
$MailTo = 'name@healthwise.org'
$MailFrom = 'SPFCheck@healthwise.org'
$SMTPServer = 'smtp.healthwise.org'

$SPFList = Get-SPFs -SPFList $SPFList                           

#Send email with results
if (($SPFList.count -gt 9) -or ($SPFCharCount -ge 400))  
{
    Send-MailMessage 
    #Maybe use this throw to only send email from the catch
    #or maybe make a Send-Email method... 
    #Throw "There are more than 9 SPF Record.`nTotal number of SPF records found: $SPFList.Count"
}

Write-Host "SPF List (Sorted Ascending):" 
$SPFList | Sort-Object
Write-Host "`nNumber of SPFs found: " $SPFList.count
Write-Host "Characters in the first level SPF search: " $SPFCharCount 
}

function Get-SPFs
{
param($SPFList)
    do
    {
        $SPFList += (Resolve-DnsName $SPFList[$counter++] -Type TXT).strings.Split(" ") | where{$_ -like 'include:*'} | foreach-object -process { $_.Replace('include:','')} 
    }while ($counter -lt $SPFList.count)
    return $SPFList
}


try
{
    Main
}
catch
{
    Write-Warning ("An error occured: $_") 
    #Send email or call Send-Email method...
}
