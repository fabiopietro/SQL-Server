
DECLARE  @TamanhoMB       AS NUMERIC(18, 2) = 1024.0 
        ,@TamanhoGB       AS NUMERIC(18, 2) = 1073741824.0
        ,@TamanhoPagina   AS NUMERIC(18, 2) = 128 


IF (OBJECT_ID('tempdb..#Datafile_Size ') IS NOT NULL) 
    DROP TABLE #Datafile_Size

SELECT  B.database_id                                                                                  AS database_id,
        B.[name]                                                                                       AS [database_name],
        A.state_desc,
        A.[type_desc],
        A.[file_id],
        A.[name],
        A.physical_name,
        CAST(C.total_bytes / @TamanhoGB AS NUMERIC(18, 2))                                             AS disk_total_size_GB,
        CAST(C.available_bytes / @TamanhoGB AS NUMERIC(18, 2))                                         AS disk_free_size_GB,
        CAST(A.size / @TamanhoPagina / @TamanhoMB AS NUMERIC(18, 2))                                   AS size_GB,
        CAST(A.max_size / @TamanhoPagina / @TamanhoMB AS NUMERIC(18, 2))                               AS max_size_GB,
        CAST(
            (CASE WHEN A.growth <= 0                                                           THEN A.size / @TamanhoPagina / @TamanhoMB
                  WHEN A.max_size <= 0                                                         THEN C.total_bytes / @TamanhoGB
                  WHEN A.max_size / @TamanhoPagina / @TamanhoMB > C.total_bytes / 1073741824.0 THEN C.total_bytes / @TamanhoGB
                                                                                               ELSE A.max_size / @TamanhoPagina / @TamanhoMB
             END) AS NUMERIC(18, 2))                                                                   AS max_real_size_GB,
        CAST(NULL AS NUMERIC(18, 2))                                                                   AS free_space_GB,
        (CASE WHEN A.is_percent_growth = 1 THEN A.growth 
                                           ELSE CAST(A.growth / 128 AS NUMERIC(18, 2)) 
         END)                                                                                          AS growth_MB,
        A.is_percent_growth,
        (CASE WHEN A.growth <= 0 THEN 0 ELSE 1 END)                                     AS is_autogrowth_enabled,
        CAST(NULL AS NUMERIC(18, 2))                                                    AS percent_used,
        CAST(NULL AS INT)                                                               AS growth_times
INTO #Datafile_Size 
FROM sys.master_files                                          A   WITH(NOLOCK)
JOIN sys.databases                                             B   WITH(NOLOCK)    ON  A.database_id = B.database_id
CROSS APPLY sys.dm_os_volume_stats(A.database_id, A.[file_id]) C
 

UPDATE #Datafile_Size
SET free_space_GB = CASE WHEN max_size_GB <= 0                     THEN disk_free_size_GB
                         WHEN max_real_size_GB > disk_free_size_GB THEN disk_free_size_GB 
                                                                   ELSE max_real_size_GB - size_GB
                      END


    
UPDATE #Datafile_Size
SET percent_used = size_GB /   CASE WHEN max_real_size_GB > disk_total_size_GB THEN disk_total_size_GB 
                                                                               ELSE max_real_size_GB 
                                END  * 100

WHERE max_real_size_GB > 0   
 

   

UPDATE #Datafile_Size
SET growth_times = CASE WHEN growth_MB <= 0        THEN 0 
                        WHEN is_percent_growth = 0 THEN (max_real_size_GB - size_GB) / (growth_MB / @TamanhoMB) 
                                                   ELSE NULL 
                   END
 
 
  
SELECT * 
FROM #Datafile_Size
