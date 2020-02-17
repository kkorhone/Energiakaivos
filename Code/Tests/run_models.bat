@set CB="C:\Program Files\COMSOL\COMSOL55\Multiphysics\bin\win64\comsolbatch.exe"

@dir full_ico_meshed.mph
@dir full_uv_meshed.mph
@dir quarter_ico_meshed.mph
@dir quarter_uv_meshed.mph

%CB% -np 8   -inputfile    full_ico_meshed.mph   -outputfile    full_ico_solved.mph
%CB% -np 8   -inputfile     full_uv_meshed.mph   -outputfile     full_uv_solved.mph
%CB% -np 8   -inputfile quarter_ico_meshed.mph   -outputfile quarter_ico_solved.mph
%CB% -np 8   -inputfile  quarter_uv_meshed.mph   -outputfile  quarter_uv_solved.mph
