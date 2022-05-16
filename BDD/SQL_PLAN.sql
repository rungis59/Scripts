select timestamp,
       operation,
	   position,
	   depth,
	   id,
	   options,
	   object_owner,
	   object_name,
	   object_alias,
	   object_type,
	   parent_id,
	   cost,
	   cardinality,
	   cpu_cost,
	   io_cost,
	   filter_predicates,
	   remarks
from v$sql_plan
where object_type = 'TABLE'
 and object_owner = 'PTD'
 and timestamp >= '15/08/2012'
order by timestamp, position, depth;