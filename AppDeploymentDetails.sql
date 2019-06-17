/*
Tristan Dufualt
2019-06-15

This query will returnPackageID, Application Name, Software Center Name, Owner of Application, Support Contact, 
Administrator Comments, Date Created, Date Last Modified, Username of Application Creator, The Collection ID being deployed to, 
Collection Type, Collection Name, SCCM Object Path for collection, Member Type (user vs Device), Name of Member.

Some application specific data is held in XML files under the table denote by function fn_ListApplicationCIs.
*/

WITH XMLNAMESPACES ( DEFAULT 'http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest')
select distinct PackageID, v_package.Name,
 SDMPackageDigest.value ('(/AppMgmtDigest/Application/DisplayInfo/Info/Title)[1]', 'nvarchar(max)') [Localized Application Name],
 SDMPackageDigest.value ('(/AppMgmtDigest/Application/Owners/User/@Id)[1]', 'nvarchar(max)') [Owner],
 SDMPackageDigest.value ('(/AppMgmtDigest/Application/Contacts/User/@Id)[1]', 'nvarchar(max)') [Support Contact],
 SDMPackageDigest.value ('(/AppMgmtDigest/Application/Description)[1]', 'nvarchar(max)') [Admin Comments]
 , DateCreated, DateLastModified, CreatedBy, LastModifiedBy, ads.TargetCollectionID
 , Case C.CollectionType 
 When 1 Then 'User Collection'
 When 2 Then 'Device Collection'
 Else ' '
 END As 'Collection Type', 
 C.CollectionName, C.ObjectPath  as CollectionPath, 
 Case cm.ArchitectureKey
 When 3 Then 'Collection'
 When 4 Then 'User'
 When 5 Then 'Device'
 Else ' '
 END AS 'Member Type',
 cm.Name
from v_Package [Member name]
join fn_ListApplicationCIs(16777218) as CI on CI.modelname = v_Package.SecurityKey
join v_AppDeploymentSummary as ads on ads.CI_ID = CI.CI_ID
Left Join CollectionMembers as CM on CM.SiteID=ads.TargetCollectionID 
join vCollections as C on C.SiteID = CM.SiteID
order by v_package.Name
