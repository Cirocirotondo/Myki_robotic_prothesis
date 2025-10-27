function [] = MyBar(data, labels, Ylab, Xlab, Tit)
%MyBar fa un barplot con didascalie e titoli
figure
datamat = cell2mat(data');
hold on
barh(datamat')
yticks(1:size(datamat,2))
% yticklabels(categorical(labels));
% barh(categorical(labels), datamat)
% scatter(categorical(labels), datamatMean, '+')
axis ij
legend('6 DoFs', '5 DoFs')
hold off
ylabel(Ylab)
% legend('Magnet #1', 'Magnet #2', 'Magnet #3')
if nargin >= 4
    xlabel(Xlab)
end
if nargin >= 5
    title(Tit)
end
end
