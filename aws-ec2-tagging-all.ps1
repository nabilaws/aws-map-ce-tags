#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.0.6.0'}
#Requires -Module AWS.Tools.EC2
$ErrorActionPreference = "Continue"
#1: Sync your ALL your EC2 Instances tagbs with EC2/EBS/SNAPSHOTS/AMI
$ec2list = (Get-EC2Instance -Filter @{Name="tag-key";Values="CloudEndure creation time"}).Instances
foreach ($ec2Looplist in $ec2list.InstanceId){
   try {
      $ErrorActionPreference = "Stop"
      $EC2TagsObject = (Get-EC2Tag -Filter @{Name="resource-type";Values="instance"},@{Name="resource-id";Values=$ec2looplist} -Verbose | Where Key -in "aws:migrationhub:source-id","map-migrated" )
      Write-Host $ec2looplist "is migrated with CE - looking for EBS"
      $ec2VolumeList = (Get-EC2Volume -Filter @{ Name="attachment.instance-id"; Values= $ec2looplist}).VolumeId
      foreach ($ebsLoop in $ec2VolumeList) {
         Write-Host $ebsLoop "found for instance:" $ec2Looplist "applying tags" $EC2TagsObject.Value $EC2TagsObject.Key
         New-EC2Tag -Resource $ebsLoop -Tag @{Key="map-migrated";Value=$EC2TagsObject.Value} -Verbose      
         $ebsSnapList = (Get-EC2Snapshot -Filter @{Name="volume-id";Values=$ebsLoop})
         Write-Host "snapshots found for" $ebsLoop "-" $ebsSnapList.Count  "snapshots"
         foreach ($snapshot in $ebsSnapList.SnapshotId) {
            New-EC2Tag -Resource $snapshot -Tag @{Key="map-migrated";Value=$EC2TagsObject.Value} -Verbose
            Write-Host "AMI found for snapshot:" $snapshot
            $amiId = (Get-EC2Image -Filter @{Name="block-device-mapping.snapshot-id";Values=$snapshot}).ImageId
            foreach ($amis in $amiId) {
               Write-Host "Looking for AMI related to" $snapshot
               New-EC2Tag -Resource $amis -Tag @{Key="map-migrated";Value=$EC2TagsObject.Value} -Verbose               
            }
         }        
         
      }
   }
   catch {
      Write-Error $_.Exception.Message
      Write-Error "No instance migrated with CloudEndure found (did you remove the CloudEndure creation time log?)"
   }
}