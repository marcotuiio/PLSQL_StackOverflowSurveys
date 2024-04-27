-- PL/SQL script to insert normalized data into the database
-- Author: Marco Tulio Alves de Barros

DROP TABLE MARCOTAB.DEVELOPERS CASCADE CONSTRAINTS;
DROP TABLE MARCOTAB.LANGUAGES CASCADE CONSTRAINTS;
DROP TABLE MARCOTAB.OP_SYSTEMS CASCADE CONSTRAINTS;
DROP TABLE MARCOTAB.DATABASES CASCADE CONSTRAINTS;
DROP TABLE MARCOTAB.AI_TOOLS CASCADE CONSTRAINTS;
DROP TABLE MARCOTAB.AI_USAGE CASCADE CONSTRAINTS;
DROP TABLE MARCOTAB.LEARNING_METHODS CASCADE CONSTRAINTS;
DROP TABLE MARCOTAB.DEV_TYPES CASCADE CONSTRAINTS;

-- SET SERVEROUTPUT ON;

CREATE TABLE developers (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    resp_id NUMBER,
    survey_year NUMBER,
    age VARCHAR2(20),
    country VARCHAR2(100),
    main_branch VARCHAR2(50),
    remote_work VARCHAR2(20),
    years_code NUMBER,
    time_searching VARCHAR2(50),
    time_answering VARCHAR2(50),
    industries VARCHAR2(100),
    CONSTRAINT developers_pk PRIMARY KEY (id),
    CONSTRAINT developers_uk UNIQUE (resp_id, survey_year)
);

CREATE TABLE languages (
    dev_id NUMBER,
    language VARCHAR2(50),
    CONSTRAINT languages_pk PRIMARY KEY (dev_id, language),
    CONSTRAINT languages_fk FOREIGN KEY (dev_id) REFERENCES developers(id)
);

CREATE TABLE op_systems (
    dev_id NUMBER,
    op_system VARCHAR2(50),
    CONSTRAINT ops_systems_pk PRIMARY KEY (dev_id, op_system),
    CONSTRAINT ops_systems_fk FOREIGN KEY (dev_id) REFERENCES developers(id)
);

CREATE TABLE databases (
    dev_id NUMBER,
    database VARCHAR2(50),
    CONSTRAINT databases_pk PRIMARY KEY (dev_id, database),
    CONSTRAINT databases_fk FOREIGN KEY (dev_id) REFERENCES developers(id)
);

CREATE TABLE ai_tools (
    dev_id NUMBER,
    ai_tool VARCHAR2(50),
    CONSTRAINT ai_tools_pk PRIMARY KEY (dev_id, ai_tool),
    CONSTRAINT ai_tools_fk FOREIGN KEY (dev_id) REFERENCES developers(id)
);

CREATE TABLE ai_usage (
    dev_id NUMBER,
    ai_usage VARCHAR2(300),
    CONSTRAINT ai_usage_pk PRIMARY KEY (dev_id, ai_usage),
    CONSTRAINT ai_usage_fk FOREIGN KEY (dev_id) REFERENCES developers(id)
);

CREATE TABLE learning_methods (
    dev_id NUMBER,
    learning_method VARCHAR2(200),
    CONSTRAINT learning_methods_pk PRIMARY KEY (dev_id, learning_method),
    CONSTRAINT learning_methods_fk FOREIGN KEY (dev_id) REFERENCES developers(id)
);

CREATE TABLE dev_types (
    dev_id NUMBER,
    dev_type VARCHAR2(100),
    CONSTRAINT dev_types_pk PRIMARY KEY (dev_id, dev_type),
    CONSTRAINT dev_types_fk FOREIGN KEY (dev_id) REFERENCES developers(id)
);

CREATE OR REPLACE FUNCTION marcotab.checks_if_na(field_value VARCHAR2) 
    RETURN VARCHAR2 IS
    return_value VARCHAR2(100);
    BEGIN
        IF field_value = 'NA' THEN
            return_value := NULL;
        ELSE
            return_value := field_value;
        END IF;
        RETURN return_value;
    END;
/

