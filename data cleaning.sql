-- data cleaning
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or Blank values
-- 4. Remove any columns


-- create new table dummy of layoff table
select * from layoffs;

create table layoffs_Staging like layoffs;

select * from layoffs_staging;

-- insert data copy from layoff table
insert layoffs_staging select * from layoffs;

-- partition by row_number in layoffs_staging table

select *, 
ROW_NUMBER() over(
PARTITION BY company, industry, total_laid_off,percentage_laid_off,'date') as row_num
from layoffs_staging;

-- now make CTE for updatinig row_num

with duplicate_cte as
(
select *, 
ROW_NUMBER() over(
PARTITION BY company,location, industry, total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte  where row_num >1 ;

select * from layoffs_staging where company='casper';

-- creating new table of layoffs_staging2

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;
-- inisert query for layoffs_staging2
insert into layoffs_staging2
select *, 
ROW_NUMBER() over(
PARTITION BY company,location, industry, total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging;

select * from layoffs_staging2  where row_num >1;

-- deleting row_num>1 values
delete from layoffs_staging2 where row_num > 1;

select * from layoffs_staging2  where row_num >1;

-- standarising data(removing white space ,duplicate name,etc)

select company ,trim(company) from layoffs_staging2;

-- update table - layoffs_Staging2

update layoffs_staging2 set company=trim(company);

select * from layoffs_staging2;

select * from layoffs_staging2 where industry like 'crypto%';
update layoffs_staging2 set industry='crypto' where industry like 'crypto%';

select distinct country, trim(trailing '.' from country) from layoffs_staging2 where country like'united %' order by 1;

update layoffs_staging2 set country=trim(trailing '.' from country) where country like 'united states %';

select distinct country from layoffs_staging2 ;

SELECT date from layoffs_staging2;

select `date`, STR_TO_DATE(`date`, '%m/%d/%Y') from layoffs_staging2;

update layoffs_staging2 set  `date` =STR_TO_DATE(`date`, '%m/%d/%Y') ;

alter table layoffs_staging2 modify column `date` DATE; -- this query use for alter column directly without changes in table

-- remove null / blank space from data/ raws & columns

select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

select * from layoffs_staging2 t1 join layoffs_staging2 t2 on t1.company= t2.company
where(t1.industry is null or t1.industry ='') and t2.industry is not null;
-- update industry column data

update layoffs_staging2 t1 join layoffs_staging2 t2 on t1.company= t2.company
set t1.industry= t2.industry where (t1.industry  is null or t1.industry ='')
and t2.industry is not null;

-- deleting total_laid_off & percentage_laid_off null values
select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
delete  from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

select * from layoffs_staging2;

alter table layoffs_staging2 drop column row_num;
