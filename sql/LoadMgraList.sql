-- AUTHOR: YMA@SANDAG.ORG
-- modified to move to popsyn_3_0 database, on 04/17/2019

use popsyn_3_0

DROP TABLE IF EXISTS #localtempMgra

CREATE TABLE #localtempMgra(
	[id]         [smallint] NOT NULL,
	[value]      [int] NOT NULL
) 

BULK INSERT #localtempMgra
FROM '\\nasb8\transdata\projects\sr13\sb\Escondido\CCP\Analysis\mgra_list_Escondido.csv'
WITH
(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
)


Delete from [sbreport].[mgra]
where [user_id] = system_user


INSERT INTO [sbreport].[mgra] (user_id,id,value)
SELECT system_user, id, value
FROM #localtempMgra


select *
from [popsyn_3_0].[sbreport].[mgra]
where [user_id] = system_user
order by id


