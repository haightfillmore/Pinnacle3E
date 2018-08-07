/******************************************************************************
*** NAME: Generate Documentation.sql
*** DATE: March 1, 2012
*** AUTH: Jeff Correll, Pinnacle
*** DESC: This is a sample of SQL to get the custom objects & name/value
***		  entries for the change form to help manage custom code deployments.
*******************************************************************************/
--Name Value collection:	
select custom_name, custom_attributevalue, custom_description
from dbo.dwf_namevaluecollection_pc
where custom_name like 'g_disburse%' or custom_name like 'g_default%' or custom_name like 'g_debug%'

--new roles:
SELECT bu.BaseUserName, r.description
FROM NxRole r
	JOIN nxBaseUser bu
		on bu.nxBaseUserID=r.nxRoleID
WHERE bu.BaseUserName like 'DWF cheque%' or bu.BaseUserName like 'DWF Office%'

--new workflow roles:
select name, description
from nxWFRole
where name like 'DWF Cheque%' or name like 'DWF Office%'

--new role users:
select wfr.name, r.description, r2.description --name, description
from nxWFRoleUser ru
	JOIN nxWFRole wfr
		on ru.wfroleid=wfr.nxWFRoleID
	JOIN NxRole r
		ON ru.currentUserID=r.nxroleid
	JOIN NxRole r2
		ON ru.nextUserID=r2.nxroleid	
where wfr.name like 'DWF Cheque%' or wfr.name like 'DWF Office%'
order by wfr.name

--development objects:
DECLARE @idoc int
DECLARE @doc nvarchar(4000)
SELECT @doc=metaXML 
FROM nxFWKAppObjectdata aod
	JOIN NxFwkAppObject ao
		ON aod.appobjectID=ao.nxfWKAppObjectID
WHERE AppObjectCode='PC_ProformaEditFull_20022014' 

EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

SELECT Row_Number() OVER(ORDER BY a.[Type], revision desc), a.[ID], a.[Type], CAST(aod.majorversion as varchar(2)) + '.' 
						+ CAST(aod.minorversion as varchar(2)) + '.' 
						+ CAST(aod.build as varchar(2)) + '.' 
						+ CAST(aod.revision as varchar(4))
FROM OPENXML (@idoc, '/*/*', 1)
            WITH (ID varchar(256),
                  Type varchar(32)) a
		JOIN NxFWKAppObjectType aot
			ON a.Type=aot.AppObjectTypeCode
		JOIN nxFWKAppObject ao
			on a.[ID]=ao.AppObjectCode
			and ao.AppObjectTypeID=aot.NxFWKAppObjectTypeID
		JOIN nxFWKAppObjectdata aod
			on aod.appobjectID=ao.nxfWKAppObjectID
WHERE IsCustom=1	--2.7 only
ORDER BY a.[Type], revision desc
