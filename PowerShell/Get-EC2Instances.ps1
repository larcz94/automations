Import-Module -name AWSPowerShell.NetCore 
Import-Module -name AWSSSOHelper

function Get-AllCredentials {
    # Import the Required Modules
    return Get-AWSSSORoleCredential -StartUrl "https://url.com/start#/" -AllAccountRoles | Select-Object AccessKey, SecretKey, SessionToken, AccountName, AccountID
}

function Get-InstanceName {
param($instanceID, $awsprofile)
 
    $tags = (Get-EC2Instance -AccessKey $awsprofile.AccessKey -SecretKey $awsprofile.SecretKey -SessionToken $awsprofile.SessionToekn).RunningInstance | Where-Object {$_.instanceId -eq $instanceId} |select Tag
    $tagName = $tags.Tag | Where-Object {$_.Key -eq "Name"} | select -ExpandProperty Value
 
    return $tagName
}

function Get-AllEC2Instances {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]$awsprofile
    )
    begin {
        $region = 'us-east-1', 'us-west-2', 'ap-southeast-2', 'us-east-2', 'ap-southeast-1', 'eu-central-1'
    }
    
    process {
        foreach ($reg in $region)
        {
            # Names and Accounts are not in there
            (Get-EC2Instance -AccessKey $awsprofile.AccessKey -SecretKey $awsprofile.SecretKey -SessionToken $awsprofile.SessionToken -Region $reg).Instances | Select-Object @{ Name = 'AccountID'; Expression = {$awsprofile.AccountId}}, @{ Name = 'Name'; Expression = {Get-InstanceName -instanceID ($_.InstanceID) -awsprofile $awsprofile}}, InstanceID, InstanceType, Platform, PrivateIpAddress, PublicIpAddress, @{ Name = 'Region'; Expression = {$reg}}

        }
    }
    end {
    }
}


Set-DefaultAWSRegion -Region us-east-1
Get-AllCredentials | Get-AllEC2Instances | Export-CSV -Path .\EC2Export.csv -NoTypeInformation