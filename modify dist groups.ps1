# takes a text file of the distribution groups a user should be a member of, 
# compares this list to the current groups the user belongs to, and changes membership accordingly 

# get current distribution group and desired distribution group lists and compare them
$user = Read-Host "Enter the email address of the mailbox: "
$AllGroups = Get-DistributionGroup | ? {$_.PrimarySmtpAddress -contains "$user"} | Select-Object -Property Name
$ref = "current.csv"
Out-File -FilePath .\$ref -InputObject $AllGroups
$diff = Read-Host "What is the file name of the new distribution group list: "
$differences = Compare-Object -ReferenceObject (Get-Content -Path .\$ref) -DifferenceObject (Get-Content -Path .\$diff)

# script blocks to remove and add groups
$RemoveFromGroup = {Remove-DistributionGroupMember -Identity ($differences[$i].InputObject).ToString() -Member $user -BypassSecurityGroupManagerCheck -Confirm:$false}
$AddToGroup = $RemoveFromGroup -replace "Remove", "Add"

# remove or add group based on each difference between the lists
for ($i = 0; $i -lt $differences.Count; $i++) {
    if($differences[$i].SideIndicator -eq "<="){
        Write-Host "removed from: " $differences[$i].InputObject;
        &$RemoveFromGroup
        
        }
    else {
        Write-Host "added to: " $differences[$i].InputObject;
        &$AddToGroup
        }
}