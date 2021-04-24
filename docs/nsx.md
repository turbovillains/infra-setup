nsx.md
===

Installation Guide https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.1/installation/GUID-414C33B3-674F-44E0-94B8-BFC0B9056B33.html

# Replace Manager Certificate 
https://docs.vmware.com/en/VMware-Validated-Design/5.0.1/com.vmware.vvd.sddc-nsxt-domain-deploy.doc/GUID-2D3B5285-4109-4AEE-9C67-7F0021F62DCB.html

Imported Certificate should have full chain of trust

Cluster IP certificate is set separately

curl --insecure -u admin:'PASSWORD' -X POST "https://$NSX_MANAGER_IP_ADDRESS/api/v1/cluster/api-certificate?action=set_cluster_certificate&certificate_id=

Certificate Issues
https://cloudbytesecurity.com/2020/10/09/how-to-replace-nsx-t-self-signed-certificates/


# Add vCenter to Fabric

https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.1/installation/GUID-D225CAFC-04D4-44A7-9A09-7C365AAFCA0E.html

After the vCenter Server is successfully registered, do not power off and delete the NSX Manager VM without deleting the compute manager first. Otherwise, when you deploy a new NSX Manager, you will not be able to register the same vCenter Server again. You will get the error that the vCenter Server is already registered with another NSX Manager.

# Add more Manager Nodes and form a Cluster (optional)

https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.1/installation/GUID-B89F5831-62E4-4841-BFE2-3F06542D5BF5.html

# Prepare DC Environment

https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.1/migration/GUID-CE5C7E86-F465-4F5D-BF37-4B2355285959.html
