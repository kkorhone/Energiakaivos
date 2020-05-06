set CB="C:\Program Files\COMSOL\COMSOL55\Multiphysics\bin\win64\comsolbatch.exe"

%CB% -np 8 -inputfile ico_field_8_300m_meshed.mph -outputfile ico_field_8_300m_solved_1Ma.mph
%CB% -np 8 -inputfile ico_field_25_300m_meshed.mph -outputfile ico_field_25_300m_solved_1Ma.mph
%CB% -np 8 -inputfile ico_field_89_300m_meshed.mph -outputfile ico_field_89_300m_solved_1Ma.mph
%CB% -np 8 -inputfile ico_field_136_300m_meshed.mph -outputfile ico_field_136_300m_solved_1Ma.mph
%CB% -np 8 -inputfile ico_field_337_300m_meshed.mph -outputfile ico_field_337_300m_solved_1Ma.mph
