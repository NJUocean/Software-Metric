use 5.010;
use strict;
use warnings;
use Understand;

#读取udb文件
(my $db, my $status)=Understand::open("/home/wangyang/workspace/understand/patch.udb");
die "Error opening database: ",$status,"\n" if $status;

#获取函数实体
my @f = $db->ents("function ~unknown ~unresolved");

#创建记录函数信息的列表
my @f_info=();

#遍历函数保存路径名称内容信息
foreach my $function (@f){
	my $name=$function->name();
	my $contents=$function->contents();
	next unless (defined $contents);
	my $ref = $function->ref("definein");
	next unless (defined $ref);
	my $path = $ref->file()->relname();
	
	#为每个函数构造一个map实体，压入函数列表
	my %function_info=();
	$function_info{name}=$name;
	$function_info{c}=$contents;
	$function_info{bugs}=0;
	$function_info{'path'}=$path;
	push(@f_info,\%function_info);
}
$db->close();

#获取所有补丁信息
my $dir = "/home/wangyang/桌面/ex2_151278035_王洋/patch/*";
my @patches = glob( $dir );

#按顺序依次打上补丁，每打一次，调用understand重新分析，找出被改变的函数
foreach my $patch ($patches){
	
	#打补丁并调用understand
	say `patch -p1 < $t`;
	say `/home/wangyang/software/scitools/bin/linux64/und analyze -all /home/wangyang/workspace/understand/patch.udb`;
	
	#打开重新分析后的understand，获取函数实体列表
	(my $db, my $status) = Understand::open("/home/wangyang/workspace/understand/patch.udb");
	die "Error opening database: ",$status,"\n" if $status;
	my @f = $db->ents("function ~unknown ~unresolved");
	
	#遍历该列表，与补丁前的函数信息进行对比
	foreach my $function (@f){
		my $name=$function->name();
		my $contents=$function->contents();
		next unless (defined $contents);
		my $ref = $function->ref("definein");
		next unless (defined $ref);
		my $path = $ref->file()->relname();
	
		foreach my $item(@f_info){
			if ($$item{path} eq $path and $$item{name} eq $name){
				if($$item{contents} ne $contents){
					$$item{bugs}+=1;
					$$item{contents}=$contents;			
				}
				next;
			{
	}
	$db->close();
}		
}

#输出分析结果
open(FILE,">","/home/wangyang/workspace/understand/result.csv") || die "cannot open file\n";
print FILE "name,bugs,path\n";
foreach my $t (@f_info)
{
	print FILE "$$t{name},$$t{bugs},$$t{path}\n";
}
close(FILE);
