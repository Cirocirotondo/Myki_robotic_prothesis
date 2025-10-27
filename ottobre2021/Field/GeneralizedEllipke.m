%% Computation of the generalized complete elliptic integral
 % --------------------------------------------------------------------
 % Implementation here is proposed following the original algorithm
 % in BASIC proposed by Bulirsch (Numerical Computation, 1965).
 % No detailed description can be provided for the inputs 1)-4), just take
 %  a look at the formula below to understand their meaning.
 %
 %               pi/2             (c*cos^2(t)+s*sin^2(t))
 % C(kc,p,c,s) = INT -------------------------------------------------- dt
 %               0   (cos^2(t)+p*sin^2(t))*sqrt(cos^2(t)+kc^2*sin^2(t))
 %
 % Inputs:
 %    1) kc     :                                                 [number]
 %    2) p      :                                                 [number] 
 %    3) c      :                                                 [number]
 %    4) s      :                                                 [number]
 %    5) Tol    : tolerance error for integral convergence        [number]
 %
 % Outputs:
 %    1) C      : generalized complete elliptic integral          [number]
 %
 % ATTENTION: % One may varify the equivalence with the functions ellipke 
 % and ellipticPi in the following cases:
 % Given a value kc in [0, 1] 
 % [K E] = ellipke(1-kc^2);      ---->  K  = C(kc,1,1,1) 
 %                               ---->  E  = C(kc,1,1,kc^2)
 % PI    = ellipticPi(n,1-kc^2)  ---->  PI = C(kc,1-n,1,1)
 %
 % Note: This function computes the complete elliptic integrals faster
 % than the built-in function of Matlab!
 % ---------------------------------------------------------------------
 % August 5th, 2019                            Author: Federico Masiero
 % ---------------------------------------------------------------------
 
function C = GeneralizedEllipke(kc,p,c,s,Tol)
 
if (kc == 0)
    C = Inf;
    return
end

eps = Tol;   % error tolerance

k  = abs(kc);
pp = p;
cc = c;
ss = s;
em = 1;

if p > 0
    pp = sqrt(p);
    ss = s/pp;
else
    f  = kc*kc;
    q  = 1 - f;
    g  = 1 - pp;
    f  = f - pp;
    q  = q*(ss - c*pp);
    pp = sqrt(f/g);
    cc = (c - ss)/g;
    ss = cc*pp - q/(g*g*pp);
end

f  = cc;
cc = cc + ss/pp;
g  = k/pp;
ss = 2*(ss + f*g);
pp = g + pp;
g  = em;
em = k + em;
kk = k;

while ( abs(g-k) > g*eps )
    
    k  = 2*sqrt(kk);
    kk = k*em;
    f  = cc;
    cc = cc + ss/pp;
    g  = kk/pp;
    ss = 2*(ss + f*g);
    pp = g + pp;
    g  = em;
    em = k + em;
    
end

C = (pi/2)*(ss + cc*em)/(em*(em + pp));