CREATE OR REPLACE FUNCTION marcotab.fix_age(age VARCHAR2)
    RETURN VARCHAR2 IS
    fixed_age VARCHAR2(100);
    BEGIN
        IF age IS NULL THEN
            fixed_age := NULL;
        ELSIF age = 'Under 18 years old' THEN
            fixed_age := '< 18';
        ELSIF age = '65 years or older' THEN
            fixed_age := '>= 65';
        ELSE
            fixed_age := REGEXP_SUBSTR(age, '[^ ]+', 1, 1);
        END IF;
        RETURN fixed_age;
    END;
/

CREATE OR REPLACE FUNCTION marcotab.fix_remote_work(remote_work VARCHAR2)
    RETURN VARCHAR2 IS
    fixed_work VARCHAR2(50);
    BEGIN 
        IF remote_work IS NULL THEN
            fixed_work := NULL;
        ELSIF remote_work = 'Hybrid (some remote, some in-person)' THEN 
            fixed_work := 'Hybrid';
        ELSE
            fixed_work := remote_work;
        END IF;
        RETURN fixed_work;
    END;
/

CREATE OR REPLACE FUNCTION marcotab.fix_so_time(utime VARCHAR2)
    RETURN VARCHAR2 IS
    fixed_time VARCHAR2(50);
    BEGIN
        IF utime IS NULL THEN
            fixed_time := NULL;
        ELSIF utime = 'Over 120 minutes a day' THEN
            fixed_time := '> 120 min/day';
        ELSIF utime = 'Less than 15 minutes a day' THEN
            fixed_time := '< 15 min/day';
        ELSE
            fixed_time := REGEXP_SUBSTR(utime, '[^ ]+', 1, 1) || 'min/day';
        END IF;
        RETURN fixed_time;
    END;
/

CREATE OR REPLACE FUNCTION marcotab.fix_main_branch(main_branch VARCHAR2)
    RETURN VARCHAR2 IS
    fixed_main_branch VARCHAR2(50);
    BEGIN
        IF main_branch IS NULL THEN
            fixed_main_branch := NULL;
        ELSIF main_branch LIKE '%hobby%' THEN
            fixed_main_branch := 'Hobby dev';
        ELSIF main_branch LIKE '%learning%' THEN
            fixed_main_branch := 'Student dev';
        ELSIF main_branch LIKE '%work%' THEN
            fixed_main_branch := 'Not dev but codes sometimes (work/studies)';
        ELSIF main_branch LIKE '%None%' THEN
            fixed_main_branch := 'Other';
        ELSE
            fixed_main_branch := 'Professional dev';
        END IF;
        RETURN fixed_main_branch;
    END;
/

CREATE OR REPLACE FUNCTION marcotab.fix_years_code(years_code VARCHAR2)
    RETURN NUMBER IS
    fixed_years NUMBER;
    BEGIN
        IF years_code IS NULL THEN
            fixed_years := NULL;
        ELSE
            BEGIN
                fixed_years := TO_NUMBER(years_code);
            EXCEPTION 
                WHEN VALUE_ERROR THEN
                    fixed_years := NULL;
            END;
        END IF;
        RETURN fixed_years;
    END;
/

CREATE OR REPLACE FUNCTION marcotab.fix_op_sys(os_sys VARCHAR2)
    RETURN VARCHAR2 IS
    fixed_os VARCHAR2(50);
    BEGIN
        IF os_sys IS NULL THEN
            fixed_os := NULL;
        ELSIF os_sys LIKE '%WSL%' THEN
            fixed_os := 'WSL';
        ELSIF os_sys LIKE '%ANDROID%' THEN
            fixed_os := 'ANDROID';
        ELSIF os_sys LIKE '%MAC%' THEN
            fixed_os := 'MACOS';
        ELSIF os_sys LIKE '%IOS%' THEN
            fixed_os := 'IOS';
        ELSIF os_sys LIKE '%WINDOWS%' THEN
            fixed_os := 'WINDOWS';
        ELSIF os_sys LIKE '%LINUX%'
            OR os_sys LIKE '%UBUNTU%'
            OR os_sys LIKE '%DEBIAN%'
            OR os_sys LIKE '%FEDORA%'
            OR os_sys LIKE '%CENTOS%'
            OR os_sys LIKE '%ARCH%'
            OR os_sys LIKE '%MANJARO%'
            OR os_sys LIKE '%MINT%'
            OR os_sys LIKE '%KALI%'
            OR os_sys LIKE '%RHEL%'
            OR os_sys LIKE '%SUSE%'
            OR os_sys LIKE '%GENTOO%'
            OR os_sys LIKE '%ALPINE%'
            OR os_sys LIKE '%ZORIN%'
            OR os_sys LIKE '%ELEMENTARY%' THEN
            fixed_os := 'LINUX';
        ELSE
            fixed_os := 'Other';
        END IF;
        RETURN fixed_os;
    END;
