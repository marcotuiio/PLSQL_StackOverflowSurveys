# Assignment 1 - BD2 - 2023.2
## Marco Tulio Alves de Barros
## Data integration and cleaning from StackOverflow surveys 2022-2023

### Introduction

This is a University Assignment for the Database II course, 2023.2. The goal is to integrate and clean data from StackOverflow surveys using PL/SQL in Oracle Database.

Using the surveys available at: https://insights.stackoverflow.com/survey

As we were granted some liberty and need to use our creativity, I decided to focus on the AI tools and languages used by developers in 2023 (using also 2022), and how they are related to the developers' age, years of experience, and country.

### Ideas in mind (02/04/2024)

- Columns of interest (may change):
* 2023: Age, MainBranch, RemoteWork, LearnCode, YearsCode, Country, LanguageHaveWorkedWith, DatabaseHaveWorkedWith, OpSysProfessional, AISearchHaveWorkedWith, AIDevHaveWorkedWith, AIToolCurrently Using, ProfessionalTech, TimeSearching, TimeAnswering, Industry (2023)

* 2022: Age, MainBranch, RemoteWork, LearnCode, YearsCode, Country, TimeSearching, TimeAnswering, LanguageHaveWorkedWith, DatabaseHaveWorkedWith, OpSysProfessional, ProfessionalTech, (2022)

With these data I inteend to analyze the following questions:
* Relations between Age x Used languages/databases x AI tools x Professional role

* What is the average age of developers in 2023 that work with AI? And prefered methods to learn code
* What is the average number for years of experience of developers in 2023 that work with AI? And prefered methods to learn code

* What is the most common programming language/database/database used by developers in 2023 that work with AI?

* Affected by the pandemic, how many developers in 2023 are working remotely and their country?

* Market tendencys about AI tools and how they are being used by developers in 2023

* Group by AI tools and count how many developers are using them in 2023
* Group by programming language/database/OpSys and count how many developers are using them in 2023

* Group by industry, gather all AI uses in them, then order by the field that has the most uses in 2023

### Challanges at first sight (02/04/2024)
* The years have different data types, as AI became very relevant in the 2023 survey. This wil require data cleaning and preparation in a way that seems homogeneous, to make possible compare and make a point on AI impact

* This will involve thinking of tables that are well integrated and dont seem to be (1) a mess of non-normalized data or (2) a bunch of tables that are not related at all and seem to be from different surveys

* Of course I will need to analyse the data better to filter what is actually needed, and then schematize the normalized tables

#### How to integrate two different surveys into one DB?

*Can this even be done in a way that makes sense?*

#### Draft of tables normalized (02/04/2024)

* Of course this is after padronizing the entrys and filtering trash

* Table 1:: Developers: id, age, country, survey_year, main_branch, remote_work, years_code, time_searching, time_answering
* Table 2:: Languages: language, developer_id
* Table 3:: Databases: database, developer_id
* Table 4:: AI_tools: ai_tool, developer_id
* Table 5:: Learning_methods: learning_method, developer_id
* Table 6:: Op_sys: op_sys, developer_id
* Table 7:: Ai_usage: developer_id, ai_usage
* Table 8:: Dev_types: developer_id, dev_type

#### Draft for logic flow (02/04/2024)

* 0. Insert all non-normalized data into a table
    - Create a table with all columns from the surveys
    - Insert all data from the surveys into this table
    - This will be the raw data

* 1. Create tables

* 2. Padronize data for every column (careful with commas, separations, typos, treat NA, trear possible nulls, etc)
    - 2.1. Age: careful with intervals, should this be integers?
    - 2.2. YearsCode: careful with intervals, should this be integers?
    - 2.3. MainBranch: convert to varchar and padronize -> MAYBE MERGE WITH DEVTYPE OR EVEN REPLACE
    - 2.4. RemoteWork: convert to varchar and padronize -> HERE I COULD TREAT AS WORK_MODEL AND IF ITS NULL ASSUME IS IN PERSON?
    - 2.5. LearnCode: convert to varchar, strip in the separator and insert by padronized name and dev id
    - 2.6. Country: convert to varchar and padronize
    - 2.7. LanguageHaveWorkedWith: convert to varchar, strip in the separator and insert by padronized name and dev id
    - 2.8. DatabaseHaveWorkedWith: convert to varchar, strip in the separator and insert by padronized name and dev id
    - 2.9. OpSysProfessional: convert to varchar and padronize
    - 2.10. AISearchHaveWorkedWith: convert to varchar, strip in the separator and insert by padronized name and dev id
    - 2.11. AIDevHaveWorkedWith: convert to varchar, strip in the separator and insert by padronized name and dev id
    - 2.12. AIToolCurrently Using: convert to varchar, strip in the separator and insert by padronized name and dev id
    - 2.13. ProfessionalTech: convert to varchar and padronize
    - 2.14. TimeSearching: careful with intervals, should this be integers?
    - 2.15. TimeAnswering: careful with intervals, should this be integers?
    - 2.16. Industry: convert to varchar and padronize

    - HELP: (ps use  REGEXP_REPLACE to strip commas and other characters, and REGEXP_SUBSTR to split strings by commas, and TRIM to remove spaces, and UPPER to make everything uppercase, and TO_NUMBER to convert to numbers, and TO_CHAR to convert to varchar, and so on)

* 3. Insert data into tables

* 4. Query data

* 5. Analyze data and check what can be done to improve the queries, like indexes, etc

#### Writing Scritps (06/04/2024 and 07/04/2024)

#### Explain how Oracle performs the queries (13/07/2024)

* The two main queries were (i left other in the script to test and make some other conclusions on how to aproach this):
    1. Market tendencys about AI tools and how they are being used by developers in 2023: This query is to analyze the market tendencys about AI tools and how they are being used by developers in 2023. The goal is to group by AI tools and count how many developers are using them in 2023. Initially this one would be used as part of another query to analyse the tendencies for the most popular languages, databases and opsystems or the typical profile of the users (and maybe sometime I will make it complete as this demands more effort to elaborate), but for now its a simple join and count on the three main tables.

    2. AI USAGE for Debugging and Getting Help' in 2023 X TIME USING STACK OVERFLOW (ANSWERING AND SEARCHING) in 2023 X 2022: Obviously the main use for stackoverflow is debbuging and getting help or ideas from others, so this query is to compare how much the chatbots and AI tools affected the time spent on stackoverflow (I do not consider the other use types for stackoverflow in 2023).
    
    To improve these queries I thought of creating an index for the AI tools and usage, but it didnt improve the query, as the default were able to take care of joins or selects, even though most quereis didnt even use them, but the were useful for fast table scans. Maybe something that could improve a bit is to think of some very specific combined index, with AI tool and usage, as these are the focus of my analysis, but I couldnt find one that worked.
