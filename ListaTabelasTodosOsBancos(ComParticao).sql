DECLARE  @RESULTADO AS TABLE    (
                                 Banco                SYSNAME
                                ,Tabela               SYSNAME
                                ,Linhas               BIGINT
                                ,EspacoTotal          BIGINT         
                                ,EspacoUsadoKB        BIGINT                    
                                ,EspacoNaoUsadoKB     BIGINT    
                                ,Disco                CHAR(1) 
                                ,Arquivo              SYSNAME  
                                )
INSERT @RESULTADO  (Banco, Tabela, Linhas, EspacoTotal, EspacoUsadoKB, EspacoNaoUsadoKB, Disco, Arquivo) 
EXEC sp_msforeachdb '
IF (''?'' NOT IN (''master'', ''msdb'', ''model'', ''tempdb'', ''DBA_BACKUP'',''DBAdmin'',''DBAVIVO''))
BEGIN

    SELECT "?" AS db
            ,t.NAME																	AS Tabela
		    ,p.rows														    	    AS Registros
		    ,SUM(au.total_pages) * 8												AS EspacoTotalKB
		    ,SUM(au.used_pages) * 8													AS EspacoUsadoKB
		    ,(SUM(au.total_pages) - SUM(au.used_pages)) * 8							AS EspacoNaoUsadoKB
		    ,LEFT(df.physical_name, 1)												AS Disco 
            ,df.name                                                                AS Arquivo 

    FROM sys.tables					t

    INNER JOIN sys.indexes			i	ON  i.OBJECT_ID		=	t.object_id

    INNER JOIN sys.partitions		p	ON  p.object_id		=	i.OBJECT_ID 
									    AND i.index_id		=	p.index_id

    INNER JOIN sys.allocation_units au	ON  au.container_id	=	p.partition_id 

    INNER JOIN sys.database_files   df	ON	df.data_space_id =	au.data_space_id 

    WHERE t.is_ms_shipped = 0
        AND i.OBJECT_ID > 255
 
GROUP BY t.Name
        ,p.rows	
        ,left(df.physical_name, 1)
        ,df.name

END
'

SELECT * 
FROM @RESULTADO
order by 1
go