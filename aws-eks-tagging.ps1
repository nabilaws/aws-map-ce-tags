#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.0.6.0'}
#Requires -Module AWS.Tools.EC2, AWS.Tools.AutoScaling, AWS.Tools.EKS
#1: Sync your CloudEndure Tagging and EC2/EBS 
$ec2list = (Get-EC2Instance -Filter @{Name="tag-key";Values="CloudEndure creation time"}).Instances
$CEServicesList =  (Get-EC2Instance -Filter @{Name="tag-key";Values="CloudEndure_Replication_Service"}).Instances

#Retrieve linked EBS 
$ec2EBSList = (Get-EC2Volume -Filter @{ Name="attachment.instance-id"; Values=$ec2list.InstanceId })
$CEServicesEBSList = (Get-EC2Volume -Filter @{ Name="attachment.instance-id"; Values=$CEServicesList.InstanceId })

#Check tags for each resource type
# -Filter @{Name="resource-type";Values="volume"},@{Name="resource-id";Values=$ec2EBSList.VolumeId}

# List EBS from CE List (All EBS Created by CE Migration)

$EBSIdList = (Get-EC2Tag -Filter @{Name="resource-type";Values="volume"},@{Name="resource-id";Values=$ec2EBSList.VolumeId} | Get-Unique).ResourceId
Write-Host "List of EBS Volumes linked to" $EBSIdList



# List EC2 from CE List (All EC2 Created by CE Migration)

$EC2TagsObject = (Get-EC2Tag -Filter @{Name="resource-type";Values="instance"},@{Name="resource-id";Values=$ec2list.InstanceId} | Where-Object Key -eq "aws:migrationhub:source-id")

foreach ($Targets in $EC2TagsObject){
   (Get-EC2Volume -Filter @{ Name="attachment.instance-id"; Values= $Targets.ResourceId })
   Write-Host $Targets.Key "with value" $Targets.Value "for" $Targets.ResourceId 
   New-EC2Tag -Resource $Targets.ResourceId -Tag @{Key=$Targets.Key;Value=$Targets.Value} -Verbose   
}

#Tag name must be map-migrated cannot re-use the aws:migrationhub:source-id (Service usage limited)