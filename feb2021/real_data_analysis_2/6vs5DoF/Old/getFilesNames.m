function [dato] = getFilesNames()
%getFilesNames  preleva i nomi dei files che finiscono per *.mat

folderlisting = dir;
  for i = 1:size(folderlisting,1)
    foldernames{i} = folderlisting(i).name;
  end

  j = 1;
  for i = 1:size(folderlisting,1)
    if strfind(foldernames{i},'.mat')
      dato{j} = foldernames{i};
      j = j+1;
    end
  end
end
