set serveroutput on
declare cursor data_cursor is 
select distinct user_constraints.CONSTRAINT_TYPE, user_constraints.CONSTRAINT_NAME,  user_tab_columns.data_type, user_constraints.table_name, user_cons_columns.column_name from user_constraints 
join user_cons_columns
on user_constraints.constraint_name = user_cons_columns.constraint_name
join USER_OBJECTS
on USER_OBJECTS.object_name = user_cons_columns.table_name
join user_tab_columns
on user_tab_columns.column_name = user_cons_columns.column_name
where user_constraints.CONSTRAINT_TYPE = 'P'
and USER_OBJECTS.object_type = 'TABLE' 
 and user_tab_columns.data_type = 'NUMBER';

begin 
for data_record in data_cursor loop 
execute immediate 'CREATE SEQUENCE ' ||data_record.table_name||'_tables_SEQ START WITH 600 increment by 1 MAXVALUE 999999999999999999999999999'; 
execute immediate 'CREATE OR REPLACE TRIGGER  '||data_record.table_name||'_tables_trg BEFORE INSERT ON  '||data_record.table_name||  
         ' FOR EACH ROW 
         BEGIN 
         :new.'|| data_record.column_name ||' := '|| data_record.table_name||'_tables_SEQ.nextval;
END; ';
end loop;
end;
