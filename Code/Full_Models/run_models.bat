@set CB="C:\Program Files\COMSOL\COMSOL55\Multiphysics\bin\win64\comsolbatch.exe"

%CB% -np 8   -inputfile  quarter_ico_25_bhes.mph   -outputfile    quarter_ico_25_bhes_solved.mph
%CB% -np 8   -inputfile  quarter_uv_25_bhes.mph   -outputfile    quarter_uv_25_bhes_solved.mph

%CB% -np 8   -inputfile  quarter_ico_89_bhes.mph   -outputfile    quarter_ico_89_bhes_solved.mph
%CB% -np 8   -inputfile  quarter_uv_85_bhes.mph   -outputfile    quarter_uv_85_bhes_solved.mph

%CB% -np 8   -inputfile  quarter_ico_136_bhes.mph   -outputfile    quarter_ico_136_bhes_solved.mph
%CB% -np 8   -inputfile  quarter_uv_145_bhes.mph   -outputfile    quarter_uv_145_bhes_solved.mph
