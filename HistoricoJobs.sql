
	DECLARE @StartDate           as VARCHAR(8)  
	DECLARE @Result_History_Jobs as table(
										 Cod					int identity(1,1)
										,Instance_Id			int
										,Job_Id					varchar(255)
										,Job_Name				varchar(255)
										,Step_Id				int
										,Step_Name				varchar(255)
										,Sql_Message_Id			int
										,Sql_Severity			int
										,SQl_Message			varchar(5000)
										,Run_Status				int
										,Run_Date				varchar(20)
										,Run_Time				varchar(20)
										,Run_Duration			int
										,Operator_Emailed		varchar(500)
										,Operator_NetSent		varchar(100)
										,Operator_Paged			varchar(100)
										,Retries_Attempted		int
										,Nm_Server				varchar(100)
										)
										
	SET @StartDate = CONVERT(VARCHAR(8), dateadd(MONTH, -1, getdate()), 112) 
	insert @Result_History_Jobs	(
								 Instance_Id			
								,Job_Id					
								,Job_Name				
								,Step_Id				
								,Step_Name				
								,Sql_Message_Id			
								,Sql_Severity			
								,SQl_Message			
								,Run_Status				
								,Run_Date				
								,Run_Time				
								,Run_Duration			
								,Operator_Emailed		
								,Operator_NetSent		
								,Operator_Paged			
								,Retries_Attempted		
								,Nm_Server				
								)
						exec	Msdb.dbo.SP_HELP_JOBHISTORY		 @mode = 'FULL' 
																,@start_run_date  = @StartDate
																
	
	select	Job_Name
			,case	when Run_Status = 0 then 'Falha'
					when Run_Status = 1 then 'Sucesso'
					when Run_Status = 2 then 'Retry (step only)'
					when Run_Status = 3 then 'Cancelado'
					when Run_Status = 4 then 'Em execução'
					when Run_Status = 5 then 'Inesperado' 
			 end Status
			 		
			 ,cast	(LEFT (Run_Date, 4) + '-' + 
			         SUBSTRING(Run_Date,5,2) + '-' + 
			         SUBSTRING(Run_Date,7,2) + ' ' + 
					 right('00' + substring(Run_time,(len(Run_time)-5),2) ,2)+ ':' +
					 right('00' + substring(Run_time,(len(Run_time)-3),2) ,2)+ ':' +
					 right('00' + substring(Run_time,(len(Run_time)-1),2) ,2) as DATETIME 
					)															Dt_Execucao
			,right('00' + substring(cast(Run_Duration as varchar)
			,(len(Run_Duration)-5),2) ,2)+ ':' + 	right('00' + substring(cast(Run_Duration as varchar)
			,(len(Run_Duration)-3),2) ,2)+ ':' + 	right('00' + substring(cast(Run_Duration as varchar)
			,(len(Run_Duration)-1),2) ,2) Run_Duration
			,SQL_Message
            , Job_Id
	from @Result_History_Jobs
	where Step_Id = 0
      and cast	(
				Run_Date + ' ' + 
				right('00' + substring(Run_time,(len(Run_time)-5),2) ,2)+ ':' +
				right('00' + substring(Run_time,(len(Run_time)-3),2) ,2)+ ':' +
				right('00' + substring(Run_time,(len(Run_time)-1),2) ,2) as datetime
				) >=dateadd(MONTH, -1, getdate()) --dia anterior no horário

