use Understand;
use Spreadsheet::WriteExcel; 

#读取udb文件
$db = Understand::open("C:\\workspace\\understandworkspace\\practise1.udb");

#获取函数实体
my @ents = $db->ents("function ~unknown ~unresolved");

#新建EXCEL文件  
my $workbook = Spreadsheet::WriteExcel->new('gnuit.csv');  

#添加工作表  
$worksheet = $workbook->add_worksheet(); 

#新建样式  
$format = $workbook->add_format(); # Add a format 
$format->set_bg_color('black');#背景设为黑色
$format->set_bold();#字体设为粗体  
$format->set_color('white');#字体设为红色  
$format->set_align('center');#单元格居中    
  
#设置表头  
$worksheet->write(0,0,'Name',$format); 
$worksheet->write(0,1,'CountLineCode',$format);  
$worksheet->write(0,2,'CountPath',$format);  
$worksheet->write(0,3,'Cyclomatic',$format);  
$worksheet->write(0,4,'MaxNesting',$format);
$worksheet->write(0,5,'Knots',$format);   
$worksheet->write(0,6,'CountInput',$format);  
$worksheet->write(0,7,'CountOutput',$format);
$worksheet->write(0,8,'RelPath',$format);

#行变量
$row=0;    

#遍历函数实体
foreach my $ent (sort {lc($a->longname()) cmp lc($b->longname());} @ents){
  #被定义关系
  my $ref = $ent->ref("definein");
  next unless $ref;
  
  #行数+1写入当前函数实体信息
  $row=$row+1;
  $worksheet->write($row,0,$ent->longname); 
  $worksheet->write($row,1,$ent->metric("CountLineCode")); 
  $worksheet->write($row,2,$ent->metric("CountPath")); 
  $worksheet->write($row,3,$ent->metric("Cyclomatic")); 
  $worksheet->write($row,4,$ent->metric("MaxNesting")); 
  $worksheet->write($row,5,$ent->metric("Knots")); 
  $worksheet->write($row,6,$ent->metric("CountInput")); 
  $worksheet->write($row,7,$ent->metric("CountOutput")); 
  $worksheet->write($row,8,$ref->file->relname); 
}

$ent->close();
