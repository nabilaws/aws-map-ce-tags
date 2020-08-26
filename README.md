# aws-map-ec2-tags
 **Sync tags between CloudEndure Migrated Resources and every EC2 Resources (Instances/Volumes/Snapshots/AMI)**


EC2 Instances migrated with CloudEndure could have missing tag propagation to EBS volumes, snapshots and AMI.
This script will synchronize specific tag (MAP2.0) or every tags to underlying resources of your EC2 Instance.


- aws-map-ec2-tagging.ps1 : 
        Powershell/.NetCore script
        Tested on : 

        Amazaon Linux 2
        ----------------------------------------------------------------------------------------------------------
        PSVersion                      | 7.0.3                                                                   |
        PSEdition                      | Core                                                                    |
        GitCommitId                    | 7.0.3                                                                   |
        OS                             | Linux 4.14.186-146.268.amzn2.x86_64 #1 SMP Tue Jul 14 18:16:52 UTC 2020 |
        Platform                       | Unix                                                                    |
        ----------------------------------------------------------------------------------------------------------


        Windows 10
        ---------------------------------------------------------------
        PSVersion                     | 7.0.3                         |
        PSEdition                     | Core                          |
        GitCommitId                   | 7.0.3                         |
        OS                            | Microsoft Windows 10.0.19042  |
        ---------------------------------------------------------------

        Windows Server 2019
        ---------------------------------------------------------------
        PSVersion                      | 7.0.3                        |
        PSEdition                      | Core                         |
        GitCommitId                    | 7.0.3                        |
        OS                             | Microsoft Windows 10.0.17763 |
        ---------------------------------------------------------------

        #Requires -Module AWS.Tools.EC2
        EC2 Instances migrated with CloudEndure (Tag Value: CloudEndure creation time) for MAP2.0, could miss the map-migrated tag.
        This script will synchronize your Instances (migrated with CloudEndure) tags (map-migrated/value only) to every linked resources (EBS Volumes, snapshots and AMI)
        This action ensure you to fully benefit your MAP2.0 credits.