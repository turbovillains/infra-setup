vmWare
====

# vCenter Simple Update Error

https://tinkertry.com/how-to-workaround-unexpected-error-occurred-while-fetching-the-updates-error-during-vcsa-7-upgrade

# VM Hardware Versions

https://kb.vmware.com/s/article/1003746

# VM Guest Id

https://vdc-download.vmware.com/vmwb-repository/dcr-public/da47f910-60ac-438b-8b9b-6122f4d14524/16b7274a-bf8b-4b4c-a05e-746f2aa93c8c/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html

# LSI 3108 settings

```
esxcfg-advcfg -g /LSOM/diskIoRetryFactor
esxcfg-advcfg -s 4 /LSOM/diskIoRetryFactor
```

# Set scratch back to /tmp

mkdir /tmp/log
esxcli system syslog config set --logdir=/tmp/log
esxcli system syslog config set --logdir=/scratch/log
vim-cmd hostsvc/advopt/update ScratchConfig.ConfiguredScratchLocation string /tmp

esxcli system syslog reload
esxcli storage filesystem unmount -p /vmfs/volumes/5feb62f0-2af61216-ccfb-0cc47ae41554/



# Unconfigure coredump location
```
esxcli system coredump file set -u
```

# Killing VMs 

```
esxcli vm process list
esxcli vm process kill --type= [soft,hard,force] --world-id= WorldNumber
```

https://kb.vmware.com/s/article/1014165#steps_using_esxi_command_line_utility_vim-cmd_to_power_off_vm


# Disable SW iSCSI

```
esxcfg-swiscsi -d
```

# root password reset from vcenter via host profile

https://kb.vmware.com/s/article/68079

# Cannot change remote syslog server

Can be caused by invalid log directory. Check
/var/log/.vmsyslogd.err

Fix by resetting to default scratch log directory
```
esxcli system syslog config set --loghost='tcp://10.0.7.4:514'  --logdir=/scratch/log
esxcli system syslog reload
```

# In-depth video about vcenter performance

https://www.youtube.com/watch?v=eFM_ewwy2ys

# Set memory reservation for vcenter

https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vsa.doc_10%2FGUID-8AE3622F-A657-4D02-9F6C-34A53C5B1C51.html

# VAMI SSL certificate shall be updated manually

https://kb.vmware.com/s/article/2136693


# Disable smartd

```
/etc/init.d/smartd stop
chkconfig smartd off
```


# Run iperf3

```
esxcli network firewall set --enabled false
cp /usr/lib/vmware/vsan/bin/iperf3 ./iperf3.copy
```

# CmdLet Reference
https://code.vmware.com/docs/10197/cmdlet-reference/

# Diagnostic partition

# https://kb.vmware.com/s/article/1036609
# https://kb.vmware.com/s/article/2004299

partedUtil setptbl /vmfs/devices/disks/mpx.vmhba0\:C0\:T1\:L0 msdos "1 63 2097151 252 0"
partedUtil getptbl /vmfs/devices/disks/mpx.vmhba0\:C0\:T1\:L0

esxcli system coredump partition set --partition mpx.vmhba0:C0:T1:L0:1
esxcli system coredump partition set --enable true

esxcli system coredump partition list

# Suppress SSH warning

https://ryanmangansitblog.com/2012/08/04/disabling-ssh-configuration-issues-warning-in-5-0/

# Invalid opcodes

https://kb.vmware.com/s/article/1003278
```
/etc/init.d/smartd stop
chkconfig smartd off
```

# iSCSI advanced options

https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.storage.doc/GUID-7FCA31F2-FA13-4BFD-8057-5A36DC3FBC14.html

# Destroy HA via CLI

 vcha-destroy

 https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.avail.doc/GUID-FE5106A8-5FE7-4C38-91AA-D7140944002D.html


# Create recovery vswitch 

https://www.starwindsoftware.com/blog/vcsa-connected-to-dvswitch-is-unaccessible-after-restore

esxcfg-vswitch -a vSwitch0
esxcfg-vswitch -A VCSANetwork vSwitch0
esxcfg-vswitch -l

esxcfg-vswitch -Q vmnic1 -V 36 dswitch01

esxcli network vswitch standard uplink add --uplink-name vmnic1 --vswitch-name vSwitch0

esxcfg-vswitch -v 10 -p VCSANetwork vSwitch0


# Powershell

https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7

brew cask install powershell

pwsh

Find-Module -Name VMware.PowerCLI
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
Get-Command -Module *VMWare*

# Change all luns to Round-Robin

https://vmarena.com/how-to-change-all-luns-to-round-robin-policy-using-powercli/