/

CREATE OR REPLACE FUNCTION marcotab.capitalize_and_trim(str VARCHAR2)
    RETURN VARCHAR2 IS
    return_str VARCHAR2(100);
    BEGIN
        IF str IS NULL THEN
            return_str := NULL;
        ELSE
            return_str := REGEXP_REPLACE(UPPER(str), '[[:space:]]*', '');
            IF return_str LIKE '%BASH%' THEN
                return_str := 'BASH/SHELL';
            END IF;
        END IF;
        RETURN return_str;
    END;
/


-- TENTEI DEIXAR O INSERT DATA DOS ANOS 2023-2021 GENERICOS POIS ELES SAO BEM PARECIDOS,
-- MAS NAO CONSEGUI E. TENTEI COLOCAR UM IF PARA VER SE O SELECT SERIA NA TABELA DE QUAL ANO E 
-- LOGO EM SEGUIDA DECLARAR O TIPO DA LINHA, SO QUE ISSO DINAMICO NÃO É TRIVIAL COMO ACHEI
-- POR ISSO UM PROCEDIMENTO PARA CADA ANO E AS ALTERNATIVAS QUE ENCONTREI FICAVAM MAIS COMPLICADAS DO QUE UTEIS

CREATE OR REPLACE PROCEDURE marcotab.insert_2022_data AS
        SURVEY_YEAR NUMBER := 2022;
        aux_split VARCHAR2(150);
        -- counter_aux NUMBER := 0;
        pos PLS_INTEGER;
        dev_auto_inc_id NUMBER;
        count_exists NUMBER;
        CURSOR cur_2022 IS SELECT * FROM STACKOVERFLOW.SO_2022;
        c STACKOVERFLOW.SO_2022%ROWTYPE;
    
    BEGIN
        OPEN cur_2022;
        LOOP
            FETCH cur_2022 INTO c;
            EXIT WHEN cur_2022%NOTFOUND;
            IF c.RESPONSEID = 'ResponseId' THEN
                CONTINUE;
            END IF;

            IF c.RESPONSEID IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'RESPONSEID cannot be NULL');
            ELSE

                -- Inserindo dev e retornando o valor auto incrementado
                INSERT INTO marcotab.developers (resp_id, survey_year, age, country, main_branch, remote_work, years_code, time_searching, time_answering)
                    VALUES (TO_NUMBER(c.RESPONSEID), SURVEY_YEAR, marcotab.fix_age(marcotab.checks_if_na(c.AGE)), marcotab.checks_if_na(c.COUNTRY), 
                            marcotab.fix_main_branch(marcotab.checks_if_na(c.MAINBRANCH)), marcotab.fix_remote_work(marcotab.checks_if_na(c.REMOTEWORK)), 
                            marcotab.fix_years_code(marcotab.checks_if_na(c.YEARSCODE)), marcotab.fix_so_time(marcotab.checks_if_na(c.TIMESEARCHING)), 
                            marcotab.fix_so_time(marcotab.checks_if_na(c.TIMEANSWERING)))
                    RETURNING id INTO dev_auto_inc_id;
                -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - DEV_ID: ' || dev_auto_inc_id);

                -- Separando LearnCode
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.LEARNCODE, '[^;]+', 1, pos); -- OPÇÃO DE COMBINAR COM A COLUNA LEARNCODEONLINE
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - LEARNCODE: ' || aux_split);
                    INSERT INTO marcotab.learning_methods (dev_id, learning_method) VALUES (dev_auto_inc_id, (aux_split));
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.LEARNCODE, '[^;]+', 1, pos);
                END LOOP;
                    
                -- Separando Languages
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.LANGUAGEHAVEWORKEDWITH, '[^;]+', 1, pos); 
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - LANGUAGEHAVEWORKEDWITH: ' || aux_split);
                    INSERT INTO marcotab.languages (dev_id, language) VALUES (dev_auto_inc_id, marcotab.capitalize_and_trim(aux_split));
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.LANGUAGEHAVEWORKEDWITH, '[^;]+', 1, pos);
                END LOOP;

                -- Separando OperatingSystems
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.OPSYSPROFESSIONALUSE, '[^;]+', 1, pos); -- OPÇÃO DE COMBINAR COM A COLUNA OPSYSPERSONALUSE
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    SELECT COUNT(*) INTO count_exists FROM marcotab.op_systems WHERE dev_id = dev_auto_inc_id AND op_system = marcotab.fix_op_sys(marcotab.capitalize_and_trim(aux_split));
                    IF count_exists = 0 THEN
                        -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - OPSYSPROFESSIONALUSE: ' || aux_split);
                        INSERT INTO marcotab.op_systems (dev_id, op_system) VALUES (dev_auto_inc_id, marcotab.fix_op_sys(marcotab.capitalize_and_trim(aux_split)));
                    END IF;
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.OPSYSPROFESSIONALUSE, '[^;]+', 1, pos);
                END LOOP;
                
                -- Separando Databases
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.DATABASEHAVEWORKEDWITH, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - DATABASEHAVEWORKEDWITH: ' || aux_split);
                    INSERT INTO marcotab.databases (dev_id, database) VALUES (dev_auto_inc_id, marcotab.capitalize_and_trim(aux_split));
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.DATABASEHAVEWORKEDWITH, '[^;]+', 1, pos);
                END LOOP;

                -- Separando DevTypes
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.DEVTYPE, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - DEVTYPE: ' || aux_split);
                    INSERT INTO marcotab.dev_types (dev_id, dev_type) VALUES (dev_auto_inc_id, aux_split);
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.DEVTYPE, '[^;]+', 1, pos);
                END LOOP;

            END IF;
            -- counter_aux := counter_aux + 1;
            -- EXIT WHEN counter_aux > 20;
        END LOOP;
        CLOSE cur_2022;
    END;
