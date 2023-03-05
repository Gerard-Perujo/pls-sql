/* PASO1 - Creo un procedimiento en el cual entra un id de empleado y modifica el id del trabajo
            al cual pertenece el id del empleado, antes de realizar el procedimiento llamamos a una funcion
            donde comprobara si el id del trabajo proporcionado existe, en el caso de que el id del trabajo
            porporcinado, el procedimiento se realiza y cambia el id del trabajo por el nuevo id_trabajo
            proporcionado*/

CREATE OR REPLACE PROCEDURE ACTUALIZAR_EMPLEADO (N_Empleado IN employees.employee_id%type, N_Trabajo IN jobs.job_id%type)  AS 

 cantidad PLS_INTEGER := 0;
 
BEGIN 
    IF TRABAJO_EXISTE (N_Trabajo) THEN
        SELECT count(*) INTO cantidad FROM employees WHERE employee_id = N_Empleado;
            IF cantidad = 1 THEN
                 UPDATE employees
                 SET job_id = N_Trabajo
                 WHERE employee_id = N_Empleado;
            END If;
             dbms_output.put_line('Trabajo modificado');
         ELSE
            dbms_output.put_line('Trabajo no existe');
    END IF;
END ACTUALIZAR_EMPLEADO;


/* PASO 2-  Creo una funcion donde se comprueba que el id_trabajo introducido existe, en el caso
            de que existe devuelve true, i sino existe devuelve false*/

create or replace FUNCTION TRABAJO_EXISTE (id_trabajo jobs.job_id%type)RETURN BOOLEAN AS 

    cantidad pls_integer := 0;
    
BEGIN
    SELECT count(*)
    INTO cantidad
    FROM jobs
    WHERE job_id = id_trabajo;
    
    IF cantidad = 1 THEN
        RETURN true;
     ELSE
        RETURN false;
    END IF;
    
END TRABAJO_EXISTE;


/* PASO 3 - Aqui creamos un bloque anonimo donde pasamos un id_empleado y introducimos
            el id:_trabajo que queremos cambiar al id_empleado relacionado*/

SET SERVEROUTPUT ON

DECLARE
    N_Empleado employees.employee_id%type;
    N_Trabajo jobs.job_id%type;
BEGIN

    N_Empleado := &employee_id;
    N_Trabajo := '&jobid';
    ACTUALIZAR_EMPLEADO (N_Empleado, N_Trabajo);
    
END;

ROLLBACK;


/*PASO 4 - Creamos la tabla EMP_AUDIT que es donde se veran los registros del trigger para
            ver cuando se dispara y ver quien es el usuario que ha echo la accion*/

CREATE TABLE EMP_AUDIT (
ID_USUARIO INT, 
MOMENTO VARCHAR2 (100), 
MENSAJE VARCHAR2(100)
);

/* Creo un trigger que saltara cada vez que haya una actualizacion en el salario
    sacando el id del empleado, la fecha en que se ha actualizado, el salario
    viejo y el salario nuevo, en caso de que no se actualice el salario no saltara el trigger
    *//
    
create or replace TRIGGER TRIGGER_EMP_AUDIT 
AFTER UPDATE OF SALARY ON EMPLOYEES 
FOR EACH ROW
BEGIN
IF(:OLD.SALARY<>:NEW.SALARY)THEN
  INSERT INTO EMP_AUDIT (ID_USUARIO, MOMENTO, MENSAJE)
  VALUES (:old.employee_id, NULL, NULL);

  DBMS_OUTPUT.PUT_LINE('EL ID DE EMPLEADO UTILIZADO ES : ' || :old.employee_id);
  DBMS_OUTPUT.PUT_LINE('EL MOMENTO DE LA ACTUALIZACION ES : ' || SYSDATE);
  DBMS_OUTPUT.PUT_LINE('EL ANTIGUO SALARIO ES : ' || :old.salary || ' Y EL NUEVO ES : ' || :new.salary);
  END IF;
END;
  
  /*creo un bloque anonimo donde hago una actualizacion en el salario del empleado
  114, para que salte el trigger y me saque los mensajes
    
SET SERVEROUTPUT ON
BEGIN
    UPDATE EMPLOYEES
    SET SALARY = 20000
    WHERE EMPLOYEE_ID = 114;
END;

ROLLBACK


