function [data] = valuta_orientaz(s, n, offset, sPos)

nBrds = size(s,2);

for i = 1:n
  data = get_data(s, offset);
  X(:, i) = data(:, 1);
  Y(:, i) = data(:, 2);
  Z(:, i) = data(:, 3);
 [s_azimuth(:,i),s_elevation(:,i),s_r(:,i)] = cart2sph(data(:,1), data(:,2), data(:,3));
end

 figure
 s_azimuth = rad2deg(s_azimuth);
 s_az_m = mean(s_azimuth')';
 s_az_s = std(s_azimuth')';
 boxplot(s_azimuth')
 
 figure
 s_elevation = rad2deg(s_elevation);
 s_az_m = mean(s_elevation')';
 s_az_s = std(s_elevation')';
 boxplot(s_elevation')
 
 figure
 s_az_m = mean(s_r')';
 s_az_s = std(s_r')';
 boxplot(s_r')



% data = get_data(s, offset);
% for j = 1:n
%   data = data + get_data(s, offset);
% end
% data = data / n;


quiver3(sPos(1:32,1)*1000,sPos(1:32,2)*1000,sPos(1:32,3)*1000,data(1:32,1),data(1:32,2),data(1:32,3))
axis equal

[s_azimuth,s_elevation,s_r] = cart2sph(data(:,1), data(:,2), data(:,3));

end


