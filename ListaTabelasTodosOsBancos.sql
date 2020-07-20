DECLARE  @RESULTADO AS TABLE    (
                                 Banco                SYSNAME
                                ,Tabela               SYSNAME
                                ,Linhas               BIGINT
                                ,EspacoTotal          BIGINT         
                                ,EspacoUsadoKB        BIGINT                    
                                ,EspacoNaoUsadoKB     BIGINT     
                                )
INSERT @RESULTADO  ( Banco, Tabela, Linhas, EspacoTotal, EspacoUsadoKB, EspacoNaoUsadoKB ) 
EXEC sp_msforeachdb '
IF (''?'' NOT IN (''master'', ''msdb'', ''model'', ''tempdb'', ''DBA_BACKUP'',''DBAdmin'',''DBAVIVO''))
BEGIN

    SELECT "?" AS db
            ,name 
            ,p.rows                                              AS Linhas
            ,SUM(a.total_pages) * 8                              AS EspacoTotal
            ,SUM(a.used_pages) * 8                               AS EspacoUsadoKB
            ,SUM(a.total_pages)  * 8 - SUM(a.used_pages) * 8     AS EspacoUsadoKB
           
    FROM [?].sys.tables                 t
    INNER JOIN [?].sys.partitions       p ON p.object_id    = t.OBJECT_ID 
    INNER JOIN [?].sys.allocation_units a ON p.partition_id = a.container_id

    GROUP BY t.Name
            ,p.Rows

END
'

SELECT * 
FROM @RESULTADO
order by 1
go