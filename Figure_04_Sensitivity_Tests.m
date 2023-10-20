clear all
close all
clc

[filename pathname] = uigetfile({'*'},'File Selector'); 
if ispc == 1
	fullpathname = char(strcat(pathname, '\', filename));
end
if ismac == 1
	fullpathname = char(strcat(pathname, '/', filename));
end
[numbers text, data] = xlsread(fullpathname);
original = numbers(:,9:10);

[filename pathname] = uigetfile({'*'},'File Selector'); 
if ispc == 1
	fullpathname = char(strcat(pathname, '\', filename));
end
if ismac == 1
	fullpathname = char(strcat(pathname, '/', filename));
end
[numbers2 text2, data2] = xlsread(fullpathname);
for i = 1:length(numbers2(:,1))
	idx = find(numbers(:,12)==numbers2(i,12));
	numbers(idx,:) = [];
end
modified = numbers(:,9:10);

xax_min = 0;
xax_max = 1000;
yax_min = 3;
yax_max = 9;

wind = 250; %running median

X2a = (original(:,1));
Y2a = (original(:,2));
[X_sorteda, X_ordera] = sort(X2a);
Y_sorteda = Y2a(X_ordera,:);
M2a = movmedian(Y_sorteda,wind);

X2b = (modified(:,1));
Y2b = (modified(:,2));
[X_sortedb, X_orderb] = sort(X2b);
Y_sortedb = Y2b(X_orderb,:);
M2b = movmedian(Y_sortedb,wind);

F1 = figure;
hold on
plot3(X_sorteda,M2a,ones(length(M2a),1), 'linewidth',3, 'color', 'r')
plot3(X_sortedb,M2b,ones(length(M2b),1), 'linewidth',3, 'color', 'b')
%axis([0 1000 yax_min yax_max])
xlim([0 1000])

[file,path] = uiputfile('*.eps','Save file'); print(F1,'-depsc','-painters',[path file]); epsclean([path file]); % save simplified contours
