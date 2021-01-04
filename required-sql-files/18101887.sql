-- 1a1
 select
	*
from
	((banghocvan b
join chungchi c on
	b.bhv_machungchi = c.cc_machungchi) as bc
join nguoilaodong n2 on
	n2.nld_quoctich = bc.cc_quoctich
	and n2.nld_masocmnd = bc.cc_masocmnd)
where
	n2.nld_quoctich = 'Viet Nam'
order by
	n2.nld_ngaysinh ;
--1a2
 select
	*
from
	((khoahoconline k
join chungchi c on
	k.kho_machungchi = c.cc_machungchi) as kc
join nguoilaodong n2 on
	n2.nld_quoctich = kc.cc_quoctich
	and n2.nld_masocmnd = kc.cc_masocmnd)
where
	extract (year
from
	kc.kho_ngayhoanthanh) < 2021
order by
	k.kho_ngayhoanthanh ;
--1b1
 select
	nld_ngaysinh,
	truong,
	nld_ho,
	nld_tendem,
	nld_ten,
	bhv_gpa,
	bhv_nambatdau
from
	(((
	select
		bhv_truong as truong
	from
		banghocvan b
	group by
		bhv_truong
	having
		avg(bhv_gpa) > 5.0) as truong_temp
join banghocvan b2 on
	b2.bhv_truong = truong_temp.truong)) as truong_co_trung_bing_gpa_tu_5_tro_len
join chungchi c on
	truong_co_trung_bing_gpa_tu_5_tro_len.bhv_machungchi = c.cc_machungchi
join nguoilaodong n on
	c.cc_masocmnd = n.nld_masocmnd
	and c.cc_quoctich = n.nld_quoctich
where
	extract(year
from
	n.nld_ngaysinh) < 2000
order by
	bhv_namtotnghiep ;
--1b2
 select
	avg(extract (year from age(nld_ngaysinh))),
	bpv_ketquapv
from
	( (
	select
		*
	from
		(((buoiphongvan b
	join thamgiapv t2 on
		b.bpv_quoctich = t2.tgpv_quoctich_nguoixinviec
		and b.bpv_masocmnd = t2.tgpv_masocmnd_nguoixinviec)
	join nhanvien n2 on
		tgpv_quoctich_nv = n2.nv_quoctich
		and tgpv_masocmnd_nv = n2.nv_masocmnd)
	join nguoilaodong on
		nv_quoctich = nld_quoctich
		and nv_masocmnd = nld_masocmnd)) as subq natural
join thamgiapv )
where
	nv_quoctich = 'Viet Nam'
group by
	bpv_ketquapv
having
	min(extract (year from nld_ngaysinh)) > 20 ;