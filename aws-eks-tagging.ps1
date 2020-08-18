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
# This CmdLet is limited to tagged resource - if the resource has no tag ( at all ) its automatically filtered $EBSIdList = (Get-EC2Tag -Filter @{Name="resource-type";Values="volume"},@{Name="resource-id";Values=$ec2EBSList.VolumeId} | Get-Unique).ResourceId 

# List EC2 from CE List (All EC2 Created by CE Migration)
foreach ($ec2Looplist in $ec2list.InstanceId){
   try {
      $ErrorActionPreference = "Stop"
      $EC2TagsObject = (Get-EC2Tag -Filter @{Name="resource-type";Values="instance"},@{Name="resource-id";Values=$ec2looplist} -Verbose | Where Key -in "aws:migrationhub:source-id","map-migrated" )
      Write-Host $ec2looplist "is migrated with CE - looking for EBS"
      $ec2VolumeList = (Get-EC2Volume -Filter @{ Name="attachment.instance-id"; Values= $ec2looplist}).VolumeId
      foreach ($ebsLoop in $ec2VolumeList) {
         Write-Host $ebsLoop "found for instance:" $ec2Looplist "applying tags" $EC2TagsObject.Value $EC2TagsObject.Key
         New-EC2Tag -Resource $ebsLoop -Tag @{Key="map-migrated";Value=$EC2TagsObject.Value} -Verbose      
         Write-Host "Any snapshot or AMI ? Keep lookin"
         $ebsSnapList = (Get-EC2Snapshot -Filter @{Name="volume-id";Values=$ebsLoop})
         Write-Host "snapshots found for" $ebsLoop "-" $ebsSnapList.Count  "snapshots"
         foreach ($snapshot in $ebsSnapList.SnapshotId) {
            New-EC2Tag -Resource $snapshot -Tag @{Key="map-migrated";Value=$EC2TagsObject.Value} -Verbose      
         }        
      }
   }
   catch {
      Write-Error $_.Exception.Message
      Write-Error "No instance migrated with CloudEndure found (did you remoove the CloudEndure creation time log?"
   }
}