/

CREATE OR REPLACE PROCEDURE marcotab.insert_2023_data AS
        SURVEY_YEAR NUMBER := 2023;
        aux_split VARCHAR2(150);
        -- counter_aux NUMBER := 0;
        pos PLS_INTEGER;
        dev_auto_inc_id NUMBER;
        count_exists NUMBER;
        CURSOR cur_2023 IS SELECT * FROM STACKOVERFLOW.SO_2023;
        c STACKOVERFLOW.SO_2023%ROWTYPE;
    
    BEGIN
        OPEN cur_2023;
        LOOP
            FETCH cur_2023 INTO c;
            EXIT WHEN cur_2023%NOTFOUND;
            IF c.RESPONSEID = 'ResponseId' THEN
                CONTINUE;
            END IF;

            IF c.RESPONSEID IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'RESPONSEID cannot be NULL');
            ELSE

                -- Inserindo dev e retornando o valor auto incrementado
                INSERT INTO marcotab.developers (resp_id, survey_year, age, country, main_branch, remote_work, years_code, time_searching, time_answering, industries)
                    VALUES (TO_NUMBER(c.RESPONSEID), SURVEY_YEAR, marcotab.fix_age(marcotab.checks_if_na(c.AGE)), marcotab.checks_if_na(c.COUNTRY), 
                            marcotab.fix_main_branch(marcotab.checks_if_na(c.MAINBRANCH)), marcotab.fix_remote_work(marcotab.checks_if_na(c.REMOTEWORK)), 
                            marcotab.fix_years_code(marcotab.checks_if_na(c.YEARSCODE)), marcotab.fix_so_time(marcotab.checks_if_na(c.TIMESEARCHING)), 
                            marcotab.fix_so_time(marcotab.checks_if_na(c.TIMEANSWERING)), marcotab.checks_if_na(c.INDUSTRY))
                    RETURNING id INTO dev_auto_inc_id;
                -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - DEV_ID: ' || dev_auto_inc_id);

                -- Separando LearnCode
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.LEARNCODE, '[^;]+', 1, pos); -- OPÇÃO DE COMBINAR COM A COLUNA LEARNCODEONLINE
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - LEARNCODE: ' || aux_split);
                    INSERT INTO marcotab.learning_methods (dev_id, learning_method) VALUES (dev_auto_inc_id, (aux_split));
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.LEARNCODE, '[^;]+', 1, pos);
                END LOOP;
                    
                -- Separando Languages
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.LANGUAGEHAVEWORKEDWITH, '[^;]+', 1, pos); 
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - LANGUAGEHAVEWORKEDWITH: ' || aux_split);
                    INSERT INTO marcotab.languages (dev_id, language) VALUES (dev_auto_inc_id, marcotab.capitalize_and_trim(aux_split));
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.LANGUAGEHAVEWORKEDWITH, '[^;]+', 1, pos);
                END LOOP;

                -- Separando OperatingSystems
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.OPSYSPROFESSIONALUSE, '[^;]+', 1, pos); -- OPÇÃO DE COMBINAR COM A COLUNA OPSYSPERSONALUSE
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    SELECT COUNT(*) INTO count_exists FROM marcotab.op_systems WHERE dev_id = dev_auto_inc_id AND op_system = marcotab.fix_op_sys(marcotab.capitalize_and_trim(aux_split));
                    IF count_exists = 0 THEN
                        -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - OPSYSPROFESSIONALUSE: ' || aux_split);
                        INSERT INTO marcotab.op_systems (dev_id, op_system) VALUES (dev_auto_inc_id, marcotab.fix_op_sys(marcotab.capitalize_and_trim(aux_split)));
                    END IF;
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.OPSYSPROFESSIONALUSE, '[^;]+', 1, pos);
                END LOOP;
                
                -- Separando Databases
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.DATABASEHAVEWORKEDWITH, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - DATABASEHAVEWORKEDWITH: ' || aux_split);
                    INSERT INTO marcotab.databases (dev_id, database) VALUES (dev_auto_inc_id, marcotab.capitalize_and_trim(aux_split));
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.DATABASEHAVEWORKEDWITH, '[^;]+', 1, pos);
                END LOOP;

                -- Separando AITools (AISEARCHHAVEWORKEDWITH + AIDEVHAVEWORKEDWITH)
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.AISEARCHHAVEWORKEDWITH, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - AISEARCHHAVEWORKEDWITH: ' || aux_split);
                    INSERT INTO marcotab.ai_tools (dev_id, ai_tool) VALUES (dev_auto_inc_id, aux_split);
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.AISEARCHHAVEWORKEDWITH, '[^;]+', 1, pos);
                END LOOP;
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.AIDEVHAVEWORKEDWITH, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    SELECT COUNT(*) INTO count_exists FROM marcotab.ai_tools WHERE dev_id = dev_auto_inc_id AND ai_tool = aux_split;
                    IF count_exists = 0 THEN
                        -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - AIDEVHAVEWORKEDWITH: ' || aux_split);
                        INSERT INTO marcotab.ai_tools (dev_id, ai_tool) VALUES (dev_auto_inc_id, aux_split);
                    END IF;
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.AIDEVHAVEWORKEDWITH, '[^;]+', 1, pos);
                END LOOP;

                -- Separando AIUsage (AITOOLINTERESTEDINUSING e AITOOLCURRENTLYUSING)
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.AITOOLINTERESTEDINUSING, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - AITOOLINTERESTEDINUSING: ' || aux_split);
                    INSERT INTO marcotab.ai_usage (dev_id, ai_usage) VALUES (dev_auto_inc_id, aux_split);
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.AITOOLINTERESTEDINUSING, '[^;]+', 1, pos);
                END LOOP;
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.AITOOLCURRENTLYUSING, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    SELECT COUNT(*) INTO count_exists FROM marcotab.ai_usage WHERE dev_id = dev_auto_inc_id AND ai_usage = aux_split;
                    IF count_exists = 0 THEN
                        -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - AITOOLCURRENTLYUSING: ' || aux_split);
                        INSERT INTO marcotab.ai_usage (dev_id, ai_usage) VALUES (dev_auto_inc_id, aux_split);
                    END IF;
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.AITOOLCURRENTLYUSING, '[^;]+', 1, pos);
                END LOOP;

                -- Separando DevTypes
                pos := 1;
                aux_split := REGEXP_SUBSTR(c.DEVTYPE, '[^;]+', 1, pos);
                WHILE marcotab.checks_if_na(aux_split) IS NOT NULL LOOP
                    -- DBMS_OUTPUT.PUT_LINE('RESPONSEID: ' || c.RESPONSEID || ' - DEVTYPE: ' || aux_split);
                    INSERT INTO marcotab.dev_types (dev_id, dev_type) VALUES (dev_auto_inc_id, aux_split);
                    pos := pos + 1;
                    aux_split := REGEXP_SUBSTR(c.DEVTYPE, '[^;]+', 1, pos);
                END LOOP;

            END IF;
            -- counter_aux := counter_aux + 1;
            -- EXIT WHEN counter_aux > 20;
        END LOOP;
        CLOSE cur_2023;
    END;
