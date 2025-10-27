function B = MultiPoleExpansion(D,L,M,poseMag,point,magDir,n)

% Check if the input vectors are column vectors. If not transpose them
if size(poseMag,1) == 1
    poseMag = poseMag';
end
if size(point,1) == 1
    point = point';
end

% variables' initialization
mu0  = 4*pi*1e-7;
beta = D/L;                           % diameter-to-length aspect ratio
V    = pi*(D/2)^2*L;
pvec = point - poseMag(1:3);
p    = norm(pvec);                    % distance between magnet center and 
                                      % point of interest
pv   = pvec/p;                        % unit vector 
m    = poseMag(4:6)*M*V;              % magnetic moment
I    = eye(3);                        % Identity matrix 3 x 3

ppT  = pv*pv';
mTp  = m'*pv/(M*V);

% Dipole term
B1 = mu0/(4*pi*p^3)*(3*ppT - I)*m;

if (magDir == 0) 
   %% Axial magnetization ------------------------------------------------
   
   switch n
       case 3
           % Quadrupole term
           B3 = mu0/(4*pi*p^5)*(L/2)^2*(4-3*beta^2)/8*              ...
               ((35*(mTp)^2-15)*ppT - (15*(mTp)^2-3)*I)*m;
           
           B = B1 + B3;
           
       case 5
           % Quadrupole term
           B3 = mu0/(4*pi*p^5)*(L/2)^2*(4-3*beta^2)/8*              ...
               ((35*(mTp)^2-15)*ppT - (15*(mTp)^2-3)*I)*m;
           
           % Octopole term
           B5 = mu0/(4*pi*p^7)*(L/2)^4*(15*beta^4-60*beta^2+24)/64* ...
               ((231*(mTp)^4-210*(mTp)^2+35)*ppT -                  ...
               (105*(mTp)^4-70*(mTp)^2+5)*I)*m;
           
           B = B1 + B3 + B5;
           
       otherwise
           
           B = B1;
           
   end
    
    % --------------------------------------------------------------------
else    
   %% Diametric magnetization --------------------------------------------
   
   switch n
       case 3
           % Quadrupole term
           B3 = mu0/(4*pi*p^5)*(L/2)^2*(4-3*beta^2)/8*              ...
               ((35*(mTp)^2-15)*ppT - (15*(mTp)^2-3)*I)*m;
           
           B = B1 + B3;
           
       case 5
           % Quadrupole term
           B3 = mu0/(4*pi*p^5)*(L/2)^2*(3*beta^2-4)/8*              ...
               ((35*(mTp)^2-15)*ppT - (15*(mTp)^2-3)*I)*m;
           
           % Octopole term
           B5 = mu0/(4*pi*p^7)*(L/2)^4*(15*beta^4-60*beta^2+24)/64* ...
               ((231*(mTp)^4-210*(mTp)^2+35)*ppT -                  ...
               (105*(mTp)^4-70*(mTp)^2+5)*I)*m;
           
           B = B1 + B3 + B5;
           
       otherwise
           
           B = B1;
           
   end
   
    % --------------------------------------------------------------------
end