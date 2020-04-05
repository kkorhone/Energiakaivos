set CB="C:\Program Files\COMSOL\COMSOL55\Multiphysics\bin\win64\comsolbatch.exe"

%CB% -np 8 -inputfile stress_300m_meshed.mph -outputfile stress_300m_solved.mph
%CB% -np 8 -inputfile stress_400m_meshed.mph -outputfile stress_400m_solved.mph
%CB% -np 8 -inputfile stress_500m_meshed.mph -outputfile stress_500m_solved.mph
%CB% -np 8 -inputfile stress_600m_meshed.mph -outputfile stress_600m_solved.mph
