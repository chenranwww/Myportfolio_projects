-- Data cleaning


-- 1. remove duplicates
-- 2. standardize the data
-- 3. null values or blank values
-- 4. remove any columns


create table layoffs_staging        #### create a duplicate to work on in case delet info
like layoffs;

select *							#### this duplicate only have title
from layoffs_staging;

insert layoffs_staging				#### insert data into the form
select *
from layoffs;

-- remove duplicates				###############################
select *,							#### add row_num column to detect duplicate
row_number() over(					#### but not add into the original table yet
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;


with duplicate_cte as				#### add row_num column to detect duplicate
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

select *								#### check if the results are correct
from layoffs_staging
where company = 'Casper';



CREATE TABLE `layoffs_staging2` (		#### create a table with the extra column to delete the duplicates
  `company` text,						#### copy to clipboard => a create statement
  `location` text,						#### this move only have title
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



select *
from layoffs_staging3
;

select *
from layoffs_staging
;


select *
from layoffs_staging2
where row_num > 1;



insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

insert into layoffs_staging3		#### add the row_num column into the table
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging2;

delete								#### delete the duplicates
from layoffs_staging3
where row_num >1;

select *
from layoffs_staging3
;

-- Standardizing data				########################
-- Typo issue						#################################
select company, trim(company)		#### delete the spaces
from layoffs_staging2
;

update layoffs_staging2				#### update
set company = trim(company);

select distinct country				#### use select distinct first to read through the names column by col and modify
from layoffs_staging2				#### also can use this to check after update
order by 1								#### also use order by 1 to see it clearer
;

update layoffs_staging2					#### update it here 
set industry = 'Crypto'
where industry like 'Crypto%'
;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%'
;

-- data type issue					#################################
select `date`,						#### covert string into date
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2
;

update layoffs_staging2				#### update date formate
set `date` = str_to_date(`date`, '%m/%d/%Y')
;


alter table layoffs_staging2		#### alter data type to date
modify column `date` date;

-- null and blank issue				#################################

select *
from layoffs_staging2
where industry is null
or industry = '';					#### search blank do not need to press space

select *
from layoffs_staging2
where company = 'Airbnb'			#### filling with travel, can also change all space into null
;

select *							#### by self join
from layoffs_staging2 st1
join layoffs_staging2 st2
	on st1.company = st1.company
    and st1.location = st2.location		#### rule out the company with same name in differnt location
where (st1.industry is null or st1.industry = '')
and st2.industry is not null;

update layoffs_staging2 st1
join layoffs_staging2 st2
	on st1.company = st1.company
    and st1.location = st2.location
set st1.industry = st2.industry
where (st1.industry is null or st1.industry = '')
and st2.industry is not null;


select *							
from layoffs_staging2
where total_laid_off is null		#### is null not = null
and percentage_laid_off is null;	#### might be invaluable

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- remove any columns			###################

select *						#### review again
from layoffs_staging3;

alter table layoffs_staging2	#### delete the whole column
drop column row_num;

alter table layoffs_staging3
drop column row_num;