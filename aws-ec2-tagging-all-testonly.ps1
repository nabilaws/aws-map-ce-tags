#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.0.6.0'}
#Requires -Module AWS.Tools.EC2
$ErrorActionPreference = "Continue"
#1: Sync your ALL your EC2 Instances tagbs with EC2/EBS/SNAPSHOTS/AMI
$ec2list = (Get-EC2Instance).Instances
foreach ($ec2Looplist in $ec2list.InstanceId){
   try {
      $ec2TagsObject = (Get-EC2Tag -Filter @{Name="resource-type";Values="instance"},@{Name="resource-id";Values=$ec2looplist} -Verbose)
      $ec2VolumeList = (Get-EC2Volume -Filter @{ Name="attachment.instance-id"; Values= $ec2looplist}).VolumeId
      Write-Host "Tags source list from instance:" $ec2Looplist
      $ec2TagsObject | Select-Object Key,Value | Format-Table | Out-String | Write-Host
      Write-Host "For the following volumes"
      $ec2VolumeList | Format-Table | Out-String | Write-Host
        foreach ($tags in $ec2TagsObject) {
            foreach ($ebsLoop in $ec2VolumeList) {
                Write-Host "Target resource:" $ebsLoop "Applying" 
                $tags | Select-Object Key,Value | Format-Table | Out-String | Write-Host
                #New-EC2Tag -Resource $ebsLoop -Tag @{Key=$ec2TagsObject.Key;Value=$ec2TagsObject.Value} -Verbose
                $ebsSnapList = (Get-EC2Snapshot -Filter @{Name="volume-id";Values=$ebsLoop})
                    foreach ($snapshot in $ebsSnapList.SnapshotId) {
                        Write-Host "Target resource:"  $snapshot               
                        #New-EC2Tag -Resource $snapshot -Tag @{Key=$ec2TagsObject.Key;Value=$ec2TagsObject.Value} -Verbose   
                        $amiId = (Get-EC2Image -Filter @{Name="block-device-mapping.snapshot-id";Values=$snapshot}).ImageId
                            foreach ($amis in $amiId) {
                                Write-Host "Target resource:" $amis

                                #New-EC2Tag -Resource $amis -Tag @{Key=$ec2TagsObject.Key;Value=$ec2TagsObject.Value} -Verbose               
                   }
                }        
             }
          }    
        }
   catch {
      Write-Error $_.Exception.Message
   }
}