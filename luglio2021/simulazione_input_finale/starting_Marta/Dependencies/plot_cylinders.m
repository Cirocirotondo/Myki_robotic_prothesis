function plot_cylinders(x_vector,v_factor)  
% Plot enclosed cylinder
% Sample values
h = 1;     % height
ra = 1;   % radius
% Create constant vectors
vectors_mag = reshape(x_vector,[3,length(x_vector)/3])';   
tht = linspace(0,2*pi,100); z = linspace(0,h,20);
% Create cylinder
xa = repmat(ra*cos(tht),20,1); 
ya = repmat(ra*sin(tht),20,1);
za = repmat(z',1,100);
% To close the ends
X = [xa*0; flipud(xa); (xa(1,:))*0]; 
Y = [ya*0; flipud(ya); (ya(1,:))*0];
Z = [za; flipud(za); za(1,:)];

% Draw cylinder
for i= 1:size(vectors_mag,1)
    [TRI,v]= surf2patch((X*0.1*0.39*v_factor)+vectors_mag(i,1),(Y*0.2*0.39*v_factor)+vectors_mag(i,2),(Z*0.2*0.39*v_factor)+vectors_mag(i,3),'triangle'); 
    a = patch('Vertices',v,'Faces',TRI,'facealpha',0.8,'facecolor',[0 0 0],'edgecolor',[0 0 0]);%,'linestyle','none');%[0.5 0.8 0.8]);
    hold on
%     a.FaceColor = [0.635 0.078 0.184];
%     a.EdgeColor = [0.635 0.078 0.184];
%     [0.635 0.078 0.184]
end
axis equal
end