

alter table [dbo].[insert_Sale]
add [StarDate] [datetime]

update [dbo].[Sale]
set [Region] = 'Souther'
where Sale_ID = 1
go

select * from [dbo].[Sale] where Sale_ID = 1
select * from [dbo].[insert_Sale] where Sale_ID = 1

update [dbo].[Sale]
set [Units_Sold] = '1000'
where Sale_ID = 2
go

select * from [dbo].[Sale] where Sale_ID = 2
select * from [dbo].[insert_Sale] where Sale_ID = 2

update [dbo].[Sale]
set [Product] = 'Women dress'
where Sale_ID = 3
go

select * from [dbo].[Sale] where Sale_ID = 3
select * from [dbo].[insert_Sale] where Sale_ID = 3