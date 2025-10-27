function p = plot_muscles(fi, ind)   

    axis equal
    
    
        [v1, f1 ] = stlReadAscii('shoulder_arm_skin_POLLICI_stl.stl');


        object1.vertices = [-v1(:,1), v1(:,2),-v1(:,3)];
        object1.faces = f1;
        
        alfa= 0.1;
        patch(object1,'FaceColor',       [0.8 0.8 1.0], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15,          ...
         'FaceAlpha', alfa );
     
        hold on
        alfa= 0.1;
        
        for k = 1:length(fi)
                [v2, f2 ] = stlReadAscii(fi{k});
                object2.vertices = v2;
                object2.faces = f2;
                patch(object2,'FaceColor',       [0.8 0.8 1.0], ...
                'EdgeColor',       'none',        ...
                'FaceLighting',    'gouraud',     ...
                'AmbientStrength', 0.15,          ...
                'FaceAlpha', alfa );
        end

%         cc = [0.3010, 0.7450, 0.9330; 0.8500, 0.3250, 0.0980; 0.9290, 0.6940, 0.1250;...
%            0.4940, 0.1840, 0.5560; 0.4660, 0.6740, 0.1880;0, 0.4470, 0.7410 ;...
%            0.6350, 0.0780, 0.1840];
% 
%        indd = 1;
%        if ind>= 12 && ind <= 15 
%            indd = 12; % ED
%        elseif ind>= 16 && ind <= 19
%            indd = 13; % FDS
%        elseif ind>= 20 && ind <= 23
%            indd = 14; % FDP
%        else 
%            indd = ind;
%        end
%        
%         cc_r = 1;
% %         for k = 1:length(fi)
%           for k = indd
%                 [v2, f2 ] = stlReadAscii(fi{k});
%                 object2.vertices = v2;
%                 object2.faces = f2;
%                 patch(object2, 'FaceColor', cc(cc_r,:),...
%                 'EdgeColor',       'none',        ...
%                 'AmbientStrength', 0.15,          ...
%                 'FaceAlpha', alfa );
%             cc_r = cc_r + 1;
%             if cc_r > size(cc,1)
%                 cc_r = 1;
%             end
%           end
        
    p = 1 ;
    camlight('left')
    material('dull')

     

end