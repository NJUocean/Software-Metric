use 5.010;
use strict;
use warnings;
use Understand;

my @Input = qw/canonicalize_file_name catgets confstr ctermid ctermid cuserid dgettext 
dngettext fgetc fgetc unlocked fgets fgets_unlocked fpathconf fread fread_unlocked 
fscanf getc getchar getchar_unlocked getc_unlocked get_current_dir_name getcwd getdelim 
getdelim _getdelim getdents getenv gethostbyaddr gethostbyname gethostbyname2 gethostent 
gethostid getline getlogin getlogin_r getmsg getopt _getopt_internal getopt_long 
getopt_long_only getpass getpmsg gets gettext getw getwd ngettext pathconf pread pread64 
ptsname ptsname_r read readdir readlink readv realpath recv recv_from recvmesg scanf 
_secure_getenv signal sysconf ttyname ttyname_r vfscanf vscanf/;

my @Output = qw /dprintf fprintf fputc fputchar_unlocked fputc_unlocked fputs fputs_unlocked 
fwrite fwrite_unlocked perror printf psignal putc putchar putc_unlocked putenv putmsg putpmsg 
puts putw pwrite pwrite64 send sendmsg sendto setenv sethostid setlogin ungetc vdprintf vfprintf 
vsyslog write writev/;

#本次实验仅下载了proftpd-1.3.5b
(my $db, my $status) = Understand::open("/home/wangyang/workspace/understand/ex5.udb");
die "Error opening database:",$status,"\n" if $status;
open FILE_Input, ">result_input.csv";
open FILE_Output, ">result_output.csv";
print FILE_Input "id,funcPath,funcName\n";
print FILE_Output "id,funcPath,funcName\n";

foreach my $func($db->ents("function ~unknown ~unresolved")){
	my $ref=$func->refs("definein");
	next unless $ref;
	
	my $abpath=$ref->file()->relname();	
	my $id=$func->id();
	my $name=$func->name();
	#判断是否调用了@Input中的函数
	if(isDEP($func)==1){
		print FILE_Input "$id,$abpath,$name\n";
	}
	#判断是否调用了@Output中的函数
	if(isDExP($func)==1){
		print FILE_Output "$id,$abpath,$name\n";
	}
}
close(FILE_Input);
close(FILE_Output);
$db->close();

sub isDEP{
	my ($func) = @_;
	foreach my $ref($func->refs("call ~inactive")){
		if(grep{$ref->ent->name() eq $_} @Input){
			return 1;
		}			
	}
	return 0;
}
sub isDExP{
	my ($func) = @_;
	foreach my $ref($func->refs("call ~inactive")){
		if(grep{$ref->ent->name() eq $_} @Output){
			return 1;
		}
	}
	return 0;
}

