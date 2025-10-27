function F = dipdipForce(rv,m1v,m2v)

mu0  = 4*pi*1e-7;
m1   = norm(m1v);
m1uv = m1v/m1;
m2   = norm(m2v);
m2uv = m2v/m2;
r    = norm(rv);
ruv  = rv/r;

F = 3*mu0*m1*m2/(4*pi*r^4)*(((m1uv'*m2uv)-5*(m1uv'*ruv)*(m2uv'*ruv))*ruv...
                             (m1uv'*ruv)*m2uv+(m2uv'*ruv)*m1uv);
