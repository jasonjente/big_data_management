#!/bin/bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "SqlServer1" -i /sql/create_database.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "SqlServer1" -i /sql/dimensions/create_dimensions.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "SqlServer1" -i /sql/fact/create_fact_table.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "SqlServer1" -i /sql/insert_data_from_dataset.sql