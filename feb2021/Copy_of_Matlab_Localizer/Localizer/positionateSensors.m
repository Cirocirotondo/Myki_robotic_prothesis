function [sensPos] = positionateSensors(sensPos_wrtBoard, Bpos,nBoards)
%positionateSensors posiziona i sensori nello spazio in base alla posa delle boards
  sensPos = [];
  for i = 1:nBoards
    % sensPos(end+1:end+32, 1:3) = rotateMat([sensPos_wrtBoard+Bpos(i, 1:3)], Bpos(i, 4), Bpos(i, 5), Bpos(i, 6));
    temp = rotateMat([sensPos_wrtBoard], Bpos(i, 4), Bpos(i, 5), Bpos(i, 6));
    sensPos(end+1:end+32, 1:3) = temp + Bpos(i, 1:3);
  end
end
