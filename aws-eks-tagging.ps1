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

Get-EC2Tag -Filter @{Name="resource-type";Values="volume"},@{Name="resource-id";Values=$ec2EBSList.VolumeId}

foreach ($EBS in $CEServicesEBSList){

   Get-EC2Volume -VolumeId $EBS.VolumeId
}


Get-EC2Tag -Filter @{Name="resource-type";Value="image"}