/

BEGIN
    -- Limpando tabelas para inserção
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.languages CASCADE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.op_systems CASCADE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.databases CASCADE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.ai_tools CASCADE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.ai_usage CASCADE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.learning_methods CASCADE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.dev_types CASCADE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE marcotab.developers CASCADE';
    marcotab.insert_2022_data;
    marcotab.insert_2023_data;
END;
/
COMMIT;

-- DESCRIBE STACKOVERFLOW.SO_2022;
-- DESCRIBE STACKOVERFLOW.SO_2023;

SELECT COUNT(*) FROM MARCOTAB.DEVELOPERS;
SELECT * FROM STACKOVERFLOW.SO_2022 WHERE ROWNUM <= 20;
SELECT * FROM STACKOVERFLOW.SO_2023 WHERE ROWNUM <= 20;

SELECT op_system, COUNT(*) as count
FROM marcotab.op_systems
GROUP BY op_system;

SELECT country, COUNT(*) as count
FROM marcotab.developers
GROUP BY country;

SELECT * FROM MARCOTAB.DEVELOPERS WHERE ROWNUM <= 20;
SELECT * FROM MARCOTAB.LANGUAGES WHERE ROWNUM <= 20;
SELECT * FROM MARCOTAB.LEARNING_METHODS WHERE ROWNUM <= 20;
SELECT * FROM MARCOTAB.OP_SYSTEMS WHERE ROWNUM <= 20;
SELECT * FROM MARCOTAB.DATABASES WHERE ROWNUM <= 20;
SELECT * FROM MARCOTAB.AI_TOOLS WHERE ROWNUM <= 20;
SELECT * FROM MARCOTAB.AI_USAGE WHERE ROWNUM <= 20;
SELECT * FROM MARCOTAB.DEV_TYPES WHERE ROWNUM <= 20;

