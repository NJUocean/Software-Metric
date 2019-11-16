use 5.010;
use strict;
use warnings; 
use Understand;

#打开文件写入表头
open(FILE, ">", "result.csv") || die "Cannot write result.\n";
print FILE "name,id,path,n1,n2,N1,N2,N,V,D,E,L,T\n";

#打开udb文件
(my $db,my $status)=Understand::open("/home/wangyang/workspace/understand/ex4.udb");

#获取function信息
foreach my $function($db->ents("function ~unknown ~unresolved")){
	#获取函数开始结束位置	
	my $startref = $function->refs("definein");
	next unless $startref;
	my $endref = $function->refs("end");
  	next unless $endref;	
	
	#获取函数信息
	my $id=$function->id();
	my $name=$function->longname();
	my $path=$startref->file->relname;
	my $lexer=$function->lexer();
	
	#调用函数获得函数对应的halstead度量信息
        my ($n1,$n2,$N1,$N2) = GetHalsteadBaseMetrics($lexer,$startref->line(),$endref->line());
	my $n=$n1+$n2;
	my $N=$N1+$N2;
	next if($n==0 or $N==0);#为空则跳过
	
	#得到函数的输入输出信息		
	my ($input,$output) = io($function);
	
	#得到函数最终的度量并写入
	my ($V,$D,$E,$L,$T)=GetHalsteadMetrics($input,$output,$n,$N);
	print FILE "$name,$id,$path,$n1,$n2,$N1,$N2,$N,$V,$D,$E,$L,$T\n";
}

$db->close();

close(FILE);

sub GetHalsteadBaseMetrics {
    my ($lexer,$startLine,$endLine) = @_;
    my $n1=0;
    my $n2=0;
    my $N1=0;
    my $N2=0;
    my %n1 = ();
    my %n2 = ();
    
    foreach my $lexeme ($lexer->lexemes($startLine,$endLine)) {
        if(($lexeme->token eq "Operator") ||
                ($lexeme->token eq "Keyword") ||
                ($lexeme->token eq "Punctuation")) {  
            if($lexeme->text() !~ /[)}\]]/) {
                $n1{$lexeme->text()} = 1;
                $N1++;
            }
        }elsif(($lexeme->token eq "Identifier") ||
                ($lexeme->token eq "Literal") || ($lexeme->token eq "String")){
            $n2{$lexeme->text()} = 1;
            $N2++;
        }
    } 
    
    $n1 = scalar(keys(%n1));
    $n2 = scalar(keys(%n2));  
    return ($n1,$n2,$N1,$N2);
} 

sub io
{
	my ($function) = @_;
	my $input = $function->metric("CountInput");
	my $output = $function->metric("CountOutput");

	my @used = ();
	for my $ref ($function->refs("call ~inactive"))
	{
		if ($ref->ent->id() eq $function->id())
		{
			next;
		}
		unless( grep {$_ eq $ref->ent->id()} @used )
		{
			push (@used,$ref->ent->id());
		}
	}
	$output = $output - @used;
	if($output < 0)
	{
		$output = 0;
	}
	@used = ();
	for my $ref ($function->refs("callby ~inactive"))
	{
		if ($ref->ent->id() eq $function->id())
		{
			next;
		}
		unless( grep {$_ eq $ref->ent->id()} @used)
		{
			push (@used,$ref->ent->id());
		}
	}
	$input = $input - @used;
	if($input < 0)
	{
		$input = 0;
	}
	return ($input,$output);
}



sub GetHalsteadMetrics{
	my ($input,$output,$n,$N)=@_;
	my $V=$N*log2($n);
	my $n2_star=$input+$output;
	my $V_star=(2+$n2_star)*log2(2+$n2_star);
	my $D=$V/$V_star;
	my $E=$V*$D;
	my $L=$V_star/$V;
	my $T=$E/18;
	return ($V,$D,$E,$L,$T);
}


sub log2 {
	my $n = shift;
	return log($n)/log(2);
}

