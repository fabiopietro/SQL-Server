DECLARE  @RESULTADO AS TABLE    (
                                 Banco                SYSNAME            NULL
                                ,Tipo                 VARCHAR(10)        NULL
                                ,Arquivo              SYSNAME            NULL
                                ,Filegroup            SYSNAME            NULL
                                ,Path                 VARCHAR(500)       NULL                   
                                ,FileSizeMB           DECIMAL(10,2)      NULL
                                ,UsedSpaceMB          DECIMAL(10,2)      NULL
                                ,FreeSpaceMB          DECIMAL(10,2)      NULL
                                ,[FreeSpace%]         DECIMAL(5,2)       NULL
                                ,AutoGrow             VARCHAR(500)       NULL
  
                                )
INSERT @RESULTADO  ( Banco, Tipo, Arquivo, Filegroup, Path, FileSizeMB, UsedSpaceMB, FreeSpaceMB, [FreeSpace%], AutoGrow) 
EXEC sp_msforeachdb '

    SELECT  "?"                                                                     db 
           ,Tipo
           ,Arquivo
           ,[FileGroup]
           ,[Path]
           ,FileSizeMB 
           ,UsedSpaceMB
           ,FileSizeMB - UsedSpaceMB                                                FreeSpaceMB
           ,cast(((FileSizeMB - UsedSpaceMB) / FileSizeMB ) * 100 as decimal(5,2)) [FreeSpace%]
           ,[AutoGrow]
    FROM (SELECT DF.TYPE_DESC                                                                                                        Tipo
                ,DF.name                                                                                                             Arquivo
                ,FG.name                                                                                                             [FileGroup]
                ,DF.PHYSICAL_NAME                                                                                                    [Path]
                ,CONVERT(DECIMAL(10,2),DF.SIZE/128.0)                                                                                FileSizeMB 
                ,CONVERT(DECIMAL(10,2),DF.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(DF.NAME, ''SPACEUSED'') AS INT)/128.0))       UsedSpaceMB
                ,[AutoGrow] = ''By '' + 
                 CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + '' MB -''
                                        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + ''% -'' ELSE '' ''
                 END

                 + 

                 CASE max_size WHEN  0 THEN ''DISABLED'' 
                               WHEN -1 THEN '' Unrestricted''
                                       ELSE '' Restricted to '' + CAST(max_size/(128*1024) AS VARCHAR(10)) + '' GB'' 
                 END

        FROM [?].sys.database_files     DF
        LEFT JOIN [?].sys.filegroups    FG ON FG.data_space_id = DF.data_space_id
    ) AS FG



'


SELECT * 
FROM @RESULTADO
WHERE Banco NOT IN  (
                     'MASTER'
                    ,'MSDB'
                    ,'MODEL'
                    ,'TEMPDB'
                    ,'DBA_BACKUP'
                    ,'DBADMIN'
                    ,'DBAVIVO'
                    ,'DBA_AUDIT'
                    )