```
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
Connect-VIServer -Server vcsa.noroutine.me

Get-Vmhost | Get-Scsilun

Get-VMHost | Get-ScsiLun -LunType disk | Where {$_.MultipathPolicy -notlike "RoundRobin" } | Where {$_.MultipathPolicy -notlike "Fixed" } | Set-Scsilun -MultiPathPolicy RoundRobin

oder

Get-VMHost | Get-ScsiLun -LunType disk | Where {$_.MultipathPolicy -notlike "RoundRobin"} | Where {$_.CapacityGB -ge 500}

Get-VMHost | Get-ScsiLun -LunType disk | Where {$_.MultipathPolicy -notlike "RoundRobin" } | Where {$_.MultipathPolicy -notlike "Fixed" } | Set-Scsilun -MultiPathPolicy RoundRobin
```

# Register VMs from datastore in vcenter

```
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
Connect-VIServer -Server vcsa.noroutine.me

$Cluster = "dev"
$Datastores = "NVME3", "NVME1", "NVME0", "NVME2"
$VMFolder = "discovered"
$ESXHost = Get-Cluster $Cluster | Get-VMHost | select -First 1
 
foreach($Datastore in Get-Datastore $Datastores) {
 # Set up Search for .VMX Files in Datastore
 $ds = Get-Datastore -Name $Datastore | %{Get-View $_.Id}
 $SearchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
 $SearchSpec.matchpattern = "*.vmx"
 $dsBrowser = Get-View $ds.browser
 $DatastorePath = "[" + $ds.Summary.Name + "]"
 
 # Find all .VMX file paths in Datastore, filtering out ones with .snapshot (Useful for NetApp NFS)
 $SearchResult = $dsBrowser.SearchDatastoreSubFolders($DatastorePath, $SearchSpec) | where {$_.FolderPath -notmatch ".snapshot"} | %{$_.FolderPath + ($_.File | select Path).Path}
 
 #Register all .vmx Files as VMs on the datastore
 foreach($VMXFile in $SearchResult) {
 New-VM -VMFilePath $VMXFile -VMHost $ESXHost -Location $VMFolder -RunAsync
 }
}
```

Remove inaccessible vms
```


Get-Cluster -Name $Cluster | Get-VM | Get-View | Where {-not $_.Config.Template} | Where{$_.Runtime.ConnectionState -eq “invalid” -or $_.Runtime.ConnectionState -eq “inaccessible”} | %{Remove-VM -Confirm:$false -VM $_.Name}

```
In case of unknown partition table, make one

partedUtil mklabel /vmfs/devices/disks/naa.6001405639b4ab2c7c941b39d3497832 gpt
partedUtil getUsableSectors /vmfs/devices/disks/naa.6001405639b4ab2c7c941b39d3497832 
partedUtil setptbl /vmfs/devices/disks/naa.6001405639b4ab2c7c941b39d3497832 gpt "1 2048 1953260894 AA31E02A400F11DB9590000C2911D1B8 0"

Scan datastore for partitions
```
esxcfg-scsidevs -l | grep "Console Device:" | awk {'print $3'}
```

```
offset="128 2048";
disk="/vmfs/devices/disks/naa.6001405639b4ab2c7c941b39d3497832"

partedUtil getptbl $disk; { for i in `echo $offset`; do echo "Checking offset found at $i:"; hexdump -n4 -s $((0x100000+(512*$i))) $disk; hexdump -n4 -s $((0x1300000+(512*$i))) $disk; hexdump -C -n 128 -s $((0x130001d + (512*$i))) $disk; done; } | grep -B 1 -A 5 d00d
```

Re-import vm into state
```
terraform state rm 'module.lab01-vm-ipa.vsphere_virtual_machine.vm["lab01-vm-ipa01"]'
terraform import 'module.lab01-vm-ipa.vsphere_virtual_machine.vm["lab01-vm-ipa01"]' '/lab/vm/dc-lab01/lab01-vm-ipa01'
```

# Power on all vms

Get-VM | Start-VM -Confirm:$false
# Datastore not mounted and snapshots are created

https://www.codyhosterman.com/2016/01/mounting-an-unresolved-vmfs/

## Mount snapshot without resignature

```
esxcfg-volume -l
esxcli storage vmfs snapshot list
esxcfg-volume -M HDD
```
## Mount snapshot with resignature

```
esxcfg-volume -l
esxcli storage vmfs snapshot list
esxcli storage vmfs snapshot resignature -l HDD
```


# Get-VMFolderPath

