delete from veh_etal 
where ( mnt_prs = 0 or mnt_prs is null )
and num_int_etp in (select num_int_etp from veh_etap where dat_val is not null );