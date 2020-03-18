/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */

USE sqlprojdb1;

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT DISTINCT 
	`name` 
from Facilities 
where 
	`membercost` != 0
order by `name`;

/* Q2: How many facilities do not charge a fee to members? */

select 
	Count(`name`) as Facility_Cnt
from Facilities
where
	membercost = 0;


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

Select 
	facid,
    name,
    membercost,
    0.20 * monthlymaintenance,
    monthlymaintenance
from Facilities
where membercost > 0
and membercost < 0.2 * monthlymaintenance;


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

Select
	facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance

from facilities

where facid = 1 or facid = 5;

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

Select
	facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance,
    case 
		when 
			monthlymaintenance > 100 then 'Expensive'
		else
			'Cheap'
		end as Cheap_or_Expensive
	
from facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

Select 
firstname,
surname
from members b
inner join
	(Select 
		max(joindate) as max_joindate 
	from members) a 
	on a.max_joindate = b.joindate;
    
/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select distinct
concat(mb.firstname, " ", mb.surname) as Member_Name,
fc.name
from bookings bk
left join facilities fc
on bk.facid = fc.facid

left join members mb
on bk.memid = mb.memid

where 
	fc.name like 'Tennis Court%'
	and	mb.firstname != 'GUEST'

order by Member_Name;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
 
select 
	fac.name,
	
    case
		when 
        mem.memid = 0 then 'Guest'
        else
		concat(mem.firstname, ' ', mem.surname) 
	end as Member_Name,
	
    case
		when 
        mem.memid = 0 then sum(guestcost)
        else
		 sum(membercost) 
	end as Cost
	
	from bookings bk
	left join facilities fac
	on fac.facid = bk.facid
    
    left join members mem
    on
    bk.memid = mem.memid


	where 
		date(bk.starttime) = '2012-09-14'


	group by
	bk.facid,
	bk.memid
	
    having 
    cost > 30
    
    order by
    cost DESC
    

    ;



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

Select a.*

from
	(select 
		fac.name,
		
		case
			when 
			mem.memid = 0 then 'Guest'
			else
			concat(mem.firstname, ' ', mem.surname) 
		end as Member_Name,
		
		case
			when 
			mem.memid = 0 then sum(guestcost)
			else
			 sum(membercost) 
		end as Cost
		
		from bookings bk
		left join facilities fac
		on fac.facid = bk.facid
		
		left join members mem
		on
		bk.memid = mem.memid


		where 
			date(bk.starttime) = '2012-09-14'


		group by
		bk.facid,
		bk.memid ) a

where cost > 30

order by 
cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select bk.facid,
fac.name,
sum(
	case when bk.memid = 0 then fac.guestcost
		else fac.membercost
	end ) as revenue

from bookings bk
left join facilities fac
on bk.facid = fac.facid

group by 
bk.facid,
fac.name

having revenue <1000

order by 
revenue
;