-- run: `sqlite3 db <sol1.sql`

drop table nums;

create table if not exists nums (n int);


.import prob.in nums

insert into nums values (0);
insert into nums select max(n) + 3 from nums;

with pairs as (
    select n, (select min(n) from nums n2 where n2.n > n1.n) as next
    from nums n1
    order by n
),
counts as (
    select
        (select count(next) from pairs where next - n = 1) as ones,
        (select count(next) from pairs where next - n = 2) as twos,
        (select count(next) from pairs where next - n = 3) as threes
)
select ones, twos, threes, ones * threes as answer from counts;
