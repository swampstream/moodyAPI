function F = moodyAPI(stageName,varargin)
%moodyAPI Interface between Moody API and matlab .m-files.
%   This function is a wrapper for access to functions moodyInit, moodySolve and moodyClose
%
% NB: There is a known issue with incomplete unloading (at least for linux
% version of matlab R2017b). Memory fills up when running moodyAPI a second
% time. This does not happen when the same moody-code runs through the
% terminal (see tutorial/runFromTerminal.sh)

switch stageName
    case {1 , 'init'}
        moodyInit(varargin{:});        
        F = -1;        
    case {2 , 'solve'}
        F = moodySolve(varargin{:});        
    
    case {3 , 'close'}
        moodyClose();        
        F = -1;
        
end

end

%% INITIALIZATION CALL TO MOODY
function moodyInit(name,X,startTime)
  if (ismac)
    loadlibrary('libmoody.dylib','moodyWrapper.h');
  else    
    moodyHome='/home/johannep/work/proj/moody/repo/packages/moody-2.0.0-Linux';
    addpath([moodyHome '/lib']);
    addpath([moodyHome '/include']);    
    loadlibrary('libmoody.so','moodyWrapper.h','includepath',[moodyHome '/include']);
   end
    calllib('libmoody','moodyInit',name,length(X),X,startTime);        
end

%% SOLVE MOORING DYNAMICS BETWEEN T1 and T2. 
%  RETURN MOORING FORCES FOR EACH DOF OF X AS F
function F = moodySolve(X,T1,T2)       
    F_value = zeros(size(X));    
    F_p = libpointer('doublePtr',F_value);
    calllib('libmoody','moodySolve',X,F_p,T1,T2);    
    F = F_p.value;
end

%% CLOSE MOODY LIB
function moodyClose()
    calllib('libmoody','moodyClose');    
    unloadlibrary('libmoody');
end

