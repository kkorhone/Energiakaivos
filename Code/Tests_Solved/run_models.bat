@set CB="C:\Program Files\COMSOL\COMSOL55\Multiphysics\bin\win64\comsolbatch.exe"

@rem %CB% -np 8   -inputfile  ico_25_bhes.mph   -outputfile    ico_25_bhes_solved.mph
@rem %CB% -np 8   -inputfile  uv_25_bhes.mph   -outputfile    uv_25_bhes_solved.mph

@rem %CB% -np 8   -inputfile  ico_89_bhes.mph   -outputfile    ico_89_bhes_solved.mph
@rem %CB% -np 8   -inputfile  uv_85_bhes.mph   -outputfile    uv_85_bhes_solved.mph

%CB% -np 8   -inputfile  ico_136_bhes.mph   -outputfile    ico_136_bhes_solved.mph
%CB% -np 8   -inputfile  uv_145_bhes.mph   -outputfile    uv_145_bhes_solved.mph

%CB% -np 8   -inputfile  ico_337_bhes.mph   -outputfile    ico_337_bhes_solved.mph
%CB% -np 8   -inputfile  uv_339_bhes.mph   -outputfile    uv_339_bhes_solved.mph