-- * Group by AI tools and count how many developers are using them in 2023
SELECT ai_tool, COUNT(*) AS count
FROM marcotab.ai_tools 
    JOIN marcotab.developers ON marcotab.developers.id = marcotab.ai_tools.dev_id
WHERE survey_year = 2023
GROUP BY ai_tool;

-- * Group by AI usage and count how many developers are using them in 2023
SELECT ai_usage, COUNT(*) AS count
FROM marcotab.ai_usage 
    JOIN marcotab.developers ON marcotab.developers.id = marcotab.ai_usage.dev_id
WHERE survey_year = 2023
GROUP BY ai_usage;

-- * Group by learning methods and count how many developers are using them in 2023 X 2022
SELECT learning_method,
       SUM(CASE WHEN survey_year = 2022 THEN 1 ELSE 0 END) AS count_2022,
       SUM(CASE WHEN survey_year = 2023 THEN 1 ELSE 0 END) AS count_2023
FROM marcotab.learning_methods 
    JOIN marcotab.developers ON marcotab.developers.id = marcotab.learning_methods.dev_id
WHERE survey_year IN (2022, 2023)
GROUP BY learning_method
ORDER BY learning_method;

-- *** 1. Market tendencys about AI tools and how they are being used by developers in 2023
SELECT ai_tool, ai_usage, MIN(marcotab.developers.age) AS age, COUNT(*) AS count
FROM marcotab.ai_tools 
    JOIN marcotab.developers ON marcotab.developers.id = marcotab.ai_tools.dev_id
    JOIN marcotab.ai_usage ON marcotab.developers.id = marcotab.ai_usage.dev_id
WHERE survey_year = 2023
GROUP BY ai_tool, ai_usage
ORDER BY ai_tool, ai_usage;

-- * Most commom programming language, op sys and database in each year
SELECT language, 
    SUM(CASE WHEN survey_year = 2022 THEN 1 ELSE 0 END) AS count_2022,
    SUM(CASE WHEN survey_year = 2023 THEN 1 ELSE 0 END) AS count_2023
