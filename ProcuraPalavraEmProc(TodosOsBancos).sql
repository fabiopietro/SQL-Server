USE master
go

SET NOCOUNT ON
GO

DECLARE  @PALAVRA   AS VARCHAR(200) = 'DISTINCT'   
        ,@SQL       AS  VARCHAR(MAX) 

DECLARE  @RESULTADO AS TABLE    (
                                 Banco                SYSNAME
                                ,[Proc]               SYSNAME
                                ,Trecho               VARCHAR(MAX)
                                )



SET @SQL = 
'

    SELECT "?"                                                  AS Banco
          ,A.NAME                                               AS [Procedure]
          ,B.TEXT                                               AS Trecho
    FROM [?].sys.SYSOBJECTS  A (nolock)
    JOIN [?].sys.SYSCOMMENTS B (nolock)     ON B.ID = A.ID
    WHERE B.TEXT LIKE ''%' +  @PALAVRA + '%''  
      AND A.TYPE = ''P''                      
    ORDER BY A.NAME
            ,db_name()

 '


 INSERT @RESULTADO  (Banco, [Proc], Trecho) 
 EXEC sp_msforeachdb  @SQL 


 SELECT * 
 FROM @RESULTADO
 WHERE Banco NOT IN (
                     'master'
                    ,'msdb'
                    ,'model'
                    ,'tempdb'
                    )


