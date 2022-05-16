create table veh_trsp_doublons as (
	   		 	select distinct c.num_veh, c.num_int_trp
				from veh_trsp a, veh_trsp b, veh_trsp c, veh_ente d
				where 	a.num_veh=b.num_veh 
				and 	d.num_veh=c.num_veh
				and 	b.num_veh=c.num_veh
				and 	c.num_veh=a.num_veh
				and 	d.num_veh=b.num_veh
				and d.typ_clo='O'
				and c.cod_tra_ord= 'MARITIME'
				and	a.cod_tra_ord= 'MARITIME'
				and b.cod_tra_ord='MARITIME' 
				and a.cod_trs_dep=b.cod_trs_dep 
				and a.cod_trs_dst=b.cod_trs_dst
				and a.lib_ord <> b.lib_ord
				and a.dat_tsm <> b.dat_tsm 
				and (c.dat_tsm < b.dat_tsm or c.dat_tsm < a.dat_tsm)
)
	