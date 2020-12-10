-- run: `sqlite3 db <sol2.sql`
-- requires sqlite 3.28+

.header on
.mode column

drop table nums;

create table if not exists nums (n int);

.import prob.in nums

insert into nums values (0);
insert into nums select max(n) + 3 from nums;

-- each value paired with the following value
with pairs as (
    select n, (select min(n) from nums n2 where n2.n > n1.n) as next
    from nums n1
    order by n
),
-- find the difference between each pair (i.e. each row), then rank them
ranked as (
    select n, next, next - n as diff,
        row_number() over (order by next-n, n) as rank_in_diff
    from pairs
    order by n
),
grouped as (
    -- `n-rank_in_diff` uniquely identifies a contiguous run of the same `diff`. `rank_in_diff` will have a gap iff the
    -- `diff` changes between two rows, but will increase by 1 between rows of the same `diff`. that means subtracting from
    -- n only identifies the gaps, which is what we want.
    select n, diff, n-rank_in_diff as group_id,
        count(diff)
        filter (where diff=1)
        over (partition by diff, n-rank_in_diff order by diff, n-rank_in_diff groups between unbounded preceding and unbounded following) as group_length
    from ranked
    order by n),
counted as (
    -- each group is now a contiguous run of `group_length` 1s.  Each run of 1s contributes a number of adapter
    -- combinations based on its length.
    select group_id, group_length,
    case group_length
        when 1 then 1
        when 2 then 2
        when 3 then 4 -- 3 1s can be combined four ways: 111 21 12 3
        when 4 then 7 -- 4 1s can be combined seven ways: 1111 112 121 211 31 13 22
    end as value
    from grouped
    where group_length != 0
    group by group_id, group_length
)
-- the final answer is the product of all those combination counts. sqlite can't do this, whoops.
select group_concat(value, "*") from counted;