FROM marcotab.languages
    JOIN marcotab.developers ON marcotab.developers.id = marcotab.languages.dev_id
WHERE survey_year IN (2022, 2023)
GROUP BY language
ORDER BY count_2023 DESC;

SELECT op_system, 
    SUM(CASE WHEN survey_year = 2022 THEN 1 ELSE 0 END) AS count_2022,
    SUM(CASE WHEN survey_year = 2023 THEN 1 ELSE 0 END) AS count_2023
FROM marcotab.op_systems
    JOIN marcotab.developers ON marcotab.developers.id = marcotab.op_systems.dev_id
WHERE survey_year IN (2022, 2023)
GROUP BY op_system
ORDER BY count_2023 DESC;

SELECT database, 
    SUM(CASE WHEN survey_year = 2022 THEN 1 ELSE 0 END) AS count_2022,
    SUM(CASE WHEN survey_year = 2023 THEN 1 ELSE 0 END) AS count_2023
FROM marcotab.databases
    JOIN marcotab.developers ON marcotab.developers.id = marcotab.databases.dev_id
WHERE survey_year IN (2022, 2023)
GROUP BY database
ORDER BY count_2023 DESC;

-- * Affected by the pandemic, how many developers in 2023 are working remotely and their country?
SELECT remote_work, country,
    SUM(CASE WHEN survey_year = 2022 THEN 1 ELSE 0 END) AS count_2022,
    SUM(CASE WHEN survey_year = 2023 THEN 1 ELSE 0 END) AS count_2023
FROM marcotab.developers
WHERE survey_year IN (2022, 2023) AND remote_work IS NOT NULL
GROUP BY remote_work, country
ORDER BY count_2023 DESC;

-- *** 2. AI USAGE for Debugging and Getting Help' in 2023 X TIME USING STACK OVERFLOW (ANSWERING AND SEARCHING) in 2023 X 2022
SELECT 'Debugging and getting help' AS AI_USAGE,
        time_searching, count_search_2023, count_search_2022, 
        count_answer_2023, count_answer_2022 
FROM 
(
    SELECT search2023.time_searching, search2023.count_search_2023, search2022.count_search_2022
    FROM 
    (
        SELECT time_searching, COUNT(*) as count_search_2023
        FROM marcotab.developers
            JOIN marcotab.ai_usage ON marcotab.developers.id = marcotab.ai_usage.dev_id
            WHERE (survey_year = 2023 AND time_searching IS NOT NULL
                AND ai_usage = 'Debugging and getting help')
        GROUP BY time_searching
    ) search2023

    JOIN 

    (
        SELECT time_searching, COUNT(*) as count_search_2022
        FROM marcotab.developers
            WHERE (survey_year = 2022 AND time_searching IS NOT NULL)
        GROUP BY time_searching
    ) search2022

    ON search2022.time_searching = search2023.time_searching
) full_search

JOIN 

(
    SELECT answer2023.time_answering, answer2023.count_answer_2023, answer2022.count_answer_2022 
    FROM 
    (
        SELECT time_answering, COUNT(*) as count_answer_2023
        FROM marcotab.developers
            JOIN marcotab.ai_usage ON marcotab.developers.id = marcotab.ai_usage.dev_id
            WHERE (survey_year = 2023 AND time_answering IS NOT NULL
                AND ai_usage = 'Debugging and getting help')
        GROUP BY time_answering
    ) answer2023

    JOIN

    (
        SELECT time_answering, COUNT(*) as count_answer_2022
        FROM marcotab.developers
            WHERE (survey_year = 2022 AND time_answering IS NOT NULL)
        GROUP BY time_answering
    ) answer2022

    ON answer2022.time_answering = answer2023.time_answering
) full_answer

ON full_answer.time_answering = full_search.time_searching;


-- Trying to improve query:

CREATE INDEX idx_developers_survey_year ON marcotab.developers(survey_year);

DROP INDEX idx_ai_usage;
CREATE INDEX idx_ai_usage ON marcotab.ai_usage(ai_usage);
DROP INDEX idx_ai_tools;
CREATE INDEX idx_ai_tools ON marcotab.ai_tools(ai_tool);
DROP INDEX idx_time_searching;
CREATE INDEX idx_time_searching ON marcotab.developers(time_searching);
DROP INDEX idx_time_answering;
CREATE INDEX idx_time_answering ON marcotab.developers(time_answering);