create view ConsumedFoodsCals as
select MealId, UserId, FoodId, FoodTitle, (Amount * Weight * Cals / 100) as TotalCals
from Meals
         natural join MealsFoodsAmount
         natural join Foods;

-- Найти самый калорийный продукт(id и название) который ел пользователь в рамках одного приема пищи
select FoodId, FoodTitle, TotalCals
from ConsumedFoodsCals
where UserId = 1 -- :UserId
order by TotalCals desc
limit 1;

-- Найти самый калорийный прием пищи(id и название) пользователя
select MealId, MealTitle
from Meals
         natural join
     (select MealId
      from ConsumedFoodsCals
      where UserId = 2 -- :UserId
      group by MealId
      order by sum(TotalCals) desc
      limit 1) as BiggestMeal;

-- Найти пользователя(id и имя) с самой большой разницой в весе по истории записей
select Users.UserId
from Users
         inner join Logs on Users.UserId = Logs.UserId
group by Users.UserId
order by max(Logs.Weight) - min(Logs.Weight) desc
limit 1;

-- Найти стратегию(id и название) которая содержит больше всего калорий в предлагаемой еде
select StrateGyId, StrategyTitle
from strategies
         natural join
     (select Strategyid
      from Strategies
               natural join Days
               natural join DaysFoodsAmount
               inner join Foods on Foods.foodid = DaysFoodsAmount.foodid
      group by StrategyId
      order by sum(Amount * Weight * Cals / 100) desc
      limit 1) as MostCaloriesStrategy;

-- Найти стратегию(id и название) которая содержит больше всего тренировок
select StrateGyId, StrategyTitle
from strategies
         natural join
     (select StrategyId
      from Strategies
               natural join Days
               natural join DaysWorkoutsOrder
      group by StrategyId
      order by count(WorkoutId) desc
      limit 1) as MostDiffucultStrategy;

-- Найти самую длинную(по кол-ву дней) стратегию(id и название)
select StrategyId, StrategyTitle
from Strategies
         natural join
     (select StrategyId
      from Days
      group by StrategyId
      order by count(*) desc, strategyid asc
      limit 1) as LongestStrategy;

-- Найти самую популярную тренировку
select WorkoutId, WorkoutTitle
from Workouts
         natural join
     (select WorkoutId
      from Activities
      group by WorkoutId
      order by count(*) desc
      limit 1) as MostPopularWorkout;

-- Найти пользователя(или пользователей, если таких несколько, id и имена) с самой длинной активностью
select UserId, Name
from Users
         natural join
     (select distinct UserId
      from Activities
      where EndedAt - StartedAt = (select max(EndedAt - StartedAt) from Activities)) as LongestActivityUsers;

-- Общее количество продуктов, тренировок и стратегий созданных пользователем
select (select count(*) from Foods where OwnerId = 1) + -- :UserId
       (select count(*) from Workouts where OwnerId = 1) + -- :UserId
       (select count(*) from Strategies where OwnerId = 1) as TotalCreatedCount; -- :UserId

-- кол-во потребленных пользователем продуктов
select count(FoodId)
from ConsumedFoodsCals
where UserId = 1; -- :UserId

-- Найти тренировки пользователя выполненные больше месяца назад
select ActivityId, ActivityTitle, WorkoutId, WorkoutTitle
from Workouts
         natural join
     (select ActivityId, ActivityTitle
      from Activities
      where UserId = 2 -- :UserId
        and StartedAt < now()::timestamptz - interval '1 month') OldActivities;

-- Найти все продукты с высоким содержанием углеводов
select FoodId, FoodTitle
from Foods
where Carbs > 50;