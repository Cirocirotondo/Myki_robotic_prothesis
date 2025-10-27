function [T] = send_to_Processing(p, x, MF, time, sPos, bPos, sens2ignore)
%send_to_Processing invia i dati all'interfaccia Processing per la
%visualizzazione.

if nargin <1
    MAIN
end

nMag = size(x(:),1)/6;
nSens = size(sPos,1);
nBoards = nSens/32;
x_temp = x';
x_ = cast2byte(x_temp(:)');
MF = MF';
if size(MF,2) < 32*nBoards
  MF(:, end:32*nBoards) = 0;
end
MF_ = cast2byte(MF(:));
time_ = cast2byte(time);
% sPosT = sPos';
% sPos_ = cast2byte(sPosTh(:));
bPos = bPos'*10000;
temp = bPos(:, 1: nBoards);
bPos_ = cast2byte(temp(:));
sensHide = sens2ignore*[32;1]-32;
nHide = size(sensHide,1);
sensHide_ = cast2byte(sensHide(:));

tic
fwrite(p{1,1}, '#');
fwrite(p{1,1}, '#');
fwrite(p{1,1}, '#');

fwrite(p{1,1}, 'B');
fwrite(p{1,1}, 'b');
fwrite(p{1,1}, cast2byte(nBoards)); %char(nBoards));
fwrite(p{1,1}, bPos_);

fwrite(p{1,1}, 'S');
fwrite(p{1,1}, 's');
% fwrite(p{1,1}, cast2byte(nSens));
for i = 1:nBoards
  fwrite(p{1,1}, MF_((i-1)*96*4+1:i*96*4));
end
fwrite(p{1,1}, 'M');
fwrite(p{1,1}, 'm');
fwrite(p{1,1}, cast2byte(nMag));
fwrite(p{1,1}, x_);

fwrite(p{1,1}, 'H');
fwrite(p{1,1}, 'h');
fwrite(p{1,1}, cast2byte(nHide));
fwrite(p{1,1}, sensHide_);

% fwrite(p{1,1}, 'P');
% fwrite(p{1,1}, nSens);
% for i = 1:nBoards
%   fwrite(p{1,1}, sPos_((i-1)*96+1:i*96));
% end
fwrite(p{1,1}, 'T');
fwrite(p{1,1}, 't');
fwrite(p{1,1}, time_);

fwrite(p{1,1}, 'Z');    %caratteri di terminazione
fwrite(p{1,1}, 'z');

T = toc;
end