```powershell
 function Get-VMFolderPath {  
 <#  
 .SYNOPSIS  
 Get folder path of Virtual Machines  
 .DESCRIPTION  
 The function retrives complete folder Path from vcenter (Inventory >> Vms and Templates)  
 .NOTES   
 Author: Kunal Udapi  
 http://kunaludapi.blogspot.com  
 .PARAMETER N/a  
 No Parameters Required  
 .EXAMPLE  
  PS> Get-VM vmname | Get-VMFolderPath  
 .EXAMPLE  
  PS> Get-VM | Get-VMFolderPath  
 .EXAMPLE  
  PS> Get-VM | Get-VMFolderPath | Out-File c:\vmfolderPathlistl.txt  
 #>  
  #####################################    
  ## http://kunaludapi.blogspot.com    
  ## Version: 1    
  ## Windows 8.1   
  ## Tested this script on    
  ## 1) Powershell v4    
  ## 2) VMware vSphere PowerCLI 6.0 Release 1 build 2548067    
  ## 3) Vsphere 5.5    
  #####################################    
   Begin {} #Begin  
   Process {  
     foreach ($vm in $Input) {  
       $DataCenter = $vm | Get-Datacenter  
       $DataCenterName = $DataCenter.Name  
       $VMname = $vm.Name  
       $VMParentName = $vm.Folder  
       if ($VMParentName.Name -eq "vm") {  
         $FolderStructure = "{0}/{1}" -f $DataCenterName, $VMname  
         $FolderStructure  
         Continue  
       }#if ($VMParentName.Name -eq "vm")  
       else {  
         $FolderStructure = "{0}/{1}" -f $VMParentName.Name, $VMname  
         $VMParentID = Get-Folder -Id $VMParentName.ParentId  
         do {  
           $ParentFolderName = $VMParentID.Name  
           if ($ParentFolderName -eq "vm") {  
             $FolderStructure = "$DataCenterName/$FolderStructure"  
             $FolderStructure  
             break  
           } #if ($ParentFolderName -eq "vm")  
           $FolderStructure = "$ParentFolderName/$FolderStructure"  
           $VMParentID = Get-Folder -Id $VMParentID.ParentId  
         } #do  
         until ($VMParentName.ParentId -eq $DataCenter.Id) #until  
       } #else ($VMParentName.Name -eq "vm")  
     } #foreach ($vm in $VMList)  
   } #Process  
   End {} #End  
 } #function Get-VMFolderPath
 ```


 ## Add iscsi

```powershell
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
Connect-VIServer -Server vcsa.noroutine.me

$Cluster = "dev"

Get-Cluster $Cluster | Get-VMHost | Get-VMHostHba -Type iScsi   | Select-Object Name, Status, IScsiName

$ESXIHosts = Get-Cluster $Cluster | Get-VMHost
foreach($ESXIHost in $ESXIHosts) {
  Write-Output $ESXIHost.Name
  $ESXIHost | Get-VMHostHba -Type iScsi | New-IScsiHbaTarget -Address 10.255.255.10:3260
  $ESXIHost | Get-VMHostHba -Type iScsi | New-IScsiHbaTarget -Address 10.255.254.10:3260
}

$ESXIHosts | Get-VmHostStorage -Refresh -RescanAllHba

// Remove
foreach($ESXIHost in $ESXIHosts) {
  Write-Output $ESXIHost.Name
  $ESXIHost | Get-VMHostHba -Type iScsi | Get-IScsiHbaTarget -Address 10.255.255.10:3261 | Remove-IScsiHbaTarget -Confirm:$false
  $ESXIHost | Get-VMHostHba -Type iScsi | Get-IScsiHbaTarget -Address 10.255.254.10:3261 | Remove-IScsiHbaTarget -Confirm:$false
}


```


## Rescan All HBAs in the cluster

## Add iscsi

```powershell
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
Connect-VIServer -Server vcsa.noroutine.me

$Cluster = "dev"

Get-Cluster $Cluster | Get-VMHost | Get-VMHostHba -Type iScsi   | Select-Object Name, Status, IScsiName

$ESXIHosts = Get-Cluster $Cluster | Get-VMHost
foreach($ESXIHost in $ESXIHosts) {
  Write-Output $ESXIHost.Name
}

$ESXIHosts | Get-VmHostStorage -Refresh -RescanAllHba

```

Also check parallel version
https://www.brisk-it.net/rescanning-esxi-storage-in-a-parallel-way/
https://github.com/mvandriessen/Invoke-RescanAllHBA/blob/master/Invoke-RescanAllHBA.ps1

# Recovering from PDL

APD, planned and unplanned PDL