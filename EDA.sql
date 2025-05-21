-- Exploratory Data Analysis

select *
from layoffs_staging3
;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging3
;

select *
from layoffs_staging3
where percentage_laid_off = 1
order by funds_raised_millions desc
;

select company, sum(total_laid_off)
from layoffs_staging3
group by company
order by 2 desc					#### use number to replace sum column
;

select min(`date`),max(`date`)	#### figure out the time frame
from layoffs_staging3
;

select industry, sum(total_laid_off)
from layoffs_staging3
group by industry
order by 2 desc
;

select country, sum(total_laid_off)
from layoffs_staging3
group by country
order by 2 desc
;

select year(`date`), sum(total_laid_off)		#### group by time series
from layoffs_staging3
group by year(`date`)
order by 1 desc
;


-- rolling sum in the time series
select substring(`date`,1,7) as `month`,			#### take out the month using subtring
sum(total_laid_off)
from layoffs_staging3
where substring(`date`,1,7) is not null				#### exclude the null
group by `month`
order by 1 asc
;

with rolling_total as
(
select substring(`date`,1,7) as `month`,
sum(total_laid_off) as total_off
from layoffs_staging3
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off,
sum(total_off) over(order by `month`) as rolling_total		#### use over()to aggregate
from rolling_total
;

-- look into the company level (who laid off the most per year?)
select company, year(`date`),
sum(total_laid_off)
from layoffs_staging3
where substring(`date`,1,7) is not null				
group by company, year(`date`)
order by company asc
;

with Company_Year(company, years, total_laid_off) as		#### change title
(
select company, year(`date`),
sum(total_laid_off)
from layoffs_staging3
where substring(`date`,1,7) is not null				
group by company, year(`date`)
),
Top_five_ranking as							#### second CTE to add ranking & within top 5
(
select *, 
dense_rank() over(partition by(years)order by total_laid_off desc) as `ranking`
from Company_Year
order by ranking asc						#### the last function to answer the question
)
select *
from Top_five_ranking
where ranking <= 5							#### filter on the rank cuz second CTE
order by years
;